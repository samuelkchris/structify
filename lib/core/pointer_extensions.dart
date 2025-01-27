
import 'dart:ffi';

import 'package:structify/core/base.dart';

/// Extension for batch point operations
extension PointBatchExt on List<Pointer<Point>> {
  /// Apply function to each point
  void forEach(void Function(Point point) fn) {
    for (final ptr in this) {
      fn(ptr.ref);
    }
  }

  /// Print all points
  void printAll() {
    for (var i = 0; i < length; i++) {
      print('[$i]: ${this[i].ref}');
    }
  }

  /// Set all points to specific values
  void setAll(int x, int y) {
    forEach((point) {
      point.x = x;
      point.y = y;
    });
  }

  /// Reset all points to origin
  void reset() {
    setAll(0, 0);
  }

  /// Scale all points by a factor
  void scale(double factor) {
    forEach((point) {
      point.x = (point.x * factor).toInt();
      point.y = (point.y * factor).toInt();
    });
  }

  /// Translate all points by dx, dy
  void translate(int dx, int dy) {
    forEach((point) {
      point.x += dx;
      point.y += dy;
    });
  }
}