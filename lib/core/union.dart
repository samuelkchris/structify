
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

  static Pointer<DataUnion> alloc() {
    return calloc<DataUnion>();
  }

  static DataUnion create() {
    return alloc().ref;
  }
}

/// Example of a struct containing a union
final class TaggedUnion extends Struct {
  @Int32()
  external int tag;

  external DataUnion data;

  static Pointer<TaggedUnion> alloc() {
    return calloc<TaggedUnion>();
  }

  static TaggedUnion create() {
    return alloc().ref;
  }

  void setInt(int value) {
    tag = 0;
    data.asInt32 = value;
  }

  void setFloat(double value) {
    tag = 1;
    data.asFloat = value;
  }

  void setInt64(int value) {
    tag = 2;
    data.asInt64 = value;
  }

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