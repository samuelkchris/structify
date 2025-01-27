# 📚 Structify Examples and Tutorials

## 🚀 Basic Examples

### 1. Working with Points and Vectors
```dart
import 'package:structify/structify.dart';

void main() {
  // Create a memory scope
  final scope = StructMemory.createScope();
  
  try {
    // Create a point
    final point = scope.allocPoint().ref
      ..x = 10
      ..y = 20;
    
    // Create a vector
    final vector = SimdVector.alloc();
    vector.ref.setValues([1.0, 2.0, 3.0, 4.0]);

    print('Point: $point');
    print('Vector: ${vector.ref.values[0]}, ${vector.ref.values[1]}, ...');
  } finally {
    scope.dispose();
  }
}
```

### 2. Memory Pool Usage
```dart
void poolExample() {
  final pool = PointPool(capacity: 1000);
  
  // Batch allocation
  final points = pool.allocateMany(5);
  
  // Initialize points
  for (final ptr in points) {
    ptr.ref
      ..x = 42
      ..y = 42;
  }
  
  // Process points in batch
  for (final ptr in points) {
    ptr.ref.x *= 2;
    ptr.ref.y *= 2;
  }
  
  // Free memory
  pool.freeMany(points);
}
```

### 3. Networking with Endianness Control
```dart
void networkExample() {
  final packet = NetworkPacket.alloc();
  
  // Set message fields
  packet.ref
    ..messageId = 0x12345678    // Network byte order
    ..flags = 0xAABBCCDD        // Host byte order
    ..timestamp = DateTime.now().millisecondsSinceEpoch;
    
  // Add payload
  final payload = [0xDE, 0xAD, 0xBE, 0xEF];
  packet.ref.setData(payload);
  
  // Cleanup
  NetworkPacket.free(packet);
}
```

## 🎓 Advanced Examples

### 1. Custom SIMD Operations
```dart
void simdExample() {
  final vectorA = SimdVector.alloc();
  final vectorB = SimdVector.alloc();
  final result = SimdVector.alloc();
  
  try {
    // Initialize vectors
    vectorA.ref.setValues([1.0, 2.0, 3.0, 4.0]);
    vectorB.ref.setValues([5.0, 6.0, 7.0, 8.0]);
    
    // Perform SIMD operations
    for (var i = 0; i < 4; i++) {
      result.ref.values[i] = 
        vectorA.ref.values[i] * vectorB.ref.values[i];
    }
  } finally {
    // Cleanup
    SimdVector.free(vectorA);
    SimdVector.free(vectorB);
    SimdVector.free(result);
  }
}
```

### 2. Custom Alignment with Memory Analysis
```dart
@Aligned(StructAlignment.align16)
final class CustomStruct extends Struct {
  @Int32()
  @Aligned(StructAlignment.align4)
  external int field1;

  @Float64()
  @Aligned(StructAlignment.align8)
  external double field2;

  @Array(4)
  external Array<Float32> field3;

  static Pointer<CustomStruct> alloc() {
    return calloc.align16<CustomStruct>();
  }
}

void alignmentExample() {
  final struct = CustomStruct.alloc();
  
  try {
    // Analyze memory layout
    print('Struct size: ${sizeOf<CustomStruct>()} bytes');
    analyzeStructLayout(struct.ref);
  } finally {
    calloc.free(struct);
  }
}
```

### 3. Dynamic Memory Management
```dart
void dynamicMemoryExample() {
  final array = DynamicAlignedArray.create(
    initialCapacity: 16,
    elementSize: sizeOf<Int32>(),
    alignment: 8,
  );
  
  try {
    // Add elements
    for (var i = 0; i < 20; i++) {
      final value = calloc<Int32>()..value = i;
      array.ref.add(value);
      calloc.free(value);
    }
    
    // Array will automatically resize
    print('Capacity: ${array.ref.capacity}');
    print('Length: ${array.ref.length}');
  } finally {
    DynamicAlignedArray.free(array);
  }
}
```

## 🔧 Real-World Examples

### 1. Game Physics Engine
```dart
final class PhysicsBody extends Struct {
  external Vector3 position;
  external Vector3 velocity;
  external Quaternion rotation;
  external Float32 mass;

  void updatePosition(double deltaTime) {
    position.x += velocity.x * deltaTime;
    position.y += velocity.y * deltaTime;
    position.z += velocity.z * deltaTime;
  }
}
```

### 2. Network Protocol Handler
```dart
final class ProtocolHandler {
  final StructScope _scope;
  final List<NetworkPacket> _packetPool;
  
  void handleMessage(List<int> rawData) {
    final packet = NetworkPacket.alloc();
    try {
      packet.ref.deserializeFromBytes(rawData);
      processMessage(packet.ref);
    } finally {
      NetworkPacket.free(packet);
    }
  }
}
```

### 3. Image Processing
```dart
final class ImageProcessor {
  final SimdVector _colorVector;
  final StructScope _scope;
  
  void applyFilter(List<int> pixels) {
    final vectorized = SimdVector.alloc();
    try {
      // Process 4 pixels at a time using SIMD
      for (var i = 0; i < pixels.length; i += 4) {
        vectorized.ref.setValues(pixels.sublist(i, i + 4)
            .map((p) => p.toDouble()).toList());
        // Apply filter...
      }
    } finally {
      SimdVector.free(vectorized);
    }
  }
}
```

## 🎮 Interactive Examples

### 1. Memory Pool Visualization
```dart
void visualizePool() {
  final pool = PointPool(capacity: 10);
  print('Pool visualization:');
  print('┌─────────────────────┐');
  print('│ Memory Pool Status  │');
  print('├─────┬───────────────┤');
  
  // Allocate and visualize
  final points = pool.allocateMany(5);
  for (var i = 0; i < 10; i++) {
    final status = i < 5 ? '█' : '░';
    print('│ $i   │     $status     │');
  }
  print('└─────┴───────────────┘');
  
  pool.freeMany(points);
}
```