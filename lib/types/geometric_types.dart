import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:structify/core/base.dart';
import '../core/serialization.dart';

/// A circle struct with center point and radius
final class Circle extends Struct implements JsonSerializable, DebugPrintable {
  /// The center point of the circle
  external Point center;

  /// The radius of the circle
  @Float()
  external double radius;

  /// Allocates memory for a `Circle` instance.
  ///
  /// Returns a pointer to the allocated memory.
  static Pointer<Circle> alloc() {
    return calloc<Circle>();
  }

  /// Creates a `Circle` instance.
  ///
  /// Returns a reference to the allocated `Circle`.
  static Circle create() {
    return alloc().ref;
  }

  /// Converts the `Circle` to a JSON map.
  ///
  /// Returns a `Map<String, dynamic>` representing the JSON serialization of the circle.
  @override
  Map<String, dynamic> toJson() => {
        'center': {
          'x': center.x,
          'y': center.y,
        },
        'radius': radius,
      };

  /// Gets the size of the struct in bytes.
  ///
  /// Returns the size of the `Circle` struct in bytes.
  @override
  int get structSize => sizeOf<Circle>();

  /// Gets the debug fields for printing.
  ///
  /// Returns a `Map<String, dynamic>` containing the fields to be used for debug printing.
  @override
  Map<String, dynamic> get debugFields => {
        'center': '(${center.x}, ${center.y})',
        'radius': radius,
      };

  /// Gets the debug string representation of the `Circle`.
  ///
  /// Returns a `String` representing the debug information of the circle.
  @override
  String toString() {
    return 'Circle(center: (${center.x}, ${center.y}), radius: $radius)';
  }
}

/// A 3x3 matrix struct
final class Matrix3x3 extends Struct
    implements JsonSerializable, DebugPrintable {
  /// The values of the matrix
  @Array(9)
  external Array<Float> values;

  /// Allocates memory for a `Matrix3x3` instance.
  ///
  /// Returns a pointer to the allocated memory.
  static Pointer<Matrix3x3> alloc() {
    return calloc<Matrix3x3>();
  }

  /// Creates a `Matrix3x3` instance.
  ///
  /// Returns a reference to the allocated `Matrix3x3`.
  static Matrix3x3 create() {
    return alloc().ref;
  }

  /// Sets the value at the specified row and column.
  ///
  /// * [row]: The row index.
  /// * [col]: The column index.
  /// * [value]: The value to set.
  void set(int row, int col, double value) {
    values[row * 3 + col] = value;
  }

  /// Gets the value at the specified row and column.
  ///
  /// * [row]: The row index.
  /// * [col]: The column index.
  /// Returns the value at the specified row and column.
  double get(int row, int col) {
    return values[row * 3 + col];
  }

  /// Sets the matrix to the identity matrix.
  void setIdentity() {
    for (var i = 0; i < 9; i++) {
      values[i] = i % 4 == 0 ? 1.0 : 0.0;
    }
  }

  /// Converts the `Matrix3x3` to a JSON map.
  ///
  /// Returns a `Map<String, dynamic>` representing the JSON serialization of the matrix.
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

  /// Gets the size of the struct in bytes.
  ///
  /// Returns the size of the `Matrix3x3` struct in bytes.
  @override
  int get structSize => sizeOf<Matrix3x3>();

  /// Gets the rows of the matrix.
  ///
  /// Returns a list of lists representing the rows of the matrix.
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

  /// Gets the debug fields for printing.
  ///
  /// Returns a `Map<String, dynamic>` containing the fields to be used for debug printing.
  @override
  Map<String, dynamic> get debugFields {
    final rows = _getRows();
    return {
      'matrix': '[\n  ${rows.map((r) => r.join(', ')).join('\n  ')}\n]',
    };
  }

  /// Gets the debug string representation of the `Matrix3x3`.
  ///
  /// Returns a `String` representing the debug information of the matrix.
  @override
  String toString() {
    final rows = _getRows();
    return 'Matrix3x3:\n  ${rows.map((r) => r.join(', ')).join('\n  ')}';
  }
}