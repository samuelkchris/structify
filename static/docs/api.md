# 📖 Structify API Reference

## Core Classes

### 🏗️ Struct Base Types

#### Point
```dart
final class Point extends Struct {
  @Int32()
  external int x;
  
  @Int32()
  external int y;
  
  static Pointer<Point> alloc();
  static void free(Pointer<Point> ptr);
}
```

#### SimdVector
```dart
final class SimdVector extends Struct {
  @Array(4)
  external Array<Float32> values;
  
  void setValues(List<double> newValues);
  List<double> getValues();
  static Pointer<SimdVector> alloc();
}
```

### 🧠 Memory Management

#### StructMemory
```dart
class StructMemory {
  /// Create a new memory scope
  static StructScope createScope();
  
  /// Get or create a named scope
  static StructScope scope(String name);
  
  /// Dispose a named scope
  static void disposeScope(String name);
  
  /// Dispose all scopes
  static void disposeAll();
}
```

#### StructScope
```dart
class StructScope {
  /// Register a pointer for cleanup
  void register(Pointer<NativeType> ptr);
  
  /// Manually free a pointer
  void free(Pointer<NativeType> ptr);
  
  /// Free all allocated memory
  void dispose();
  
  /// Allocate Point
  Pointer<Point> allocPoint();
  
  /// Allocate multiple Points
  Pointer<Point> allocPoints(int count);
}
```

### 🏊‍♂️ Memory Pools

#### BaseStructPool
```dart
class BaseStructPool {
  final int capacity;
  int get allocated;
  int get available;
  
  bool get isDisposed;
  void markDisposed();
}
```

#### PointPool
```dart
class PointPool extends BaseStructPool {
  PointPool({required int capacity});
  
  Pointer<Point>? allocate();
  List<Pointer<Point>> allocateMany(int count);
  void free(Pointer<Point> pointer);
  void freeMany(List<Pointer<Point>> pointers);
  void dispose();
}
```

### 🔄 Endianness Control

#### StructEndian
```dart
enum StructEndian {
  host,
  little,
  big,
  network
}
```

#### ByteOrder
```dart
class ByteOrder {
  final StructEndian endian;
  const ByteOrder(this.endian);
}
```

### ⚖️ Alignment Control

#### StructAlignment
```dart
enum StructAlignment {
  packed(1),
  align2(2),
  align4(4),
  align8(8),
  align16(16)
}
```

#### Aligned
```dart
class Aligned {
  final StructAlignment alignment;
  const Aligned(this.alignment);
}
```

## Extensions

### 🛠️ AlignedAlloc
```dart
extension AlignedAlloc on Allocator {
  Pointer<T> allocAligned<T extends Struct>(
    int size,
    int alignment, {
    int count = 1,
  });
  
  Pointer<T> align4<T extends Struct>({int count = 1});
  Pointer<T> align8<T extends Struct>({int count = 1});
  Pointer<T> align16<T extends Struct>({int count = 1});
}
```

### 🔄 EndianConversion
```dart
extension EndianConversion on ByteData {
  int getIntAt(int offset, int bytes, StructEndian endian);
  void setIntAt(int offset, int bytes, int value, StructEndian endian);
  double getFloatAt(int offset, int bytes, StructEndian endian);
  void setFloatAt(int offset, int bytes, double value, StructEndian endian);
}
```

## Annotations

### 📝 Field Annotations
```dart
const packed = Aligned(StructAlignment.packed);

@Int32()
@Aligned(StructAlignment.align4)
@ByteOrder(StructEndian.network)
external int field;
```

## Utility Classes

### 🔍 AlignmentUtils
```dart
class AlignmentUtils {
  static int calculatePadding(int offset, int alignment);
  static int alignOffset(int offset, int alignment);
  static int calculateAlignedSize(int size, int alignment);
  static bool isAligned(int offset, int alignment);
}
```

### 🔄 EndianUtils
```dart
class EndianUtils {
  static int swap16(int value);
  static int swap32(int value);
  static int swap64(int value);
  static int hostToNetwork32(int value);
  static int networkToHost32(int value);
}
```