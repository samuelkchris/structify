
/// Base interface for structs that can be serialized to JSON
abstract class JsonSerializable {
  /// Convert to JSON Map
  Map<String, dynamic> toJson();
}

/// Base interface for structs that support debug printing
abstract class DebugPrintable {
  /// Get struct size in bytes
  int get structSize;

  /// Get debug fields for printing
  Map<String, dynamic> get debugFields;

  /// Get debug string representation
  @override
  String toString() {
    final fields = debugFields.entries.map((e) => '${e.key}: ${e.value}').join(', ');
    return '$runtimeType(size: $structSize bytes, $fields)';
  }
}