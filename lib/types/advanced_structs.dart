import 'dart:ffi';
import 'package:ffi/ffi.dart';
import '../utils/alignment.dart';
import '../utils/endian.dart';

/// SIMD-aligned vector for fast operations
@Packed(1)
final class SimdVector extends Struct {
  @Array(4)
  external Array<Float> values; // 16-byte aligned for SIMD

  /// Allocates memory for a `SimdVector` instance.
  ///
  /// Returns a pointer to the allocated memory.
  static Pointer<SimdVector> alloc() {
    return calloc.align16<SimdVector>();
  }

  /// Sets the values of the SIMD vector.
  ///
  /// * [newValues]: A list of 4 double values to set.
  /// Throws an `ArgumentError` if the length of [newValues] is not 4.
  void setValues(List<double> newValues) {
    if (newValues.length != 4) {
      throw ArgumentError('SIMD vector requires exactly 4 values');
    }
    for (var i = 0; i < 4; i++) {
      values[i] = newValues[i].toDouble();
    }
  }

  /// Frees the allocated memory for a `SimdVector` instance.
  ///
  /// * [ptr]: The pointer to the `SimdVector` instance to free.
  static void free(Pointer<SimdVector> ptr) {
    calloc.free(ptr);
  }
}

/// Resizable array with alignment preservation
final class DynamicAlignedArray extends Struct {
  external Pointer<Uint8> data;
  @Int32()
  external int length;
  @Int32()
  external int capacity;
  @Int32()
  external int elementSize;
  @Int32()
  external int alignment;

  /// Creates a `DynamicAlignedArray` instance with the specified parameters.
  ///
  /// * [initialCapacity]: The initial capacity of the array.
  /// * [elementSize]: The size of each element in the array.
  /// * [alignment]: The alignment requirement for the array.
  /// Returns a pointer to the allocated `DynamicAlignedArray` instance.
  static Pointer<DynamicAlignedArray> create({
    int initialCapacity = 16,
    int elementSize = 4,
    int alignment = 4,
  }) {
    final ptr = calloc<DynamicAlignedArray>();
    ptr.ref
      ..length = 0
      ..capacity = initialCapacity
      ..elementSize = elementSize
      ..alignment = alignment;

    // Allocate aligned memory for data
    ptr.ref.data = calloc
        .allocAligned<DynamicAlignedArray>(
          elementSize * initialCapacity,
          alignment,
        )
        .cast();

    return ptr;
  }

  /// Resizes the array to the specified capacity.
  ///
  /// * [newCapacity]: The new capacity of the array.
  void resize(int newCapacity) {
    if (newCapacity <= capacity) return;

    final newData = calloc
        .allocAligned<DynamicAlignedArray>(
          elementSize * newCapacity,
          alignment,
        )
        .cast<Uint8>();

    // Copy existing data
    for (var i = 0; i < length * elementSize; i++) {
      newData[i] = data[i];
    }

    calloc.free(data);
    data = newData;
    capacity = newCapacity;
  }

  /// Adds an element to the array.
  ///
  /// * [element]: The element to add.
  void add(Pointer<NativeType> element) {
    if (length == capacity) {
      resize(capacity * 2);
    }

    final srcBytes = element.cast<Uint8>();
    final offset = length * elementSize;

    for (var i = 0; i < elementSize; i++) {
      data[offset + i] = srcBytes[i];
    }
    length++;
  }

  /// Returns the element at the specified index.
  ///
  /// * [index]: The index of the element to retrieve.
  /// Returns a pointer to the element at the specified index.
  /// Throws a `RangeError` if the index is out of bounds.
  Pointer<T> at<T extends NativeType>(int index) {
    if (index < 0 || index >= length) {
      throw RangeError('Index out of bounds');
    }
    return (data + (index * elementSize)).cast<T>();
  }

  /// Disposes the array and frees the allocated memory.
  void dispose() {
    calloc.free(data);
    data = nullptr;
    length = 0;
    capacity = 0;
  }

  /// Frees the allocated memory for a `DynamicAlignedArray` instance.
  ///
  /// * [ptr]: The pointer to the `DynamicAlignedArray` instance to free.
  static void free(Pointer<DynamicAlignedArray> ptr) {
    ptr.ref.dispose();
    calloc.free(ptr);
  }
}

/// Mixed endianness struct for network protocols
final class NetworkMessage extends Struct {
  // Network byte order (big-endian)
  @Int32()
  @ByteOrder(StructEndian.network)
  external int messageId; // 4 bytes

  // Host byte order
  @Int32()
  @ByteOrder(StructEndian.host)
  external int flags; // 4 bytes

  // Little-endian
  @Int64()
  @ByteOrder(StructEndian.little)
  external int timestamp; // 8 bytes

  // Network byte order (big-endian)
  @Int32()
  @ByteOrder(StructEndian.network)
  external int dataLength; // 4 bytes

  external Pointer<Uint8> data;

  /// Allocates memory for a `NetworkMessage` instance.
  ///
  /// Returns a pointer to the allocated memory.
  static Pointer<NetworkMessage> alloc() {
    return calloc<NetworkMessage>();
  }

  /// Sets the data for the network message.
  ///
  /// * [bytes]: A list of bytes to set as the data.
  void setData(List<int> bytes) {
    if (data != nullptr) {
      calloc.free(data);
    }
    dataLength = bytes.length;
    data = calloc<Uint8>(bytes.length);
    final buffer = data.asTypedList(bytes.length);
    buffer.setAll(0, bytes);
  }

  /// Retrieves the data from the network message.
  ///
  /// Returns a list of bytes representing the data.
  List<int> getData() {
    if (data == nullptr || dataLength == 0) return [];
    return data.asTypedList(dataLength).toList();
  }

  /// Disposes the network message and frees the allocated memory.
  void dispose() {
    if (data != nullptr) {
      calloc.free(data);
      data = nullptr;
    }
  }

  /// Frees the allocated memory for a `NetworkMessage` instance.
  ///
  /// * [ptr]: The pointer to the `NetworkMessage` instance to free.
  static void free(Pointer<NetworkMessage> ptr) {
    ptr.ref.dispose();
    calloc.free(ptr);
  }
}
