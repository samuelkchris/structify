import 'dart:ffi';
import 'dart:convert';
import 'package:ffi/ffi.dart';

/// Fixed-length string type for struct fields
final class StructString extends Struct {
  external Pointer<Uint8> data;
  @Int32()
  external int length;
  @Int32()
  external int capacity;

  // Helper to create fixed-size string
  static Pointer<StructString> create(int capacity) {
    final ptr = calloc<StructString>();
    ptr.ref.data = calloc<Uint8>(capacity);
    ptr.ref.capacity = capacity;
    ptr.ref.length = 0;
    return ptr;
  }

  // Set string value
  void setValue(String value) {
    final bytes = utf8.encode(value);
    if (bytes.length > capacity) {
      throw ArgumentError('String too long for capacity');
    }

    final list = data.asTypedList(capacity);
    list.fillRange(0, capacity, 0); // Clear existing data
    list.setAll(0, bytes);
    length = bytes.length;
  }

  // Get string value
  String getValue() {
    if (length == 0) return '';
    final bytes = data.asTypedList(length);
    return utf8.decode(bytes);
  }

  // Clean up allocated memory
  void dispose() {
    calloc.free(data);
  }
}

/// String array for struct fields
final class StructStringArray extends Struct {
  external Pointer<Pointer<Uint8>> data;
  @Int32()
  external int length;
  @Int32()
  external int capacity;
  @Int32()
  external int stringCapacity;

  // Create string array
  static Pointer<StructStringArray> create(
      int arrayCapacity, int stringCapacity) {
    final ptr = calloc<StructStringArray>();
    ptr.ref.data = calloc<Pointer<Uint8>>(arrayCapacity);
    ptr.ref.capacity = arrayCapacity;
    ptr.ref.stringCapacity = stringCapacity;
    ptr.ref.length = 0;

    // Initialize each string buffer
    for (var i = 0; i < arrayCapacity; i++) {
      ptr.ref.data[i] = calloc<Uint8>(stringCapacity);
    }

    return ptr;
  }

  // Set string at index
  void setString(int index, String value) {
    if (index >= capacity) {
      throw RangeError('Index out of bounds');
    }

    final bytes = utf8.encode(value);
    if (bytes.length > stringCapacity) {
      throw ArgumentError('String too long for capacity');
    }

    final buffer = data[index].asTypedList(stringCapacity);
    buffer.fillRange(0, stringCapacity, 0);
    buffer.setAll(0, bytes);

    if (index >= length) {
      length = index + 1;
    }
  }

  // Get string at index
  String getString(int index) {
    if (index >= length) {
      throw RangeError('Index out of bounds');
    }

    final buffer = data[index].asTypedList(stringCapacity);
    var end = 0;
    while (end < stringCapacity && buffer[end] != 0) {
      end++;
    }
    return utf8.decode(buffer.sublist(0, end));
  }

  // Clean up allocated memory
  void dispose() {
    for (var i = 0; i < capacity; i++) {
      calloc.free(data[i]);
    }
    calloc.free(data);
  }
}

/// Example usage struct
final class StringStruct extends Struct {
  external StructString name;
  external StructStringArray tags;

  static Pointer<StringStruct> create({
    int nameCapacity = 50,
    int tagsCapacity = 10,
    int tagStringCapacity = 20,
  }) {
    final ptr = calloc<StringStruct>();
    ptr.ref.name = StructString.create(nameCapacity).ref;
    ptr.ref.tags =
        StructStringArray.create(tagsCapacity, tagStringCapacity).ref;
    return ptr;
  }

  void dispose() {
    name.dispose();
    tags.dispose();
    calloc.free(this as Pointer<StringStruct>);
  }
}
