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
  ///
  /// * [ptr]: The pointer to register.
  void register(Pointer<NativeType> ptr) {
    if (_isDisposed) {
      throw StateError('Cannot register pointer in disposed scope');
    }
    _allocations.add(ptr);
  }

  /// Manually free a pointer and remove it from cleanup
  ///
  /// * [ptr]: The pointer to free.
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
  ///
  /// * [count]: The number of points to allocate.
  /// Returns a pointer to the allocated memory.
  Pointer<Point> allocPoints(int count) {
    if (_isDisposed) {
      throw StateError('Cannot allocate memory in disposed scope');
    }
    final ptr = calloc<Point>(count);
    _allocations.add(ptr);
    return ptr;
  }

  /// Allocate single Point
  ///
  /// Returns a pointer to the allocated memory.
  Pointer<Point> allocPoint() {
    return allocPoints(1);
  }

  /// Allocate single Rectangle
  ///
  /// Returns a pointer to the allocated memory.
  Pointer<Rectangle> allocRectangle() {
    if (_isDisposed) {
      throw StateError('Cannot allocate memory in disposed scope');
    }
    final ptr = calloc<Rectangle>();
    _allocations.add(ptr);
    return ptr;
  }

  /// Allocate single ComplexStruct
  ///
  /// Returns a pointer to the allocated memory.
  Pointer<ComplexStruct> allocComplexStruct() {
    if (_isDisposed) {
      throw StateError('Cannot allocate memory in disposed scope');
    }
    final ptr = calloc<ComplexStruct>();
    _allocations.add(ptr);
    return ptr;
  }

  /// Allocate single DataUnion
  ///
  /// Returns a pointer to the allocated memory.
  Pointer<DataUnion> allocDataUnion() {
    if (_isDisposed) {
      throw StateError('Cannot allocate memory in disposed scope');
    }
    final ptr = calloc<DataUnion>();
    _allocations.add(ptr);
    return ptr;
  }

  /// Allocate single TaggedUnion
  ///
  /// Returns a pointer to the allocated memory.
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
  ///
  /// * [name]: The name of the scope.
  /// Returns the created or existing scope.
  static StructScope scope(String name) {
    return _scopes.putIfAbsent(name, () => StructScope());
  }

  /// Create a new anonymous scope
  ///
  /// Returns the created scope.
  static StructScope createScope() {
    return StructScope();
  }

  /// Dispose a named scope
  ///
  /// * [name]: The name of the scope to dispose.
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
