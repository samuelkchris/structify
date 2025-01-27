import 'dart:typed_data';
import '../core/base.dart';

/// Wire types for Protocol Buffer encoding
enum WireType {
  varint(0),
  fixed64(1),
  lengthDelimited(2),
  fixed32(5);

  /// The integer value representing the wire type.
  final int value;

  /// Constructs a [WireType] with the given value.
  const WireType(this.value);
}

/// Protocol Buffer field descriptor
class ProtoField {
  /// The field number.
  final int number;

  /// The wire type of the field.
  final WireType wireType;

  /// The name of the field.
  final String name;

  /// Constructs a [ProtoField] with the given number, wire type, and name.
  const ProtoField(this.number, this.wireType, this.name);
}

/// Protocol Buffer serialization interface
abstract interface class ProtobufSerializable {
  /// Get field descriptors for the struct.
  List<ProtoField> get protoFields;

  /// Calculate size needed for serialization.
  int calculateSize();

  /// Serialize to Protocol Buffer format.
  ByteBuffer serializeToProto();

  /// Deserialize from Protocol Buffer format.
  void deserializeFromProto(ByteBuffer buffer);
}

/// Protocol Buffer utility functions
mixin ProtobufUtils {
  /// Encode field number and wire type.
  ///
  /// * [fieldNumber]: The field number.
  /// * [wireType]: The wire type.
  /// Returns the encoded tag.
  int makeTag(int fieldNumber, WireType wireType) {
    return (fieldNumber << 3) | wireType.value;
  }

  /// Encode variable-length integer.
  ///
  /// * [buffer]: The buffer to write to.
  /// * [offset]: The offset to start writing at.
  /// * [value]: The value to encode.
  void writeVarint(ByteData buffer, int offset, int value) {
    var current = value;
    var currentOffset = offset;

    while (current > 0x7F) {
      buffer.setUint8(currentOffset, (current & 0x7F) | 0x80);
      current >>= 7;
      currentOffset++;
    }
    buffer.setUint8(currentOffset, current & 0x7F);
  }

  /// Write length-delimited field.
  ///
  /// * [buffer]: The buffer to write to.
  /// * [offset]: The offset to start writing at.
  /// * [bytes]: The bytes to write.
  /// Returns the number of bytes written.
  int writeLengthDelimited(ByteData buffer, int offset, List<int> bytes) {
    writeVarint(buffer, offset, bytes.length);
    var currentOffset = offset + 1;

    for (var byte in bytes) {
      buffer.setUint8(currentOffset++, byte);
    }

    return currentOffset - offset;
  }
}

/// Extension to add Protocol Buffer support to Point
extension PointProtobuf on Point {
  /// Field descriptor for the x-coordinate.
  static const xField = ProtoField(1, WireType.fixed32, 'x');

  /// Field descriptor for the y-coordinate.
  static const yField = ProtoField(2, WireType.fixed32, 'y');

  /// Get field descriptors for the Point struct.
  List<ProtoField> get protoFields => [xField, yField];

  /// Calculate size needed for serialization.
  ///
  /// Returns the size in bytes.
  int calculateSize() =>
      2 * (1 + 4); // 2 fields, each with 1 byte tag and 4 bytes data

  /// Encode field number and wire type.
  ///
  /// * [fieldNumber]: The field number.
  /// * [wireType]: The wire type.
  /// Returns the encoded tag.
  int _makeTag(int fieldNumber, WireType wireType) {
    return (fieldNumber << 3) | wireType.value;
  }

  /// Serialize the Point to Protocol Buffer format.
  ///
  /// Returns a [ByteBuffer] containing the serialized data.
  ByteBuffer serializeToProto() {
    const size = 2 * (1 + 4); // 2 fields, each with 1 byte tag and 4 bytes data
    final buffer = ByteData(size);

    // Write x field
    buffer.setUint8(0, _makeTag(xField.number, xField.wireType));
    buffer.setInt32(1, x, Endian.little);

    // Write y field
    buffer.setUint8(5, _makeTag(yField.number, yField.wireType));
    buffer.setInt32(6, y, Endian.little);

    return buffer.buffer;
  }

  /// Deserialize the Point from Protocol Buffer format.
  ///
  /// * [buffer]: The [ByteBuffer] containing the serialized data.
  void deserializeFromProto(ByteBuffer buffer) {
    final data = ByteData.view(buffer);

    // Read x field
    if (data.getUint8(0) == _makeTag(xField.number, xField.wireType)) {
      x = data.getInt32(1, Endian.little);
    }

    // Read y field
    if (data.getUint8(5) == _makeTag(yField.number, yField.wireType)) {
      y = data.getInt32(6, Endian.little);
    }
  }
}
