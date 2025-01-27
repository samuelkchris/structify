import 'package:ffi/ffi.dart';
import 'package:test/test.dart';
import 'package:structify/structify.dart';
import 'dart:ffi';

void main() {
  group('Point Tests', () {
    late Pointer<Point> point;

    setUp(() {
      point = Point.alloc();
    });

    tearDown(() {
      calloc.free(point);
    });

    test('should initialize with zero values', () {
      expect(point.ref.x, equals(0));
      expect(point.ref.y, equals(0));
    });

    test('should set and get values correctly', () {
      point.ref.x = 10;
      point.ref.y = 20;

      expect(point.ref.x, equals(10));
      expect(point.ref.y, equals(20));
    });

    test('should serialize and deserialize correctly', () {
      point.ref.x = 30;
      point.ref.y = 40;

      final buffer = point.ref.serialize();
      final newPoint = Point.deserialize(buffer);

      expect(newPoint.x, equals(30));
      expect(newPoint.y, equals(40));
    });

    test('should have correct size', () {
      expect(sizeOf<Point>(), equals(8)); // Two Int32 fields
    });

    test('should implement toString correctly', () {
      point.ref.x = 50;
      point.ref.y = 60;
      expect(point.ref.toString(), equals('Point(x: 50, y: 60)'));
    });
  });

  group('Rectangle Tests', () {
    late Pointer<Rectangle> rect;

    setUp(() {
      rect = Rectangle.alloc();
    });

    tearDown(() {
      calloc.free(rect);
    });

    test('should initialize array with zeros', () {
      for (var i = 0; i < 4; i++) {
        expect(rect.ref.points[i], equals(0));
      }
    });

    test('should set points correctly', () {
      rect.ref.setPoints(10, 20, 30, 40);

      expect(rect.ref.points[0], equals(10));
      expect(rect.ref.points[1], equals(20));
      expect(rect.ref.points[2], equals(30));
      expect(rect.ref.points[3], equals(40));
    });

    test('should serialize and deserialize correctly', () {
      rect.ref.setPoints(1, 2, 3, 4);

      final buffer = rect.ref.serialize();
      final newRect = Rectangle.deserialize(buffer);

      for (var i = 0; i < 4; i++) {
        expect(newRect.points[i], equals(rect.ref.points[i]));
      }
    });
  });

  group('PackedPoint Tests', () {
    late Pointer<PackedPoint> packedPoint;

    setUp(() {
      packedPoint = PackedPoint.alloc();
    });

    tearDown(() {
      calloc.free(packedPoint);
    });

    test('should have no padding between fields', () {
      // For a packed struct, size should be exactly sum of field sizes
      expect(sizeOf<PackedPoint>(), equals(8)); // Two Int32 fields
    });

    test('should handle field access correctly', () {
      packedPoint.ref.x = 100;
      packedPoint.ref.y = 200;

      expect(packedPoint.ref.x, equals(100));
      expect(packedPoint.ref.y, equals(200));
    });

    test('should serialize and deserialize correctly', () {
      packedPoint.ref.x = 300;
      packedPoint.ref.y = 400;

      final buffer = packedPoint.ref.serialize();
      final newPackedPoint = PackedPoint.deserialize(buffer);

      expect(newPackedPoint.x, equals(300));
      expect(newPackedPoint.y, equals(400));
    });
  });
}