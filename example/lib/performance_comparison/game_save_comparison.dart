import 'dart:convert';
import 'dart:typed_data';
import 'package:structify/structify.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';

// Traditional Approach: Using plain Dart classes
class PlayerDataTraditional {
  int health;
  int mana;
  double positionX;
  double positionY;
  List<int> inventory;
  String playerName;

  PlayerDataTraditional({
    required this.health,
    required this.mana,
    required this.positionX,
    required this.positionY,
    required this.inventory,
    required this.playerName,
  });

  // Serialize to bytes (manual implementation)
  Uint8List toBytes() {
    final nameBytes = utf8.encode(playerName); // Use UTF-8 encoding
    final buffer = ByteData(
        4 + // health
            4 + // mana
            8 + // positionX
            8 + // positionY
            4 + // inventory length
            inventory.length * 4 + // inventory data
            4 + // name length
            nameBytes.length // name data
    );

    var offset = 0;

    // Write fields
    buffer.setInt32(offset, health, Endian.little);
    offset += 4;

    buffer.setInt32(offset, mana, Endian.little);
    offset += 4;

    buffer.setFloat64(offset, positionX, Endian.little);
    offset += 8;

    buffer.setFloat64(offset, positionY, Endian.little);
    offset += 8;

    buffer.setInt32(offset, inventory.length, Endian.little);
    offset += 4;

    for (var item in inventory) {
      buffer.setInt32(offset, item, Endian.little);
      offset += 4;
    }

    buffer.setInt32(offset, nameBytes.length, Endian.little);
    offset += 4;

    final result = Uint8List(buffer.lengthInBytes + nameBytes.length);
    result.setRange(0, buffer.lengthInBytes, buffer.buffer.asUint8List());
    result.setRange(buffer.lengthInBytes, result.length, nameBytes);

    return result;
  }

  // Deserialize from bytes (manual implementation)
  static PlayerDataTraditional fromBytes(Uint8List bytes) {
    final buffer = ByteData.view(bytes.buffer);
    var offset = 0;

    final health = buffer.getInt32(offset, Endian.little);
    offset += 4;

    final mana = buffer.getInt32(offset, Endian.little);
    offset += 4;

    final positionX = buffer.getFloat64(offset, Endian.little);
    offset += 8;

    final positionY = buffer.getFloat64(offset, Endian.little);
    offset += 8;

    final inventoryLength = buffer.getInt32(offset, Endian.little);
    offset += 4;

    final inventory = <int>[];
    for (var i = 0; i < inventoryLength; i++) {
      inventory.add(buffer.getInt32(offset, Endian.little));
      offset += 4;
    }

    final nameLength = buffer.getInt32(offset, Endian.little);
    offset += 4;

    final nameBytes = bytes.sublist(offset, offset + nameLength);
    final playerName = utf8.decode(nameBytes); // Use UTF-8 decoding

    return PlayerDataTraditional(
      health: health,
      mana: mana,
      positionX: positionX,
      positionY: positionY,
      inventory: inventory,
      playerName: playerName,
    );
  }
}

// Structify Approach: Using memory-aligned structs
@Packed(1)
final class PlayerDataStructify extends Struct implements JsonSerializable {
  @Int32()
  external int health;

  @Int32()
  external int mana;

  @Double()  // Using Double for 64-bit floating point
  external double positionX;

  @Double()  // Using Double for 64-bit floating point
  external double positionY;

  @Int32()
  external int inventoryLength;

  @Array(100) // Fixed size for simplicity
  external Array<Int32> inventory;

  // Store name separately since it's variable length
  external Pointer<Utf8> _name;

  static Pointer<PlayerDataStructify> allocate(String name) {
    final ptr = calloc<PlayerDataStructify>();
    ptr.ref.health = 0;
    ptr.ref.mana = 0;
    ptr.ref.positionX = 0;
    ptr.ref.positionY = 0;
    ptr.ref.inventoryLength = 0;
    ptr.ref._name = name.toNativeUtf8();
    return ptr;
  }

  void free() {
    if (_name != nullptr) {
      calloc.free(_name);
    }
    malloc.free(this as Pointer<PlayerDataStructify>);
  }

  String get name => _name.toDartString();
  set name(String value) {
    calloc.free(_name);
    _name = value.toNativeUtf8();
  }

