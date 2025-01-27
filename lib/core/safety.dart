
import 'dart:ffi';
import 'package:ffi/ffi.dart';

/// Memory safety wrapper for struct pointers
class SafePointer<T extends NativeType> {
  final Pointer<T> _pointer;
  bool _isDisposed = false;
  final void Function(Pointer<T>)? _disposeFunc;
  final String _debugName;

  SafePointer(this._pointer, {
    void Function(Pointer<T>)? disposeFunc,
    String debugName = 'Unnamed',
  }) : _disposeFunc = disposeFunc,
        _debugName = debugName;

  Pointer<T> get pointer {
    _checkDisposed();
    return _pointer;
  }

  void _checkDisposed() {
    if (_isDisposed) {
      throw StateError('Attempt to use disposed pointer: $_debugName');
    }
  }

  void dispose() {
    if (_isDisposed) return;
    if (_disposeFunc != null) {
      _disposeFunc(_pointer);
    } else {
      calloc.free(_pointer);
    }
    _isDisposed = true;
  }
}

/// Memory corruption detection
class MemoryGuard {
  static const _guardValue = 0xDEADBEEF;
  final Pointer<Uint32> _start;
  final Pointer<Uint32> _end;
  final int _size;
  final String _debugName;

  MemoryGuard(Pointer<NativeType> pointer, int size, {String debugName = 'Unnamed'})
      : _start = pointer.cast<Uint32>().elementAt(-1),
        _end = pointer.cast<Uint32>().elementAt(size ~/ sizeOf<Uint32>()),
        _size = size,
        _debugName = debugName {
    _start.value = _guardValue;
    _end.value = _guardValue;
  }

  void check() {
    if (_start.value != _guardValue) {
      throw StateError('Memory corruption detected at start of $_debugName');
    }
    if (_end.value != _guardValue) {
      throw StateError('Memory corruption detected at end of $_debugName');
    }
  }
}

/// Range checking for arrays
class BoundsChecker {
  final int _length;
  final String _debugName;

  const BoundsChecker(this._length, {String debugName = 'Unnamed'})
      : _debugName = debugName;

  void check(int index) {
    if (index < 0 || index >= _length) {
      throw RangeError.range(
          index, 0, _length - 1,
          'index',
          'Index out of bounds for $_debugName'
      );
    }
  }
}

/// Reference counting for shared pointers
class ReferenceCounter {
  final Pointer<NativeType> _pointer;
  final Pointer<Int32> _refCount;
  final void Function(Pointer<NativeType>)? _disposeFunc;
  bool _isDisposed = false;
  final String _debugName;

  ReferenceCounter(this._pointer, {
    void Function(Pointer<NativeType>)? disposeFunc,
    String debugName = 'Unnamed',
  }) : _refCount = calloc<Int32>(),
        _disposeFunc = disposeFunc,
        _debugName = debugName {
    _refCount.value = 1;
  }

  Pointer<NativeType> get pointer {
    _checkDisposed();
    return _pointer;
  }

  void _checkDisposed() {
    if (_isDisposed) {
      throw StateError('Attempt to use disposed reference: $_debugName');
    }
  }

  void increment() {
    _checkDisposed();
    _refCount.value++;
  }

  void decrement() {
    _checkDisposed();
    _refCount.value--;
    if (_refCount.value == 0) {
      if (_disposeFunc != null) {
        _disposeFunc!(_pointer);
      } else {
        calloc.free(_pointer);
      }
      calloc.free(_refCount);
      _isDisposed = true;
    }
  }
}

/// Immutable struct wrapper
class ImmutableStruct {
  final Pointer<NativeType> _pointer;
  final String _debugName;
  final Type _structType;

  ImmutableStruct(this._pointer, this._structType, {String debugName = 'Unnamed'})
      : _debugName = debugName;

  Pointer<NativeType> get pointer => _pointer;

  @override
  String toString() => 'ImmutableStruct<$_structType>($_debugName)';
}

/// Memory validation utilities
class MemoryValidator {
  static void validateAlignment(int offset, int alignment) {
    if (offset % alignment != 0) {
      throw StateError('Misaligned memory access: offset $offset is not aligned to $alignment bytes');
    }
  }

  static void validateSize(int size, int maxSize) {
    if (size < 0 || size > maxSize) {
      throw RangeError.range(size, 0, maxSize, 'size');
    }
  }

  static void validatePointer(Pointer<NativeType> pointer) {
    if (pointer.address == 0) {
      throw StateError('Null pointer dereference');
    }
  }
}