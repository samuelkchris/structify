# 🚀 Structify Quickstart Guide

## 📥 Installation

1. Add to pubspec.yaml:
```yaml
dependencies:
  structify: ^0.1.0
```

2. Run:
```bash
dart pub get
```

3. Import:
```dart
import 'package:structify/structify.dart';
```

## 🏃‍♂️ Quick Examples

### 1️⃣ Basic Point Structure
```dart
// Define a point
final class Point extends Struct {
  @Int32()
  external int x;

  @Int32()
  external int y;

  static Pointer<Point> alloc() => calloc<Point>();
}

// Use the point
void main() {
  final point = Point.alloc();
  point.ref.x = 10;
  point.ref.y = 20;
  print('Point: (${point.ref.x}, ${point.ref.y})');
  calloc.free(point);
}
```

### 2️⃣ Memory Pool
```dart
void poolExample() {
  final pool = PointPool(capacity: 100);
  final points = pool.allocateMany(5);
  
  // Use points...
  for (final ptr in points) {
    ptr.ref.x = 42;
    ptr.ref.y = 42;
  }
  
  pool.freeMany(points);
}
```

### 3️⃣ SIMD Vector
```dart
void simdExample() {
  final vector = SimdVector.alloc();
  vector.ref.setValues([1.0, 2.0, 3.0, 4.0]);
  
  // Use vector...
  
  SimdVector.free(vector);
}
```

## 🛠️ Common Operations

### Memory Management
```dart
// Scope-based management
final scope = StructMemory.createScope();
try {
  final point = scope.allocPoint();
  // Use point...
} finally {
  scope.dispose();
}
```

### Alignment Control
```dart
@Aligned(StructAlignment.align8)
final class AlignedStruct extends Struct {
  @Int32()
  external int field1;

  @Float64()
  external double field2;
}
```

### Network Protocol
```dart
final packet = NetworkPacket.alloc();
packet.ref
  ..messageId = 1234
  ..setData([0xDE, 0xAD, 0xBE, 0xEF]);
NetworkPacket.free(packet);
```

## 🎯 Best Practices

1. Always use scope-based memory management
2. Use pools for multiple similar objects
3. Align data structures appropriately
4. Clean up resources in finally blocks
5. Use SIMD for vector operations

## 🚫 Common Pitfalls

❌ **Don't** forget to free memory
```dart
final point = Point.alloc();  // Memory leak!
```

✅ **Do** use scope or explicit cleanup
```dart
final point = Point.alloc();
try {
  // Use point...
} finally {
  calloc.free(point);
}
```

❌ **Don't** access freed memory
```dart
pool.free(point);
point.ref.x = 42;  // Undefined behavior!
```

✅ **Do** clear references after freeing
```dart
pool.free(point);
point = null;  // Prevent accidental use
```

## 🔍 Debugging Tips

1. Use memory analyzers:
```dart
MemoryAnalyzer.analyzeMemoryUsage(() {
  // Your code here
});
```

2. Enable debug checks:
```dart
StructifyConfig.debugMode = true;
```

3. Visualize memory layout:
```dart
visualizeMemoryLayout(struct);
```

## 📚 Next Steps

1. Read the full [Documentation](docs/README.md)
2. Check out [Examples](examples/)
3. Run [Benchmarks](benchmark/)
4. Join our [Discord](https://discord.gg/structify)

## 🆘 Getting Help

1. Open an issue on [GitHub](https://github.com/samuelkchris/structify)
2. Ask on [Stack Overflow](https://stackoverflow.com/questions/tagged/structify)
3. Check the [FAQ](docs/FAQ.md)

## 🎉 Quick Tips

1. Use `@packed` for network structures
2. Use `align16` for SIMD operations
3. Pool similar objects together
4. Use scope-based management for simplicity
5. Profile before optimizing

Ready to dive deeper? Check out our [Advanced Guide](docs/advanced.md)!