  // Helper method to write to binary
  ByteBuffer toBinary() {
    final nameBytes = utf8.encode(name);
    final size = sizeOf<PlayerDataStructify>() + nameBytes.length;
    final buffer = ByteData(size);
    var offset = 0;

    buffer.setInt32(offset, health, Endian.little);
    offset += 4;

    buffer.setInt32(offset, mana, Endian.little);
    offset += 4;

    buffer.setFloat64(offset, positionX, Endian.little);
    offset += 8;

    buffer.setFloat64(offset, positionY, Endian.little);
    offset += 8;

    buffer.setInt32(offset, inventoryLength, Endian.little);
    offset += 4;

    for (var i = 0; i < inventoryLength; i++) {
      buffer.setInt32(offset, inventory[i], Endian.little);
      offset += 4;
    }

    // Write name length and data
    buffer.setInt32(offset, nameBytes.length, Endian.little);
    offset += 4;

    final result = Uint8List(size);
    result.setRange(0, offset, buffer.buffer.asUint8List());
    result.setRange(offset, offset + nameBytes.length, nameBytes);

    return result.buffer;
  }

  // Helper method to read from binary
  static Pointer<PlayerDataStructify> fromBinary(ByteBuffer buffer) {
    final data = ByteData.view(buffer);
    var offset = 0;

    final ptr = malloc<PlayerDataStructify>();

    ptr.ref.health = data.getInt32(offset, Endian.little);
    offset += 4;

    ptr.ref.mana = data.getInt32(offset, Endian.little);
    offset += 4;

    ptr.ref.positionX = data.getFloat64(offset, Endian.little);
    offset += 8;

    ptr.ref.positionY = data.getFloat64(offset, Endian.little);
    offset += 8;

    ptr.ref.inventoryLength = data.getInt32(offset, Endian.little);
    offset += 4;

    for (var i = 0; i < ptr.ref.inventoryLength; i++) {
      ptr.ref.inventory[i] = data.getInt32(offset, Endian.little);
      offset += 4;
    }

    // Read name length and data
    final nameLength = data.getInt32(offset, Endian.little);
    offset += 4;

    final nameBytes = buffer.asUint8List().sublist(offset, offset + nameLength);
    final name = utf8.decode(nameBytes);
    ptr.ref._name = name.toNativeUtf8();

    return ptr;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'health': health,
      'mana': mana,
      'positionX': positionX,
      'positionY': positionY,
      'inventory': List.generate(inventoryLength, (i) => inventory[i]),
      'name': name,
    };
  }
}

void main() async {
  // Test data
  const iterations = 10000;
  final testInventory = List.generate(50, (i) => i);
  final testName = "PlayerOne";

  print('Performance Comparison: Traditional vs Structify');
  print('Iterations: $iterations\n');

  // Traditional approach timing
  final traditionalStart = DateTime.now();

  for (var i = 0; i < iterations; i++) {
    final player = PlayerDataTraditional(
      health: 100,
      mana: 100,
      positionX: 123.45,
      positionY: 67.89,
      inventory: testInventory,
      playerName: testName,
    );

    final bytes = player.toBytes();
    final decoded = PlayerDataTraditional.fromBytes(bytes);

    // Verify data
    assert(decoded.health == 100);
    assert(decoded.playerName == testName);
  }

  final traditionalDuration = DateTime.now().difference(traditionalStart);

  // Structify approach timing
  final structifyStart = DateTime.now();

  for (var i = 0; i < iterations; i++) {
    final player = PlayerDataStructify.allocate(testName);
    player.ref.health = 100;
    player.ref.mana = 100;
    player.ref.positionX = 123.45;
    player.ref.positionY = 67.89;
    player.ref.inventoryLength = testInventory.length;

    for (var j = 0; j < testInventory.length; j++) {
      player.ref.inventory[j] = testInventory[j];
    }

    // Serialize
    final buffer = player.ref.toBinary();

    // Deserialize
    final newPlayer = PlayerDataStructify.fromBinary(buffer);

    // Verify data
    assert(newPlayer.ref.health == 100);
    assert(newPlayer.ref.name == testName);

    player.ref.free();
    newPlayer.ref.free();
  }

  final structifyDuration = DateTime.now().difference(structifyStart);

  // Print results
  print('Traditional Approach:');
  print('  Total time: ${traditionalDuration.inMilliseconds}ms');
  print('  Average time per operation: ${traditionalDuration.inMicroseconds / iterations}µs\n');

  print('Structify Approach:');
  print('  Total time: ${structifyDuration.inMilliseconds}ms');
  print('  Average time per operation: ${structifyDuration.inMicroseconds / iterations}µs\n');

  final speedup = traditionalDuration.inMicroseconds / structifyDuration.inMicroseconds;
  print('Structify is ${speedup.toStringAsFixed(2)}x faster\n');

  // Memory usage comparison
  print('Memory Usage Comparison:');
  final traditionalSize = 4 + 4 + 8 + 8 + (50 * 4) + testName.length;
  final structifySize = sizeOf<PlayerDataStructify>();
  print('Traditional: $traditionalSize bytes (estimated)');
  print('Structify: $structifySize bytes (fixed)\n');
}