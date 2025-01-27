import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

/// Alignment options for struct fields
enum StructAlignment {
  /// No alignment, pack tightly
  packed(1),

  /// 2-byte alignment
  align2(2),

  /// 4-byte alignment (default for most platforms)
  align4(4),

  /// 8-byte alignment
  align8(8),

  /// 16-byte alignment (for SIMD)
  align16(16);

  /// The integer value representing the alignment
  final int value;

  /// Constructs a [StructAlignment] with the given value
  const StructAlignment(this.value);
}

/// Annotation for specifying field alignment
class Aligned {
  /// The alignment to be applied to the field
  final StructAlignment alignment;

  /// Constructs an [Aligned] annotation with the given alignment
  const Aligned(this.alignment);
}

/// Annotation for packed structs (no padding)
const packed = Aligned(StructAlignment.packed);

/// Helper functions for alignment calculations
class AlignmentUtils {
  /// Calculate padding needed to align to the given boundary
  ///
  /// * [offset]: The current offset
  /// * [alignment]: The alignment boundary
  /// Returns the padding needed to align to the boundary
  static int calculatePadding(int offset, int alignment) {
    if (alignment <= 1) return 0;
    final remainder = offset % alignment;
    return remainder == 0 ? 0 : alignment - remainder;
  }

  /// Get the next aligned offset
  ///
  /// * [offset]: The current offset
  /// * [alignment]: The alignment boundary
  /// Returns the next aligned offset
  static int alignOffset(int offset, int alignment) {
    return offset + calculatePadding(offset, alignment);
  }

  /// Calculate total size with alignment
  ///
  /// * [size]: The current size
  /// * [alignment]: The alignment boundary
  /// Returns the total size with alignment
  static int calculateAlignedSize(int size, int alignment) {
    return alignOffset(size, alignment);
  }

  /// Verify if an offset is properly aligned
  ///
  /// * [offset]: The current offset
  /// * [alignment]: The alignment boundary
  /// Returns true if the offset is properly aligned, false otherwise
  static bool isAligned(int offset, int alignment) {
    return offset % alignment == 0;
  }
}

/// Extension to help with aligned memory allocation
extension AlignedAlloc on Allocator {
  /// Allocate aligned memory for custom sized native types
  ///
  /// * [size]: The size of the memory to allocate
  /// * [alignment]: The alignment boundary
  /// * [count]: The number of elements to allocate (default is 1)
  /// Returns a pointer to the allocated memory
  Pointer<T> allocAligned<T extends Struct>(
    int size,
    int alignment, {
    int count = 1,
  }) {
    // Calculate the required size with space for alignment
    final baseSize = count * size;
    final totalSize = baseSize + alignment - 1;

    // Allocate memory with extra space for alignment
    final ptr = calloc<Uint8>(totalSize);

    // Calculate the aligned address
    final addr = ptr.address;
    final alignedAddr = (addr + alignment - 1) & ~(alignment - 1);

    // Convert back to pointer
    return Pointer.fromAddress(alignedAddr).cast<T>();
  }

  /// Helper methods for common alignments
  ///
  /// * [count]: The number of elements to allocate (default is 1)
  /// Returns a pointer to the allocated memory
  Pointer<T> align4<T extends Struct>({int count = 1}) {
    return allocAligned<T>(sizeOf<Int32>(), 4, count: count);
  }

  /// Helper methods for common alignments
  ///
  /// * [count]: The number of elements to allocate (default is 1)
  /// Returns a pointer to the allocated memory
  Pointer<T> align8<T extends Struct>({int count = 1}) {
    return allocAligned<T>(sizeOf<Int64>(), 8, count: count);
  }

  /// Helper methods for common alignments
  ///
  /// * [count]: The number of elements to allocate (default is 1)
  /// Returns a pointer to the allocated memory
  Pointer<T> align16<T extends Struct>({int count = 1}) {
    return allocAligned<T>(16, 16, count: count);
  }
}

/// Example of a struct with custom alignment
final class AlignedStruct extends Struct {
  @Int32()
  @Aligned(StructAlignment.align4)
  external int intField; // 4-byte aligned

  @Float()
  @Aligned(StructAlignment.align8)
  external double doubleField; // 8-byte aligned

  @Int32()
  @Aligned(StructAlignment.align2)
  external int shortField; // 2-byte aligned as int32

  @Int32()
  @packed
  external int byteField; // No alignment (packed)

  /// Allocates memory for an [AlignedStruct] instance
  ///
  /// Returns a pointer to the allocated memory
  static Pointer<AlignedStruct> alloc() {
    // Align to 16-byte boundary using the helper method
    return calloc.align16<AlignedStruct>();
  }

  /// Frees the allocated memory for an [AlignedStruct] instance
  ///
  /// * [ptr]: The pointer to the [AlignedStruct] instance to free
  static void free(Pointer<AlignedStruct> ptr) {
    calloc.free(ptr);
  }
}

/// Struct field metadata class
class StructField {
  /// The offset of the field
  final int offset;

  /// The size of the field
  final int size;

  /// The alignment of the field
  final StructAlignment alignment;

  /// Constructs a [StructField] with the given offset, size, and alignment
  const StructField({
    required this.offset,
    required this.size,
    this.alignment = StructAlignment.align4,
  });

  /// Calculate the next field offset considering alignment
  ///
  /// Returns the next field offset
  int get nextOffset => AlignmentUtils.alignOffset(
        offset + size,
        alignment.value,
      );
}

/// Function to analyze struct layout
///
/// * [struct]: The [AlignedStruct] instance to analyze
void analyzeStructLayout(AlignedStruct struct) {
  final fields = [
    StructField(
        offset: 0, size: sizeOf<Int32>(), alignment: StructAlignment.align4),
    StructField(
        offset: 8, size: sizeOf<Float>(), alignment: StructAlignment.align8),
    StructField(
        offset: 16, size: sizeOf<Int32>(), alignment: StructAlignment.align2),
    StructField(
        offset: 20, size: sizeOf<Int32>(), alignment: StructAlignment.packed),
  ];

  int totalSize = 0;
  for (var field in fields) {
    final padding =
        AlignmentUtils.calculatePadding(field.offset, field.alignment.value);
    totalSize = field.nextOffset;

    stdout.write('Field at offset ${field.offset}: '
          'size ${field.size}, '
          'alignment ${field.alignment.value}, '
          'padding $padding bytes');

  }

  // Round up total size to struct alignment
  totalSize = AlignmentUtils.calculateAlignedSize(totalSize, 16);

  stdout.write('Total struct size: $totalSize bytes');

}
