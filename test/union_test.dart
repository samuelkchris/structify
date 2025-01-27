import 'package:ffi/ffi.dart';
import 'package:test/test.dart';
import 'package:structify/structify.dart';
import 'dart:ffi';
import 'dart:typed_data';

void main() {
  group('DataUnion Tests', () {
    late Pointer<DataUnion> union;

    setUp(() {
      union = DataUnion.alloc();
    });

    tearDown(() {
      calloc.free(union);
    });

    test('should share memory between different interpretations', () {
      union.ref.asInt32 = 42;
      final bytes = union.ref.asBytes;

      // Verify that bytes represent the integer 42
      if (Endian.host == Endian.little) {
        expect(bytes[0], equals(42));
        expect(bytes[1], equals(0));
        expect(bytes[2], equals(0));
        expect(bytes[3], equals(0));
      } else {
        expect(bytes[3], equals(42));
        expect(bytes[2], equals(0));
        expect(bytes[1], equals(0));
        expect(bytes[0], equals(0));
      }
    });

    test('should handle float conversion', () {
      union.ref.asFloat = 3.14;
      expect(union.ref.asFloat, closeTo(3.14, 0.0001));

      // Verify memory sharing
      final asInt = union.ref.asInt32;
      union.ref.asInt32 = asInt;
      expect(union.ref.asFloat, closeTo(3.14, 0.0001));
    });

    test('should handle 64-bit values', () {
      union.ref.asInt64 = 0x1234567890ABCDEF;
      expect(union.ref.asInt64, equals(0x1234567890ABCDEF));
    });
  });

  group('TaggedUnion Tests', () {
    late Pointer<TaggedUnion> tagged;

    setUp(() {
      tagged = TaggedUnion.alloc();
    });

    tearDown(() {
      calloc.free(tagged);
    });

    test('should handle integer values', () {
      tagged.ref.setInt(42);
      expect(tagged.ref.tag, equals(0));
      expect(tagged.ref.getValue(), equals(42));
    });

    test('should handle float values', () {
      tagged.ref.setFloat(3.14);
      expect(tagged.ref.tag, equals(1));
      expect(tagged.ref.getValue(), closeTo(3.14, 0.0001));
    });

    test('should handle 64-bit integer values', () {
      tagged.ref.setInt64(0x1234567890ABCDEF);
      expect(tagged.ref.tag, equals(2));
      expect(tagged.ref.getValue(), equals(0x1234567890ABCDEF));
    });

    test('should throw on invalid tag', () {
      tagged.ref.tag = 99;
      expect(() => tagged.ref.getValue(), throwsStateError);
    });

    test('should maintain value after type change', () {
      tagged.ref.setInt(42);
      expect(tagged.ref.getValue(), equals(42));

      tagged.ref.setFloat(3.14);
      expect(tagged.ref.getValue(), closeTo(3.14, 0.0001));

      tagged.ref.setInt64(0x1234567890ABCDEF);
      expect(tagged.ref.getValue(), equals(0x1234567890ABCDEF));
    });
  });

  group('Complex Struct with Union Tests', () {
    late StructScope scope;

    setUp(() {
      scope = StructMemory.createScope();
    });

    tearDown(() {
      scope.dispose();
    });

    test('should handle union within struct', () {
      final tagged = scope.allocTaggedUnion();
      final data = scope.allocDataUnion();

      // Test integer interpretation
      tagged.ref.setInt(42);
      data.ref.asInt32 = tagged.ref.getValue() as int;
      expect(data.ref.asInt32, equals(42));

      // Test float interpretation
      tagged.ref.setFloat(3.14);
      data.ref.asFloat = tagged.ref.getValue() as double;
      expect(data.ref.asFloat, closeTo(3.14, 0.0001));
    });

    test('should handle complex data transformations', () {
      final union = scope.allocDataUnion();

      // Store integer
      union.ref.asInt32 = 42;

      // Read as bytes and modify
      union.ref.asBytes[0] += 1;

      // Verify modification through integer view
      if (Endian.host == Endian.little) {
        expect(union.ref.asInt32, equals(43));
      } else {
        // On big-endian systems, we modified the most significant byte
        expect(union.ref.asInt32, equals(42 + (1 << 24)));
      }
    });
  });
}