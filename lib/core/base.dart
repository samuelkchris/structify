
import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:structify/core/serialization.dart';

/// Main annotation for specifying struct field properties
class StructField {
  final int offset;
  final int size;
  final bool packed;

  const StructField(this.offset, {this.size = 1, this.packed = false});
}

/// Size annotation for specifying dynamic array sizes
class Size {
  final int size;
  const Size([this.size = 0]);
}

/// Example struct implementation showing basic usage
final class Point extends Struct implements DebugPrintable {
  @Int32()
  external int x;

  @Int32()
  external int y;

  /// Create a new Point struct
  static Pointer<Point> alloc() {
    return calloc<Point>();
  }

  static Point create() {
    return alloc().ref;
  }

  ByteBuffer serialize() {
    final buffer = ByteData(sizeOf<Point>());
    buffer.setInt32(0, x, Endian.host);
    buffer.setInt32(4, y, Endian.host);
    return buffer.buffer;
  }

  static Point deserialize(ByteBuffer buffer) {
    final point = Point.create();
    final data = ByteData.view(buffer);
    point.x = data.getInt32(0, Endian.host);
    point.y = data.getInt32(4, Endian.host);
    return point;
  }

  @override
  int get structSize => sizeOf<Point>();

  @override
  Map<String, dynamic> get debugFields => {
    'x': x,
    'y': y,
  };

  @override
  String toString() {
    return 'Point(x: $x, y: $y)';
  }
}

/// Example of a packed struct with no padding
@Packed(1)
final class PackedPoint extends Struct {
  @Int32()
  external int x;

  @Int32()
  external int y;

  /// Create a new PackedPoint struct
  static Pointer<PackedPoint> alloc() {
    return calloc<PackedPoint>();
  }

  static PackedPoint create() {
    return alloc().ref;
  }

  ByteBuffer serialize() {
    final buffer = ByteData(sizeOf<PackedPoint>());
    buffer.setInt32(0, x, Endian.host);
    buffer.setInt32(4, y, Endian.host);
    return buffer.buffer;
  }

  static PackedPoint deserialize(ByteBuffer buffer) {
    final point = PackedPoint.create();
    final data = ByteData.view(buffer);
    point.x = data.getInt32(0, Endian.host);
    point.y = data.getInt32(4, Endian.host);
    return point;
  }
}

/// Example of a struct with arrays
final class Rectangle extends Struct {
  @Array(4)
  external Array<Int32> points;

  /// Create a new Rectangle struct
  static Pointer<Rectangle> alloc() {
    return calloc<Rectangle>();
  }

  static Rectangle create() {
    return alloc().ref;
  }

  void setPoints(int x1, int y1, int x2, int y2) {
    points[0] = x1;
    points[1] = y1;
    points[2] = x2;
    points[3] = y2;
  }

  ByteBuffer serialize() {
    final buffer = ByteData(sizeOf<Rectangle>());
    for (var i = 0; i < 4; i++) {
      buffer.setInt32(i * 4, points[i], Endian.host);
    }
    return buffer.buffer;
  }

  static Rectangle deserialize(ByteBuffer buffer) {
    final rect = Rectangle.create();
    final data = ByteData.view(buffer);
    for (var i = 0; i < 4; i++) {
      rect.points[i] = data.getInt32(i * 4, Endian.host);
    }
    return rect;
  }
}

/// Memory management utilities
class StructAlloc {
  /// Free memory for struct
  static void free<T extends Struct>(Pointer<T> pointer) {
    calloc.free(pointer);
  }
}