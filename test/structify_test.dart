// import 'package:structify/core/struct_base.dart';
// import 'package:structify/core/struct_buffer.dart';
// import 'package:test/test.dart';
//
// void main() {
//   group('Point struct tests', () {
//     test('should correctly serialize and deserialize', () {
//       final point = Point(10, 20);
//       final buffer = point.serialize();
//       final deserializedPoint = Point.deserialize(buffer);
//
//       expect(deserializedPoint.x.value, equals(10));
//       expect(deserializedPoint.y.value, equals(20));
//     });
//
//     test('should maintain correct byte size', () {
//       final point = Point(10, 20);
//       expect(point.sizeInBytes, equals(8));
//       expect(point.serialize().lengthInBytes, equals(8));
//     });
//   });
//
//   group('StructBuffer tests', () {
//     test('should correctly write and read values', () {
//       final buffer = StructBuffer(8);
//
//       buffer.writeInt32(0, 42);
//       buffer.writeInt32(4, 24);
//
//       expect(buffer.readInt32(0), equals(42));
//       expect(buffer.readInt32(4), equals(24));
//     });
//   });
// }
