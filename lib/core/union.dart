import 'dart:ffi';
import 'package:ffi/ffi.dart';

/// Example union showing multiple ways to interpret the same memory
final class DataUnion extends Union {
  @Int32()
  external int asInt32;

  @Float()
  external double asFloat;

  @Int64()
  external int asInt64;

  @Array(4)
  external Array<Uint8> asBytes;

  /// Allocates memory for a `DataUnion` instance.
  ///
  /// Returns a pointer to the allocated memory.
  static Pointer<DataUnion> alloc() {
    return calloc<DataUnion>();
  }

  /// Creates a `DataUnion` instance.
  ///
  /// Returns a reference to the allocated `DataUnion`.
  static DataUnion create() {
    return alloc().ref;
  }
}

/// Example of a struct containing a union
final class TaggedUnion extends Struct {
  @Int32()
  external int tag;

  external DataUnion data;

  /// Allocates memory for a `TaggedUnion` instance.
  ///
  /// Returns a pointer to the allocated memory.
  static Pointer<TaggedUnion> alloc() {
    return calloc<TaggedUnion>();
  }

  /// Creates a `TaggedUnion` instance.
  ///
  /// Returns a reference to the allocated `TaggedUnion`.
  static TaggedUnion create() {
    return alloc().ref;
  }

  /// Sets the union to interpret the value as an integer.
  ///
  /// * [value]: The integer value to set.
  void setInt(int value) {
    tag = 0;
    data.asInt32 = value;
  }

  /// Sets the union to interpret the value as a float.
  ///
  /// * [value]: The float value to set.
  void setFloat(double value) {
    tag = 1;
    data.asFloat = value;
  }

  /// Sets the union to interpret the value as a 64-bit integer.
  ///
  /// * [value]: The 64-bit integer value to set.
  void setInt64(int value) {
    tag = 2;
    data.asInt64 = value;
  }

  /// Retrieves the value based on the current tag.
  ///
  /// Returns the value as an integer, float, or 64-bit integer based on the tag.
  /// Throws a `StateError` if the tag value is invalid.
  dynamic getValue() {
    switch (tag) {
      case 0:
        return data.asInt32;
      case 1:
        return data.asFloat;
      case 2:
        return data.asInt64;
      default:
        throw StateError('Invalid tag value: $tag');
    }
  }
}
