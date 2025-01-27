import 'dart:typed_data';
import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'alignment.dart';

/// Endianness specification for struct fields
enum StructEndian {
  /// Use platform native byte order
  host,

  /// Force little-endian byte order
  little,

  /// Force big-endian byte order
  big,

  /// Network byte order (big-endian)
  network;

  /// Convert to ByteData endian
  Endian toEndian() {
    switch (this) {
      case StructEndian.big:
      case StructEndian.network:
        return Endian.big;
      case StructEndian.little:
        return Endian.little;
      case StructEndian.host:
        return Endian.host;
    }
  }
}

/// Annotation for specifying field endianness
class ByteOrder {
  /// The endianness to be applied to the field
  final StructEndian endian;

  /// Constructs a [ByteOrder] annotation with the given endianness
  const ByteOrder(this.endian);
}

/// Extension methods for endian conversion
extension EndianConversion on ByteData {
  /// Read integer with specified endianness
  ///
  /// * [offset]: The offset to read from
  /// * [bytes]: The number of bytes to read
  /// * [endian]: The endianness to use
  /// Returns the integer value read
  int getIntAt(int offset, int bytes, StructEndian endian) {
    switch (bytes) {
      case 1:
        return getInt8(offset);
      case 2:
        return getInt16(offset, endian.toEndian());
      case 4:
        return getInt32(offset, endian.toEndian());
      case 8:
        return getInt64(offset, endian.toEndian());
      default:
        throw ArgumentError('Unsupported integer size: $bytes bytes');
    }
  }

  /// Write integer with specified endianness
  ///
  /// * [offset]: The offset to write to
  /// * [bytes]: The number of bytes to write
  /// * [value]: The integer value to write
  /// * [endian]: The endianness to use
  void setIntAt(int offset, int bytes, int value, StructEndian endian) {
    switch (bytes) {
      case 1:
        setInt8(offset, value);
        break;
      case 2:
        setInt16(offset, value, endian.toEndian());
        break;
      case 4:
        setInt32(offset, value, endian.toEndian());
        break;
      case 8:
        setInt64(offset, value, endian.toEndian());
        break;
      default:
        throw ArgumentError('Unsupported integer size: $bytes bytes');
    }
  }

  /// Read float with specified endianness
  ///
  /// * [offset]: The offset to read from
  /// * [bytes]: The number of bytes to read
  /// * [endian]: The endianness to use
  /// Returns the float value read
  double getFloatAt(int offset, int bytes, StructEndian endian) {
    switch (bytes) {
      case 4:
        return getFloat32(offset, endian.toEndian());
      case 8:
        return getFloat64(offset, endian.toEndian());
      default:
        throw ArgumentError('Unsupported float size: $bytes bytes');
    }
  }

  /// Write float with specified endianness
  ///
  /// * [offset]: The offset to write to
  /// * [bytes]: The number of bytes to write
  /// * [value]: The float value to write
  /// * [endian]: The endianness to use
  void setFloatAt(int offset, int bytes, double value, StructEndian endian) {
    switch (bytes) {
      case 4:
        setFloat32(offset, value, endian.toEndian());
        break;
      case 8:
        setFloat64(offset, value, endian.toEndian());
        break;
      default:
        throw ArgumentError('Unsupported float size: $bytes bytes');
    }
  }
}

/// Helper for endian conversion
class EndianUtils {
  /// Swap bytes for 16-bit value
  ///
  /// * [value]: The 16-bit value to swap bytes for
  /// Returns the value with swapped bytes
  static int swap16(int value) {
    return ((value & 0xFF) << 8) | ((value >> 8) & 0xFF);
  }

  /// Swap bytes for 32-bit value
  ///
  /// * [value]: The 32-bit value to swap bytes for
  /// Returns the value with swapped bytes
  static int swap32(int value) {
    return ((value & 0xFF) << 24) |
        ((value & 0xFF00) << 8) |
        ((value >> 8) & 0xFF00) |
        ((value >> 24) & 0xFF);
  }

  /// Swap bytes for 64-bit value
  ///
  /// * [value]: The 64-bit value to swap bytes for
  /// Returns the value with swapped bytes
  static int swap64(int value) {
    return ((value & 0xFF) << 56) |
        ((value & 0xFF00) << 40) |
        ((value & 0xFF0000) << 24) |
        ((value & 0xFF000000) << 8) |
        ((value >> 8) & 0xFF000000) |
        ((value >> 24) & 0xFF0000) |
        ((value >> 40) & 0xFF00) |
        ((value >> 56) & 0xFF);
  }

  /// Convert host to network byte order (if needed)
  ///
  /// * [value]: The 32-bit value to convert
  /// Returns the value in network byte order
  static int hostToNetwork32(int value) {
    return Endian.host == Endian.little ? swap32(value) : value;
  }

  /// Convert network to host byte order (if needed)
  ///
  /// * [value]: The 32-bit value to convert
  /// Returns the value in host byte order
  static int networkToHost32(int value) {
    return Endian.host == Endian.little ? swap32(value) : value;
  }
}

/// Example of a struct using alignment and endianness
final class NetworkPacket extends Struct {
  @Int32()
  @Aligned(StructAlignment.align4)
  @ByteOrder(StructEndian.network)
  external int messageType;

  @Int32()
  @Aligned(StructAlignment.align2)
  @ByteOrder(StructEndian.network)
  external int payloadLength;

  external Pointer<Uint8> payload;

  /// Allocates memory for a `NetworkPacket` instance
  ///
  /// Returns a pointer to the allocated memory
  static Pointer<NetworkPacket> alloc() {
    return calloc<NetworkPacket>();
  }

  /// Sets the payload data
  ///
  /// * [data]: The list of bytes to set as the payload
  void setPayload(List<int> data) {
    if (payload != nullptr) {
      calloc.free(payload);
    }
    payloadLength = data.length;
    payload = calloc<Uint8>(data.length);
    final buffer = payload.asTypedList(data.length);
    buffer.setAll(0, data);
  }

  /// Gets the payload data
  ///
  /// Returns a list of bytes representing the payload
  List<int> getPayload() {
    if (payload == nullptr || payloadLength == 0) return [];
    return payload.asTypedList(payloadLength).toList();
  }

  /// Cleanup resources
  void dispose() {
    if (payload != nullptr) {
      calloc.free(payload);
      payload = nullptr;
    }
  }

  /// Static dispose method for the pointer
  ///
  /// * [ptr]: The pointer to the `NetworkPacket` instance to free
  static void free(Pointer<NetworkPacket> ptr) {
    ptr.ref.dispose();
    calloc.free(ptr);
  }
}
