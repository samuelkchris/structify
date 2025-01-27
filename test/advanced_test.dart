import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:test/test.dart';
import 'package:structify/structify.dart';
import 'dart:ffi';

void main() {
  group('String Types Tests', () {
    /// Tests basic operations of `StructString`.
    test('StructString basic operations', () {
      final str = StructString.create(20);

      str.ref.setValue("Hello World");
      expect(str.ref.getValue(), equals("Hello World"));
      expect(str.ref.length, equals(11));
      expect(str.ref.capacity, equals(20));

      str.ref.setValue("Test");
      expect(str.ref.getValue(), equals("Test"));
      expect(str.ref.length, equals(4));

      expect(() => str.ref.setValue("This string is too long for the capacity"),
          throwsArgumentError);

      str.ref.dispose();
      calloc.free(str);
    });

    /// Tests operations of `StructStringArray`.
    test('StructStringArray operations', () {
      final strArray = StructStringArray.create(5, 10);

      strArray.ref.setString(0, "First");
      strArray.ref.setString(1, "Second");
      strArray.ref.setString(2, "Third");

      expect(strArray.ref.getString(0), equals("First"));
      expect(strArray.ref.getString(1), equals("Second"));
      expect(strArray.ref.getString(2), equals("Third"));
      expect(strArray.ref.length, equals(3));

      expect(() => strArray.ref.getString(5), throwsRangeError);
      expect(() => strArray.ref.setString(0, "This string is too long"),
          throwsArgumentError);

      strArray.ref.dispose();
      calloc.free(strArray);
    });

    /// Tests complete functionality of `StringStruct`.
    test('StringStruct complete test', () {
      final struct = StringStruct.create(
        nameCapacity: 50,
        tagsCapacity: 3,
        tagStringCapacity: 20,
      );

      struct.ref.name.setValue("Test Structure");
      struct.ref.tags.setString(0, "tag1");
      struct.ref.tags.setString(1, "tag2");
      struct.ref.tags.setString(2, "tag3");

      expect(struct.ref.name.getValue(), equals("Test Structure"));
      expect(struct.ref.tags.getString(0), equals("tag1"));
      expect(struct.ref.tags.getString(1), equals("tag2"));
      expect(struct.ref.tags.getString(2), equals("tag3"));

      struct.ref.dispose();
      calloc.free(struct);
    });
  });

  group('Endianness Tests', () {
    /// Tests byte order handling in `NetworkPacket`.
    test('NetworkPacket byte order', () {
      final packet = NetworkPacket.alloc();

      packet.ref.messageType = 0x12345678; // Network byte order (big-endian)
      packet.ref.payloadLength = 0xABCD; // Network byte order (big-endian)

      // For big-endian systems, these values should remain unchanged
      // For little-endian systems, these values will be byte-swapped

      final testData = [0x01, 0x02, 0x03, 0x04];
      packet.ref.setPayload(testData);

      // Test proper endianness conversion
      if (Endian.host == Endian.little) {
        // On little-endian systems, the values should be byte-swapped
        expect(packet.ref.payloadLength, equals(0xCDAB));
      } else {
        // On big-endian systems, the values should remain unchanged
        expect(packet.ref.payloadLength, equals(0xABCD));
      }

      expect(packet.ref.getPayload(), equals(testData));

      NetworkPacket.free(packet);
    });
  });
}
