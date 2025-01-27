import 'package:ffi/ffi.dart';
import 'package:structify/core/safety.dart';
import 'package:test/test.dart';
import 'package:structify/structify.dart';
import 'dart:ffi';

void main() {
  group('StructScope Tests', () {
    late StructScope scope;

    setUp(() {
      scope = StructMemory.createScope();
    });

    tearDown(() {
      scope.dispose();
    });

    test('should allocate and track Point', () {
      final point = scope.allocPoint();
      point.ref.x = 10;
      point.ref.y = 20;

      expect(point.ref.x, equals(10));
      expect(point.ref.y, equals(20));
    });

    test('should handle multiple allocations', () {
      final points = List.generate(5, (i) => scope.allocPoint()
        ..ref.x = i
        ..ref.y = i * 2);

      for (var i = 0; i < points.length; i++) {
        expect(points[i].ref.x, equals(i));
        expect(points[i].ref.y, equals(i * 2));
      }
    });

    test('should prevent allocation after dispose', () {
      scope.dispose();
      expect(() => scope.allocPoint(), throwsStateError);
    });

    test('should handle Rectangle allocation', () {
      final rect = scope.allocRectangle();
      rect.ref.setPoints(1, 2, 3, 4);

      expect(rect.ref.points[0], equals(1));
      expect(rect.ref.points[3], equals(4));
    });
  });

  group('Memory Pool Tests', () {
    late PointPool pool;
    const poolSize = 10;

    setUp(() {
      pool = PointPool(capacity: poolSize);
    });

    tearDown(() {
      pool.dispose();
    });

    test('should allocate from pool', () {
      final point = pool.allocate();
      expect(point, isNotNull);
      expect(pool.available, equals(poolSize - 1));
    });

    test('should free back to pool', () {
      final point = pool.allocate();
      point!.ref.x = 10;
      point.ref.y = 20;

      pool.free(point);
      expect(pool.available, equals(poolSize));

      // Next allocation should reuse the freed space
      final newPoint = pool.allocate();
      expect(newPoint!.ref.x, equals(0)); // Should be reset
      expect(newPoint.ref.y, equals(0));
    });

    test('should handle multiple allocations and frees', () {
      final points = <Pointer<Point>>[];

      // Allocate all available slots
      for (var i = 0; i < poolSize; i++) {
        final point = pool.allocate();
        expect(point, isNotNull);
        points.add(point!);
      }

      expect(pool.available, equals(0));
      expect(pool.allocate(), isNull); // Pool is full

      // Free half the points
      for (var i = 0; i < poolSize ~/ 2; i++) {
        pool.free(points[i]);
      }

      expect(pool.available, equals(poolSize ~/ 2));

      // Should be able to allocate the freed slots
      for (var i = 0; i < poolSize ~/ 2; i++) {
        expect(pool.allocate(), isNotNull);
      }
    });

    test('should handle batch operations', () {
      final points = pool.allocateMany(5);
      expect(points.length, equals(5));
      expect(pool.available, equals(poolSize - 5));

      pool.freeMany(points);
      expect(pool.available, equals(poolSize));
    });

    test('should prevent operations after dispose', () {
      pool.dispose();
      expect(() => pool.allocate(), throwsStateError);
    });
  });

  group('Memory Safety Tests', () {
    test('SafePointer should prevent use after dispose', () {
      final ptr = Point.alloc();
      final safePtr = SafePointer<Point>(ptr, debugName: 'TestPoint');

      safePtr.pointer.ref.x = 10;
      expect(safePtr.pointer.ref.x, equals(10));

      safePtr.dispose();
      expect(() => safePtr.pointer, throwsStateError);
    });

    test('MemoryGuard should detect corruption', () {
      final pointer = Point.alloc();
      final guard = MemoryGuard(pointer, sizeOf<Point>(), debugName: 'TestGuard');

      guard.check(); // Should not throw

      // Simulate corruption
      final corruptPtr = pointer.cast<Uint32>();
      (corruptPtr + (-1)).value = 0xDEADBEEF + 1;

      expect(() => guard.check(), throwsStateError);

      calloc.free(pointer);
    });

    test('BoundsChecker should prevent out of bounds access', () {
      const length = 5;
      const checker = BoundsChecker(length);

      // Valid accesses
      checker.check(0);
      checker.check(length - 1);

      // Invalid accesses
      expect(() => checker.check(-1), throwsRangeError);
      expect(() => checker.check(length), throwsRangeError);
    });
  });
}
