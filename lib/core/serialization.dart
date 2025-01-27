/// Base interface for structs that can be serialized to JSON
abstract class JsonSerializable {
  /// Convert to JSON Map
  ///
  /// Returns a `Map<String, dynamic>` representing the JSON serialization of the struct.
  Map<String, dynamic> toJson();
}

/// Base interface for structs that support debug printing
abstract class DebugPrintable {
  /// Get struct size in bytes
  ///
  /// Returns the size of the struct in bytes.
  int get structSize;

  /// Get debug fields for printing
  ///
  /// Returns a `Map<String, dynamic>` containing the fields to be used for debug printing.
  Map<String, dynamic> get debugFields;

  /// Get debug string representation
  ///
  /// Returns a `String` representing the debug information of the struct.
  @override
  String toString() {
    final fields =
        debugFields.entries.map((e) => '${e.key}: ${e.value}').join(', ');
    return '$runtimeType(size: $structSize bytes, $fields)';
  }
}
