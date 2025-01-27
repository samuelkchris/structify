import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:structify/core/base.dart';
import '../core/serialization.dart';

/// A circle struct with center point and radius
final class Circle extends Struct implements JsonSerializable, DebugPrintable {
  external Point center;

  @Float()
  external double radius;

  static Pointer<Circle> alloc() {
    return calloc<Circle>();
  }

  static Circle create() {
    return alloc().ref;
  }

  @override
  Map<String, dynamic> toJson() => {
        'center': {
          'x': center.x,
          'y': center.y,
        },
        'radius': radius,
      };

  @override
  int get structSize => sizeOf<Circle>();

  @override
  Map<String, dynamic> get debugFields => {
        'center': '(${center.x}, ${center.y})',
        'radius': radius,
      };

  @override
  String toString() {
    return 'Circle(center: (${center.x}, ${center.y}), radius: $radius)';
  }
}

/// A 3x3 matrix struct
final class Matrix3x3 extends Struct
    implements JsonSerializable, DebugPrintable {
  @Array(9)
  external Array<Float> values;

  static Pointer<Matrix3x3> alloc() {
    return calloc<Matrix3x3>();
  }

  static Matrix3x3 create() {
    return alloc().ref;
  }

  void set(int row, int col, double value) {
    values[row * 3 + col] = value;
  }

  double get(int row, int col) {
    return values[row * 3 + col];
  }

  void setIdentity() {
    for (var i = 0; i < 9; i++) {
      values[i] = i % 4 == 0 ? 1.0 : 0.0;
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final result = <String, List<double>>{
      'values': [],
    };
    for (var i = 0; i < 9; i++) {
      result['values']!.add(values[i]);
    }
    return result;
  }

  @override
  int get structSize => sizeOf<Matrix3x3>();

  List<List<double>> _getRows() {
    final rows = <List<double>>[];
    for (var i = 0; i < 3; i++) {
      rows.add([
        values[i * 3],
        values[i * 3 + 1],
        values[i * 3 + 2],
      ]);
    }
    return rows;
  }

  @override
  Map<String, dynamic> get debugFields {
    final rows = _getRows();
    return {
      'matrix': '[\n  ${rows.map((r) => r.join(', ')).join('\n  ')}\n]',
    };
  }

  @override
  String toString() {
    final rows = _getRows();
    return 'Matrix3x3:\n  ${rows.map((r) => r.join(', ')).join('\n  ')}';
  }
}
