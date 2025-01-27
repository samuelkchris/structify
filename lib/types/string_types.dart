import 'dart:ffi';
import 'dart:convert';
import 'package:ffi/ffi.dart';

/// Represents a fixed-length string type for struct fields.
final class StructString extends Struct {
  /// Pointer to the data of the string.
  external Pointer<Uint8> data;

  /// The length of the string.
  @Int32()
  external int length;

  /// The capacity of the string.
  @Int32()
  external int capacity;

  /// Creates a new `StructString` with the given capacity.
  ///
  /// Allocates memory for the string and initializes its fields.
  ///
  /// @param capacity The capacity of the string.
  /// @return A pointer to the newly created `StructString`.
  static Pointer<StructString> create(int capacity) {
    final ptr = calloc<StructString>();
    ptr.ref.data = calloc<Uint8>(capacity);
    ptr.ref.capacity = capacity;
    ptr.ref.length = 0;
    return ptr;
  }

  /// Sets the value of the string.
  ///
  /// Encodes the given string to UTF-8 and stores it in the allocated memory.
  ///
  /// @param value The string value to set.
  /// @throws ArgumentError if the string is too long for the capacity.
  void setValue(String value) {
    final bytes = utf8.encode(value);
    if (bytes.length > capacity) {
      throw ArgumentError('String too long for capacity');
    }

    final list = data.asTypedList(capacity);
    list.fillRange(0, capacity, 0);
    list.setAll(0, bytes);
    length = bytes.length;
  }

  /// Gets the value of the string.
  ///
  /// Decodes the stored UTF-8 bytes to a Dart string.
  ///
  /// @return The string value.
  String getValue() {
    if (length == 0) return '';
    final bytes = data.asTypedList(length);
    return utf8.decode(bytes);
  }

  /// Disposes the allocated memory for the string.
  void dispose() {
    if (data != nullptr) {
      calloc.free(data);
      data = nullptr;
    }
  }
}

/// Represents a string array for struct fields.
final class StructStringArray extends Struct {
  /// Pointer to the array of string data pointers.
  external Pointer<Pointer<Uint8>> data;

  /// The length of the string array.
  @Int32()
  external int length;

  /// The capacity of the string array.
  @Int32()
  external int capacity;

  /// The capacity of each string in the array.
  @Int32()
  external int stringCapacity;

  /// Creates a new `StructStringArray` with the given capacities.
  ///
  /// Allocates memory for the array and initializes its fields.
  ///
  /// @param arrayCapacity The capacity of the string array.
  /// @param stringCapacity The capacity of each string in the array.
  /// @return A pointer to the newly created `StructStringArray`.
  static Pointer<StructStringArray> create(int arrayCapacity, int stringCapacity) {
    final ptr = calloc<StructStringArray>();
    ptr.ref.data = calloc<Pointer<Uint8>>(arrayCapacity);
    ptr.ref.capacity = arrayCapacity;
    ptr.ref.stringCapacity = stringCapacity;
    ptr.ref.length = 0;

    for (var i = 0; i < arrayCapacity; i++) {
      ptr.ref.data[i] = calloc<Uint8>(stringCapacity);
    }

    return ptr;
  }

  /// Sets the string value at the specified index.
  ///
  /// Encodes the given string to UTF-8 and stores it in the allocated memory.
  ///
  /// @param index The index at which to set the string.
  /// @param value The string value to set.
  /// @throws RangeError if the index is out of bounds.
  /// @throws ArgumentError if the string is too long for the capacity.
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

  /// Gets the string value at the specified index.
  ///
  /// Decodes the stored UTF-8 bytes to a Dart string.
  ///
  /// @param index The index from which to get the string.
  /// @return The string value.
  /// @throws RangeError if the index is out of bounds.
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

  /// Disposes the allocated memory for the string array.
  void dispose() {
    if (data != nullptr) {
      for (var i = 0; i < capacity; i++) {
        calloc.free(data[i]);
      }
      calloc.free(data);
      data = nullptr;
    }
  }
}

/// Represents an example usage struct containing a string and a string array.
final class StringStruct extends Struct {
  /// The name field as a `StructString`.
  external StructString name;

  /// The tags field as a `StructStringArray`.
  external StructStringArray tags;

  /// Creates a new `StringStruct` with the given capacities.
  ///
  /// Allocates memory for the struct and initializes its fields.
  ///
  /// @param nameCapacity The capacity of the name string.
  /// @param tagsCapacity The capacity of the tags array.
  /// @param tagStringCapacity The capacity of each string in the tags array.
  /// @return A pointer to the newly created `StringStruct`.
  static Pointer<StringStruct> create({
    int nameCapacity = 50,
    int tagsCapacity = 10,
    int tagStringCapacity = 20,
  }) {
    final ptr = calloc<StringStruct>();
    ptr.ref.name = StructString.create(nameCapacity).ref;
    ptr.ref.tags = StructStringArray.create(tagsCapacity, tagStringCapacity).ref;
    return ptr;
  }

  /// Disposes the allocated memory for the struct.
  void dispose() {
    name.dispose();
    tags.dispose();
  }
}