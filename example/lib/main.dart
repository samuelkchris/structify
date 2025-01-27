
import 'dart:ffi';
import 'dart:io';
import 'package:structify/structify.dart';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:structify/utils/alignment.dart';

void main() {
  stdout.write('Advanced Structify Features Demo\n');

  // 1. SIMD Vector Operations
  stdout.write('1. SIMD Vector Operations:');
  final vector = SimdVector.alloc();
  vector.ref.setValues([1.0, 2.0, 3.0, 4.0]);

  stdout.write('SIMD Vector values:');
  for (var i = 0; i < 4; i++) {
    stdout.write('  [$i]: ${vector.ref.values[i]}');
  }
  stdout.write('');

  // 2. Dynamic Aligned Array
  stdout.write('2. Dynamic Aligned Array Operations:');
  final array = DynamicAlignedArray.create(
    initialCapacity: 4,
    elementSize: sizeOf<Int32>(),
    alignment: 8,
  );

  // Add some integers (ensuring 8-byte alignment)
  for (var i = 0; i < 6; i++) {
    final value = calloc<Int32>()..value = i * 100;
    array.ref.add(value);
    calloc.free(value);
  }

  stdout.write('Array contents (capacity should auto-expand):');
  for (var i = 0; i < array.ref.length; i++) {
    final value = array.ref.at<Int32>(i).value;
    stdout.write('  [$i]: $value');
  }
  stdout.write('  Length: ${array.ref.length}, Capacity: ${array.ref.capacity}\n');

  // 3. Mixed Endianness Network Message
  stdout.write('3. Network Message with Mixed Endianness:');
  final msg = NetworkMessage.alloc();

  // Set fields with different endianness
  msg.ref.messageId = 0x12345678;    // Will be stored in network byte order
  msg.ref.flags = 0xAABBCCDD;        // Will be stored in host byte order
  msg.ref.timestamp = 0x1122334455667788;  // Will be stored in little-endian

  // Add some payload data
  final payload = Uint8List.fromList([0xDE, 0xAD, 0xBE, 0xEF]);
  msg.ref.setData(payload);

  stdout.write('Message ID (network order): 0x${msg.ref.messageId.toRadixString(16).padLeft(8, '0')}');
  stdout.write('Flags (host order): 0x${msg.ref.flags.toRadixString(16).padLeft(8, '0')}');
  stdout.write('Timestamp (little-endian): 0x${msg.ref.timestamp.toRadixString(16).padLeft(16, '0')}');
  stdout.write('Payload: ${msg.ref.getData().map((b) => '0x${b.toRadixString(16).padLeft(2, '0')}').join(', ')}\n');

  // 4. Memory Analysis
  stdout.write('4. Memory Layout Analysis:');
  stdout.write('SIMD Vector:');
  stdout.write('  Size: ${sizeOf<SimdVector>()} bytes');
  stdout.write('  Alignment: 16 bytes (optimized for SIMD)');
  stdout.write('  Data structure: 4 x Float32 (${4 * sizeOf<Float>()} bytes)');
  stdout.write('  Memory efficiency: ${(4 * sizeOf<Float>() / sizeOf<SimdVector>() * 100).toStringAsFixed(1)}%\n');

  stdout.write('Network Message:');
  stdout.write('  Size: ${sizeOf<NetworkMessage>()} bytes');
  analyzeNetworkMessageLayout();
  stdout.write('');

  // Cleanup
  SimdVector.free(vector);
  DynamicAlignedArray.free(array);
  NetworkMessage.free(msg);

  stdout.write('All resources cleaned up successfully!');
}

// Add at the end of the file

/// Analyze memory layout of NetworkMessage
void analyzeNetworkMessageLayout() {
  var offset = 0;

  // Message ID (4 bytes, network order)
  stdout.write('  MessageId offset: $offset bytes');
  offset += sizeOf<Int32>();

  // Flags (4 bytes, host order)
  offset = AlignmentUtils.alignOffset(offset, 4);
  stdout.write('  Flags offset: $offset bytes');
  offset += sizeOf<Int32>();

  // Timestamp (8 bytes, little-endian)
  offset = AlignmentUtils.alignOffset(offset, 8);
  stdout.write('  Timestamp offset: $offset bytes');
  offset += sizeOf<Int64>();

  // Data length (4 bytes, network order)
  offset = AlignmentUtils.alignOffset(offset, 4);
  stdout.write('  Data length offset: $offset bytes');
  offset += sizeOf<Int32>();

  // Pointer to data
  offset = AlignmentUtils.alignOffset(offset, sizeOf<Pointer<Uint8>>());
  stdout.write('  Data pointer offset: $offset bytes');
}