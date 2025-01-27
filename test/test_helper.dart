import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:structify/structify.dart';

/// Helper to create a temporary scope for tests
T withScope<T>(T Function(StructScope scope) fn) {
  final scope = StructMemory.createScope();
  try {
    return fn(scope);
  } finally {
    scope.dispose();
  }
}

/// Helper to verify memory alignment
void verifyAlignment(Pointer<NativeType> pointer, int alignment) {
  expect(
    pointer.address % alignment,
    equals(0),
    reason: 'Pointer 0x${pointer.address.toRadixString(16)} '
        'is not aligned to $alignment bytes',
  );
}

/// Helper to check if a struct is properly packed
void verifyPacked(int actualSize, int expectedSize) {
  expect(
    actualSize,
    equals(expectedSize),
    reason: 'Struct should be packed to $expectedSize bytes, '
        'but got $actualSize bytes',
  );
}

/// Helper to generate test data of specified size
List<int> generateTestData(int size) {
  return List.generate(size, (i) => i % 256);
}

/// Helper to compare byte arrays
void compareBytes(List<int> actual, List<int> expected) {
  expect(actual.length, equals(expected.length),
      reason: 'Byte array lengths differ');

  for (var i = 0; i < actual.length; i++) {
    expect(actual[i], equals(expected[i]),
        reason: 'Byte arrays differ at index $i');
  }
}

/// Helper to verify endianness conversion
List<int> verifyEndianness(int value, StructEndian endian) {
  final buffer = ByteData(4);

  if (endian == StructEndian.big || endian == StructEndian.network) {
    buffer.setInt32(0, value, Endian.big);
  } else {
    buffer.setInt32(0, value, Endian.little);
  }

  return buffer.buffer.asUint8List().toList();
}

/// Helper for memory leak detection
class MemoryLeakDetector {
  final List<Pointer<NativeType>> _allocations = [];

  void trackAllocation(Pointer<NativeType> ptr) {
    _allocations.add(ptr);
  }

  void forgetAllocation(Pointer<NativeType> ptr) {
    _allocations.remove(ptr);
  }

  void verifyNoLeaks() {
    if (_allocations.isNotEmpty) {
      final addresses = _allocations
          .map((p) => '0x${p.address.toRadixString(16)}')
          .join(', ');
      fail('Memory leak detected: $addresses');
    }
  }
}

/// Helper for performance testing
class PerformanceTest {
  final String name;
  final Stopwatch _stopwatch = Stopwatch();
  final List<Duration> _measurements = [];

  PerformanceTest(this.name);

  void measure(void Function() fn) {
    _stopwatch.start();
    fn();
    _stopwatch.stop();
    _measurements.add(_stopwatch.elapsed);
    _stopwatch.reset();
  }

  void report() {
    if (_measurements.isEmpty) return;

    final avg = _measurements.reduce((a, b) => a + b) ~/ _measurements.length;
    final max = _measurements.reduce((a, b) => a > b ? a : b);
    final min = _measurements.reduce((a, b) => a < b ? a : b);

    stdout.write('\nPerformance test: $name');
    stdout.write('  Average: ${avg.inMicroseconds}µs');
    stdout.write('  Min: ${min.inMicroseconds}µs');
    stdout.write('  Max: ${max.inMicroseconds}µs');
    stdout.write('  Samples: ${_measurements.length}');
  }
}