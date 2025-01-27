import 'dart:ffi';
  import 'package:ffi/ffi.dart';

  /// Memory safety wrapper for struct pointers
  class SafePointer<T extends NativeType> {
    final Pointer<T> _pointer;
    bool _isDisposed = false;
    final void Function(Pointer<T>)? _disposeFunc;
    final String _debugName;

    /// Constructs a [SafePointer] with the given pointer and optional dispose function.
    ///
    /// * [pointer]: The pointer to manage.
    /// * [disposeFunc]: Optional function to dispose the pointer.
    /// * [debugName]: Optional name for debugging purposes.
    SafePointer(this._pointer, {
      void Function(Pointer<T>)? disposeFunc,
      String debugName = 'Unnamed',
    }) : _disposeFunc = disposeFunc,
          _debugName = debugName;

    /// Returns the managed pointer.
    Pointer<T> get pointer {
      _checkDisposed();
      return _pointer;
    }

    /// Checks if the pointer has been disposed and throws an error if it has.
    void _checkDisposed() {
      if (_isDisposed) {
        throw StateError('Attempt to use disposed pointer: $_debugName');
      }
    }

    /// Disposes the managed pointer.
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
    final String _debugName;

    /// Constructs a [MemoryGuard] for the given pointer and size.
    ///
    /// * [pointer]: The pointer to guard.
    /// * [size]: The size of the memory block.
    /// * [debugName]: Optional name for debugging purposes.
    MemoryGuard(Pointer<NativeType> pointer, int size, {String debugName = 'Unnamed'})
        : _start = pointer.cast<Uint32>() + (-1),
        _end = pointer.cast<Uint32>() + (size ~/ sizeOf<Uint32>()),
          _debugName = debugName {
      _start.value = _guardValue;
      _end.value = _guardValue;
    }

    /// Checks for memory corruption and throws an error if detected.
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

    /// Constructs a [BoundsChecker] for the given length.
    ///
    /// * [length]: The length of the array.
    /// * [debugName]: Optional name for debugging purposes.
    const BoundsChecker(this._length, {String debugName = 'Unnamed'})
        : _debugName = debugName;

    /// Checks if the given index is within bounds and throws an error if not.
    ///
    /// * [index]: The index to check.
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

    /// Constructs a [ReferenceCounter] for the given pointer.
    ///
    /// * [pointer]: The pointer to manage.
    /// * [disposeFunc]: Optional function to dispose the pointer.
    /// * [debugName]: Optional name for debugging purposes.
    ReferenceCounter(this._pointer, {
      void Function(Pointer<NativeType>)? disposeFunc,
      String debugName = 'Unnamed',
    }) : _refCount = calloc<Int32>(),
          _disposeFunc = disposeFunc,
          _debugName = debugName {
      _refCount.value = 1;
    }

    /// Returns the managed pointer.
    Pointer<NativeType> get pointer {
      _checkDisposed();
      return _pointer;
    }

    /// Checks if the reference has been disposed and throws an error if it has.
    void _checkDisposed() {
      if (_isDisposed) {
        throw StateError('Attempt to use disposed reference: $_debugName');
      }
    }

    /// Increments the reference count.
    void increment() {
      _checkDisposed();
      _refCount.value++;
    }

    /// Decrements the reference count and disposes the pointer if the count reaches zero.
    void decrement() {
      _checkDisposed();
      _refCount.value--;
      if (_refCount.value == 0) {
        if (_disposeFunc != null) {
          _disposeFunc(_pointer);
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

    /// Constructs an [ImmutableStruct] for the given pointer and struct type.
    ///
    /// * [pointer]: The pointer to the struct.
    /// * [structType]: The type of the struct.
    /// * [debugName]: Optional name for debugging purposes.
    ImmutableStruct(this._pointer, this._structType, {String debugName = 'Unnamed'})
        : _debugName = debugName;

    /// Returns the managed pointer.
    Pointer<NativeType> get pointer => _pointer;

    @override
    String toString() => 'ImmutableStruct<$_structType>($_debugName)';
  }

  /// Memory validation utilities
  class MemoryValidator {
    /// Validates the alignment of the given offset.
    ///
    /// * [offset]: The offset to validate.
    /// * [alignment]: The required alignment.
    static void validateAlignment(int offset, int alignment) {
      if (offset % alignment != 0) {
        throw StateError('Misaligned memory access: offset $offset is not aligned to $alignment bytes');
      }
    }

    /// Validates the size of the given memory block.
    ///
    /// * [size]: The size to validate.
    /// * [maxSize]: The maximum allowed size.
    static void validateSize(int size, int maxSize) {
      if (size < 0 || size > maxSize) {
        throw RangeError.range(size, 0, maxSize, 'size');
      }
    }

    /// Validates the given pointer.
    ///
    /// * [pointer]: The pointer to validate.
    static void validatePointer(Pointer<NativeType> pointer) {
      if (pointer.address == 0) {
        throw StateError('Null pointer dereference');
      }
    }
  }