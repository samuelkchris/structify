import 'dart:ffi';
import 'dart:io';
import 'package:structify/core/base.dart';

/// Extension for batch operations on a list of [Pointer<Point>]
extension PointBatchExt on List<Pointer<Point>> {
  /// Applies a function to each [Point] in the list.
  ///
  /// * [fn]: The function to apply to each [Point].
  void forEach(void Function(Point point) fn) {
    for (final ptr in this) {
      fn(ptr.ref);
    }
  }

  /// Prints all points in the list.
  void printAll() {
    for (var i = 0; i < length; i++) {

      stdout.write('[$i]: ${this[i].ref}');

    }
  }

  /// Sets all points in the list to specific values.
  ///
  /// * [x]: The x-coordinate to set.
  /// * [y]: The y-coordinate to set.
  void setAll(int x, int y) {
    forEach((point) {
      point.x = x;
      point.y = y;
    });
  }

  /// Resets all points in the list to the origin (0, 0).
  void reset() {
    setAll(0, 0);
  }

  /// Scales all points in the list by a factor.
  ///
  /// * [factor]: The factor by which to scale the points.
  void scale(double factor) {
    forEach((point) {
      point.x = (point.x * factor).toInt();
      point.y = (point.y * factor).toInt();
    });
  }

  /// Translates all points in the list by dx and dy.
  ///
  /// * [dx]: The amount to translate in the x-direction.
  /// * [dy]: The amount to translate in the y-direction.
  void translate(int dx, int dy) {
    forEach((point) {
      point.x += dx;
      point.y += dy;
    });
  }
}
