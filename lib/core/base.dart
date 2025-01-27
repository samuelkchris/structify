import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:structify/core/serialization.dart';

/// Main annotation for specifying struct field properties
class StructField {
  final int offset;
  final int size;
  final bool packed;

  /// Constructs a [StructField] annotation.
  ///
  /// * [offset]: The offset of the field within the struct.
  /// * [size]: The size of the field. Defaults to 1.
  /// * [packed]: Whether the field is packed. Defaults to false.
  const StructField(this.offset, {this.size = 1, this.packed = false});
}

/// Size annotation for specifying dynamic array sizes
class Size {
  final int size;

  /// Constructs a [Size] annotation.
  ///
  /// * [size]: The size of the array. Defaults to 0.
  const Size([this.size = 0]);
}

/// Example struct implementation showing basic usage
final class Point extends Struct implements DebugPrintable {
  @Int32()
  external int x;

  @Int32()
  external int y;

  /// Allocates memory for a new [Point] struct.
  static Pointer<Point> alloc() {
    return calloc<Point>();
  }

  /// Creates a new [Point] instance.
  static Point create() {
    return alloc().ref;
  }

  /// Serializes the [Point] struct to a [ByteBuffer].
  ByteBuffer serialize() {
    final buffer = ByteData(sizeOf<Point>());
    buffer.setInt32(0, x, Endian.host);
    buffer.setInt32(4, y, Endian.host);
    return buffer.buffer;
  }

  /// Deserializes a [ByteBuffer] to a [Point] struct.
  ///
  /// * [buffer]: The buffer containing the serialized data.
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

  /// Allocates memory for a new [PackedPoint] struct.
  static Pointer<PackedPoint> alloc() {
    return calloc<PackedPoint>();
  }

  /// Creates a new [PackedPoint] instance.
  static PackedPoint create() {
    return alloc().ref;
  }

  /// Serializes the [PackedPoint] struct to a [ByteBuffer].
  ByteBuffer serialize() {
    final buffer = ByteData(sizeOf<PackedPoint>());
    buffer.setInt32(0, x, Endian.host);
    buffer.setInt32(4, y, Endian.host);
    return buffer.buffer;
  }

  /// Deserializes a [ByteBuffer] to a [PackedPoint] struct.
  ///
  /// * [buffer]: The buffer containing the serialized data.
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

  /// Allocates memory for a new [Rectangle] struct.
  static Pointer<Rectangle> alloc() {
    return calloc<Rectangle>();
  }

  /// Creates a new [Rectangle] instance.
  static Rectangle create() {
    return alloc().ref;
  }

  /// Sets the points of the [Rectangle] struct.
  ///
  /// * [x1], [y1], [x2], [y2]: The coordinates of the points.
  void setPoints(int x1, int y1, int x2, int y2) {
    points[0] = x1;
    points[1] = y1;
    points[2] = x2;
    points[3] = y2;
  }

  /// Serializes the [Rectangle] struct to a [ByteBuffer].
  ByteBuffer serialize() {
    final buffer = ByteData(sizeOf<Rectangle>());
    for (var i = 0; i < 4; i++) {
      buffer.setInt32(i * 4, points[i], Endian.host);
    }
    return buffer.buffer;
  }

  /// Deserializes a [ByteBuffer] to a [Rectangle] struct.
  ///
  /// * [buffer]: The buffer containing the serialized data.
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
  /// Frees memory allocated for a struct.
  ///
  /// * [pointer]: The pointer to the allocated memory.
  static void free<T extends Struct>(Pointer<T> pointer) {
    calloc.free(pointer);
  }
}
