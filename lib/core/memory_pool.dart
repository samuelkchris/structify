import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'base.dart';

/// A base class for managing a pool of structs
class BaseStructPool {
  final int _capacity;
  final List<bool> _used;
  bool _isDisposed = false;

  /// Constructs a [BaseStructPool] with the given capacity.
  ///
  /// * [capacity]: The number of structs the pool can hold.
  BaseStructPool({required int capacity})
      : _capacity = capacity,
        _used = List.filled(capacity, false);

  /// Returns the total capacity of the pool.
  int get capacity => _capacity;

  /// Returns the number of allocated structs.
  int get allocated => _used.where((used) => used).length;

  /// Returns the number of available slots in the pool.
  int get available => _capacity - allocated;

  /// Finds the index of the first free slot in the pool.
  ///
  /// Returns the index of the free slot, or -1 if no free slot is found.
  int _findFreeIndex() {
    for (var i = 0; i < _capacity; i++) {
      if (!_used[i]) return i;
    }
    return -1;
  }

  /// Marks a slot as used.
  ///
  /// * [index]: The index of the slot to mark as used.
  /// Returns true if the slot was successfully marked as used, false otherwise.
  bool _markUsed(int index) {
    if (index >= 0 && index < _capacity && !_used[index]) {
      _used[index] = true;
      return true;
    }
    return false;
  }

  /// Marks a slot as free.
  ///
  /// * [index]: The index of the slot to mark as free.
  void _markFree(int index) {
    if (index >= 0 && index < _capacity) {
      _used[index] = false;
    }
  }

  /// Returns whether the pool has been disposed.
  bool get isDisposed => _isDisposed;

  /// Marks the pool as disposed.
  void markDisposed() {
    _isDisposed = true;
  }
}

/// A pool for managing [Point] structs
class PointPool extends BaseStructPool {
  final List<Pointer<Point>> _pointers;
  final Map<Pointer<Point>, int> _pointerToIndex;

  /// Constructs a [PointPool] with the given capacity.
  ///
  /// * [capacity]: The number of points the pool can hold.
  PointPool({required super.capacity})
      : _pointers =
            List.generate(capacity, (_) => calloc<Point>(), growable: false),
        _pointerToIndex = {} {
    // Initialize pointer to index mapping
    for (var i = 0; i < capacity; i++) {
      _pointerToIndex[_pointers[i]] = i;
    }
  }

  /// Allocates a [Point] from the pool.
  ///
  /// Returns a pointer to the allocated [Point], or null if no free slot is available.
  Pointer<Point>? allocate() {
    if (isDisposed) {
      throw StateError('Cannot allocate from disposed pool');
    }

    final index = _findFreeIndex();
    if (index != -1 && _markUsed(index)) {
      return _pointers[index];
    }
    return null;
  }

  /// Allocates multiple [Point] structs from the pool.
  ///
  /// * [count]: The number of points to allocate.
  /// Returns a list of pointers to the allocated points.
  List<Pointer<Point>> allocateMany(int count) {
    if (isDisposed) {
      throw StateError('Cannot allocate from disposed pool');
    }

    if (count > available) {
      throw ArgumentError(
          'Not enough space in pool ($available available, requested $count)');
    }

    final result = <Pointer<Point>>[];
    for (var i = 0; i < count; i++) {
      final ptr = allocate();
      if (ptr == null) break;
      result.add(ptr);
    }
    return result;
  }

  /// Frees a [Point] back to the pool.
  ///
  /// * [pointer]: The pointer to the [Point] to free.
  void free(Pointer<Point> pointer) {
    if (isDisposed) {
      throw StateError('Cannot free to disposed pool');
    }

    final index = _pointerToIndex[pointer];
    if (index == null) {
      throw ArgumentError('Pointer not from this pool');
    }

    _markFree(index);
    pointer.ref.x = 0;
    pointer.ref.y = 0;
  }

  /// Frees multiple [Point] structs back to the pool.
  ///
  /// * [pointers]: The list of pointers to the points to free.
  void freeMany(List<Pointer<Point>> pointers) {
    for (final ptr in pointers) {
      free(ptr);
    }
  }

  /// Disposes the pool, freeing all allocated memory.
  void dispose() {
    if (isDisposed) return;

    // Reset all slots to unused
    for (var i = 0; i < capacity; i++) {
      _markFree(i);
    }

    // Free all pointers
    for (final ptr in _pointers) {
      calloc.free(ptr);
    }
    _pointerToIndex.clear();
    markDisposed();
  }

  /// Returns a string representation of the pool state for debugging.
  ///
  /// Returns a string showing the state of each slot in the pool.
  String debugState() {
    return 'Pool State:\n${_used.asMap().entries.map((e) => '${e.key}: ${e.value ? "used" : "free"}').join('\n')}';
  }
}
