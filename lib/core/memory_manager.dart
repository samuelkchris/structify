
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:structify/core/union.dart';
import 'package:structify/types/struct_types.dart';
import 'base.dart';


/// A scope-based memory manager for automatic cleanup
class StructScope {
  final List<Pointer<NativeType>> _allocations = [];
  bool _isDisposed = false;

  /// Register an existing pointer for cleanup
  void register(Pointer<NativeType> ptr) {
    if (_isDisposed) {
      throw StateError('Cannot register pointer in disposed scope');
    }
    _allocations.add(ptr);
  }

  /// Manually free a pointer and remove it from cleanup
  void free(Pointer<NativeType> ptr) {
    if (_isDisposed) {
      throw StateError('Cannot free memory in disposed scope');
    }
    if (_allocations.remove(ptr)) {
      calloc.free(ptr);
    }
  }

  /// Free all allocated memory
  void dispose() {
    if (_isDisposed) return;

    for (final ptr in _allocations) {
      calloc.free(ptr);
    }
    _allocations.clear();
    _isDisposed = true;
  }

  /// Allocate an array of Points
  Pointer<Point> allocPoints(int count) {
    if (_isDisposed) {
      throw StateError('Cannot allocate memory in disposed scope');
    }
    final ptr = calloc<Point>(count);
    _allocations.add(ptr);
    return ptr;
  }

  /// Allocate single Point
  Pointer<Point> allocPoint() {
    return allocPoints(1);
  }

  /// Allocate single Rectangle
  Pointer<Rectangle> allocRectangle() {
    if (_isDisposed) {
      throw StateError('Cannot allocate memory in disposed scope');
    }
    final ptr = calloc<Rectangle>();
    _allocations.add(ptr);
    return ptr;
  }

  /// Allocate single ComplexStruct
  Pointer<ComplexStruct> allocComplexStruct() {
    if (_isDisposed) {
      throw StateError('Cannot allocate memory in disposed scope');
    }
    final ptr = calloc<ComplexStruct>();
    _allocations.add(ptr);
    return ptr;
  }

  /// Allocate single DataUnion
  Pointer<DataUnion> allocDataUnion() {
    if (_isDisposed) {
      throw StateError('Cannot allocate memory in disposed scope');
    }
    final ptr = calloc<DataUnion>();
    _allocations.add(ptr);
    return ptr;
  }

  /// Allocate single TaggedUnion
  Pointer<TaggedUnion> allocTaggedUnion() {
    if (_isDisposed) {
      throw StateError('Cannot allocate memory in disposed scope');
    }
    final ptr = calloc<TaggedUnion>();
    _allocations.add(ptr);
    return ptr;
  }
}

/// Global memory manager for convenience
class StructMemory {
  static final Map<String, StructScope> _scopes = {};

  /// Create or get a named scope
  static StructScope scope(String name) {
    return _scopes.putIfAbsent(name, () => StructScope());
  }

  /// Create a new anonymous scope
  static StructScope createScope() {
    return StructScope();
  }

  /// Dispose a named scope
  static void disposeScope(String name) {
    final scope = _scopes.remove(name);
    scope?.dispose();
  }

  /// Dispose all scopes
  static void disposeAll() {
    for (final scope in _scopes.values) {
      scope.dispose();
    }
    _scopes.clear();
  }
}