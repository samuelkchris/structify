
import 'dart:ffi';
import 'package:structify/structify.dart';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:structify/utils/alignment.dart';

void main() {
  print('Advanced Structify Features Demo\n');

  // 1. SIMD Vector Operations
  print('1. SIMD Vector Operations:');
  final vector = SimdVector.alloc();
  vector.ref.setValues([1.0, 2.0, 3.0, 4.0]);

  print('SIMD Vector values:');
  for (var i = 0; i < 4; i++) {
    print('  [${i}]: ${vector.ref.values[i]}');
  }
  print('');

  // 2. Dynamic Aligned Array
  print('2. Dynamic Aligned Array Operations:');
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

  print('Array contents (capacity should auto-expand):');
  for (var i = 0; i < array.ref.length; i++) {
    final value = array.ref.at<Int32>(i).value;
    print('  [${i}]: $value');
  }
  print('  Length: ${array.ref.length}, Capacity: ${array.ref.capacity}\n');

  // 3. Mixed Endianness Network Message
  print('3. Network Message with Mixed Endianness:');
  final msg = NetworkMessage.alloc();

  // Set fields with different endianness
  msg.ref.messageId = 0x12345678;    // Will be stored in network byte order
  msg.ref.flags = 0xAABBCCDD;        // Will be stored in host byte order
  msg.ref.timestamp = 0x1122334455667788;  // Will be stored in little-endian

  // Add some payload data
  final payload = Uint8List.fromList([0xDE, 0xAD, 0xBE, 0xEF]);
  msg.ref.setData(payload);

  print('Message ID (network order): 0x${msg.ref.messageId.toRadixString(16).padLeft(8, '0')}');
  print('Flags (host order): 0x${msg.ref.flags.toRadixString(16).padLeft(8, '0')}');
  print('Timestamp (little-endian): 0x${msg.ref.timestamp.toRadixString(16).padLeft(16, '0')}');
  print('Payload: ${msg.ref.getData().map((b) => '0x${b.toRadixString(16).padLeft(2, '0')}').join(', ')}\n');

  // 4. Memory Analysis
  print('4. Memory Layout Analysis:');
  print('SIMD Vector:');
  print('  Size: ${sizeOf<SimdVector>()} bytes');
  print('  Alignment: 16 bytes (optimized for SIMD)');
  print('  Data structure: 4 x Float32 (${4 * sizeOf<Float>()} bytes)');
  print('  Memory efficiency: ${(4 * sizeOf<Float>() / sizeOf<SimdVector>() * 100).toStringAsFixed(1)}%\n');

  print('Network Message:');
  print('  Size: ${sizeOf<NetworkMessage>()} bytes');
  analyzeNetworkMessageLayout();
  print('');

  // Cleanup
  SimdVector.free(vector);
  DynamicAlignedArray.free(array);
  NetworkMessage.free(msg);

  print('All resources cleaned up successfully!');
}

// Add at the end of the file

/// Analyze memory layout of NetworkMessage
void analyzeNetworkMessageLayout() {
  var offset = 0;

  // Message ID (4 bytes, network order)
  print('  MessageId offset: $offset bytes');
  offset += sizeOf<Int32>();

  // Flags (4 bytes, host order)
  offset = AlignmentUtils.alignOffset(offset, 4);
  print('  Flags offset: $offset bytes');
  offset += sizeOf<Int32>();

  // Timestamp (8 bytes, little-endian)
  offset = AlignmentUtils.alignOffset(offset, 8);
  print('  Timestamp offset: $offset bytes');
  offset += sizeOf<Int64>();

  // Data length (4 bytes, network order)
  offset = AlignmentUtils.alignOffset(offset, 4);
  print('  Data length offset: $offset bytes');
  offset += sizeOf<Int32>();

  // Pointer to data
  offset = AlignmentUtils.alignOffset(offset, sizeOf<Pointer<Uint8>>());
  print('  Data pointer offset: $offset bytes');
}