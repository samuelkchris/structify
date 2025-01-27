import 'package:ffi/ffi.dart';
import 'package:test/test.dart';
import 'package:structify/structify.dart';
import 'dart:ffi';

import 'test_helper.dart';

void main() {
  group('Performance Tests', () {
    const iterationCount = 10000;
    late PerformanceTest perfTest;

    setUp(() {
      perfTest = PerformanceTest('Struct Operations');
    });

    tearDown(() {
      perfTest.report();
    });

    test('Memory Pool Allocation Performance', () {
      const poolSize = 1000;
      final pool = PointPool(capacity: poolSize);

      perfTest.measure(() {
        final points = pool.allocateMany(poolSize);
        for (final ptr in points) {
          ptr.ref.x = 10;
          ptr.ref.y = 20;
        }
        pool.freeMany(points);
      });

      pool.dispose();
    });

    test('Point Struct Operations Performance', () {
      final scope = StructMemory.createScope();
      final points = <Pointer<Point>>[];

      // Setup
      for (var i = 0; i < 1000; i++) {
        points.add(scope.allocPoint());
      }

      perfTest.measure(() {
        for (var point in points) {
          point.ref.x = 100;
          point.ref.y = 200;
          final buffer = point.ref.serialize();
          final deserialized = Point.deserialize(buffer);
          expect(deserialized.x, equals(100));
          expect(deserialized.y, equals(200));
        }
      });

      scope.dispose();
    });

    test('SIMD Vector Operations Performance', () {
      final vectors = List.generate(
        100,
        (_) => SimdVector.alloc(),
      );

      perfTest.measure(() {
        for (var vector in vectors) {
          vector.ref.setValues([1.0, 2.0, 3.0, 4.0]);
          // Simulate SIMD operations
          for (var i = 0; i < 4; i++) {
            vector.ref.values[i] *= 2.0;
          }
        }
      });

      for (var vector in vectors) {
        SimdVector.free(vector);
      }
    });

    test('Dynamic Array Performance', () {
      final array = DynamicAlignedArray.create(
        initialCapacity: 1000,
        elementSize: sizeOf<Int32>(),
        alignment: 8,
      );

      perfTest.measure(() {
        for (var i = 0; i < iterationCount; i++) {
          final value = calloc<Int32>()..value = i;
          array.ref.add(value);
          calloc.free(value);
        }
      });

      DynamicAlignedArray.free(array);
    });

    test('String Operations Performance', () {
      final strings = List.generate(
        100,
        (_) => StructString.create(50),
      );

      perfTest.measure(() {
        for (var str in strings) {
          str.ref.setValue("This is a test string for performance measurement");
          final value = str.ref.getValue();
          expect(value.length, greaterThan(0));
        }
      });

      for (var str in strings) {
        str.ref.dispose();
      }
    });

    test('Memory Management Performance', () {
      perfTest.measure(() {
        for (var i = 0; i < iterationCount ~/ 100; i++) {
          withScope((scope) {
            final points = List.generate(
                100,
                (j) => scope.allocPoint()
                  ..ref.x = j
                  ..ref.y = j * 2);

            // Perform some operations
            for (var point in points) {
              point.ref.x += 1;
              point.ref.y += 1;
            }
          });
        }
      });
    });
  });
}
