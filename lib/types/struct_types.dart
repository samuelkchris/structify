import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import '../core/base.dart';

/// Complex struct example showing nested structs and arrays
final class ComplexStruct extends Struct {
  @Int32()
  external int id;

  external Point start;

  external Point end;

  @Array(10)
  external Array<Int32> data;

  static Pointer<ComplexStruct> alloc() {
    return calloc<ComplexStruct>();
  }

  static ComplexStruct create() {
    return alloc().ref;
  }

  ByteBuffer serialize() {
    final buffer = ByteData(sizeOf<ComplexStruct>());
    var offset = 0;

    // Write id
    buffer.setInt32(offset, id, Endian.host);
    offset += sizeOf<Int32>();

    // Write start point
    final startBuffer = start.serialize();
    final startData = ByteData.view(startBuffer);
    for (var i = 0; i < sizeOf<Point>(); i++) {
      buffer.setUint8(offset + i, startData.getUint8(i));
    }
    offset += sizeOf<Point>();

    // Write end point
    final endBuffer = end.serialize();
    final endData = ByteData.view(endBuffer);
    for (var i = 0; i < sizeOf<Point>(); i++) {
      buffer.setUint8(offset + i, endData.getUint8(i));
    }
    offset += sizeOf<Point>();

    // Write data array
    for (var i = 0; i < 10; i++) {
      buffer.setInt32(offset, data[i], Endian.host);
      offset += sizeOf<Int32>();
    }

    return buffer.buffer;
  }

  static ComplexStruct deserialize(ByteBuffer buffer) {
    final struct = ComplexStruct.create();
    final data = ByteData.view(buffer);
    var offset = 0;

    // Read id
    struct.id = data.getInt32(offset, Endian.host);
    offset += sizeOf<Int32>();

    // Read start point
    final startBuffer = ByteData(sizeOf<Point>());
    for (var i = 0; i < sizeOf<Point>(); i++) {
      startBuffer.setUint8(i, data.getUint8(offset + i));
    }
    struct.start = Point.deserialize(startBuffer.buffer);
    offset += sizeOf<Point>();

    // Read end point
    final endBuffer = ByteData(sizeOf<Point>());
    for (var i = 0; i < sizeOf<Point>(); i++) {
      endBuffer.setUint8(i, data.getUint8(offset + i));
    }
    struct.end = Point.deserialize(endBuffer.buffer);
    offset += sizeOf<Point>();

    // Read data array
    for (var i = 0; i < 10; i++) {
      struct.data[i] = data.getInt32(offset, Endian.host);
      offset += sizeOf<Int32>();
    }

    return struct;
  }
}

/// Helper for numeric array operations
extension Int32ArrayHelpers on Array<Int32> {
  ByteBuffer asBytes() {
    const size = 10; // Fixed size for now, can be made dynamic later
    final buffer = calloc<Int32>(size);
    for (var i = 0; i < size; i++) {
      buffer[i] = this[i];
    }
    final bytes = buffer.cast<Uint8>().asTypedList(size * sizeOf<Int32>());
    final result = bytes.buffer;
    calloc.free(buffer);
    return result;
  }
}

/// Alignment helper
int alignTo(int offset, int alignment) {
  return (offset + alignment - 1) & ~(alignment - 1);
}
