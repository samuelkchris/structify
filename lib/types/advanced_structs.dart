import 'dart:ffi';
import 'package:ffi/ffi.dart';
import '../utils/alignment.dart';
import '../utils/endian.dart';

/// SIMD-aligned vector for fast operations
@Packed(1)
final class SimdVector extends Struct {
  @Array(4)
  external Array<Float> values; // 16-byte aligned for SIMD

  static Pointer<SimdVector> alloc() {
    return calloc.align16<SimdVector>();
  }

  void setValues(List<double> newValues) {
    if (newValues.length != 4) {
      throw ArgumentError('SIMD vector requires exactly 4 values');
    }
    for (var i = 0; i < 4; i++) {
      values[i] = newValues[i].toDouble();
    }
  }

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

  Pointer<T> at<T extends NativeType>(int index) {
    if (index < 0 || index >= length) {
      throw RangeError('Index out of bounds');
    }
    return data.elementAt(index * elementSize).cast();
  }

  void dispose() {
    calloc.free(data);
    data = nullptr;
    length = 0;
    capacity = 0;
  }

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

  static Pointer<NetworkMessage> alloc() {
    return calloc<NetworkMessage>();
  }

  void setData(List<int> bytes) {
    if (data != nullptr) {
      calloc.free(data);
    }
    dataLength = bytes.length;
    data = calloc<Uint8>(bytes.length);
    final buffer = data.asTypedList(bytes.length);
    buffer.setAll(0, bytes);
  }

  List<int> getData() {
    if (data == nullptr || dataLength == 0) return [];
    return data.asTypedList(dataLength).toList();
  }

  void dispose() {
    if (data != nullptr) {
      calloc.free(data);
      data = nullptr;
    }
  }

  static void free(Pointer<NetworkMessage> ptr) {
    ptr.ref.dispose();
    calloc.free(ptr);
  }
}
