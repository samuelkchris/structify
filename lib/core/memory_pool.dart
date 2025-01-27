import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'base.dart';

class BaseStructPool {
  final int _capacity;
  final List<bool> _used;
  bool _isDisposed = false;

  BaseStructPool({required int capacity})
      : _capacity = capacity,
        _used = List.filled(capacity, false);

  int get capacity => _capacity;
  int get allocated => _used.where((used) => used).length;
  int get available => _capacity - allocated;

  int _findFreeIndex() {
    for (var i = 0; i < _capacity; i++) {
      if (!_used[i]) return i;
    }
    return -1;
  }

  bool _markUsed(int index) {
    if (index >= 0 && index < _capacity && !_used[index]) {
      _used[index] = true;
      return true;
    }
    return false;
  }

  void _markFree(int index) {
    if (index >= 0 && index < _capacity) {
      _used[index] = false;
    }
  }

  bool get isDisposed => _isDisposed;

  void markDisposed() {
    _isDisposed = true;
  }
}

class PointPool extends BaseStructPool {
  final List<Pointer<Point>> _pointers;
  final Map<Pointer<Point>, int> _pointerToIndex;

  PointPool({required super.capacity})
      : _pointers = List.generate(
      capacity,
          (_) => calloc<Point>(),
      growable: false),
        _pointerToIndex = {} {
    // Initialize pointer to index mapping
    for (var i = 0; i < capacity; i++) {
      _pointerToIndex[_pointers[i]] = i;
    }
  }

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

  List<Pointer<Point>> allocateMany(int count) {
    if (isDisposed) {
      throw StateError('Cannot allocate from disposed pool');
    }

    if (count > available) {
      throw ArgumentError('Not enough space in pool ($available available, requested $count)');
    }

    final result = <Pointer<Point>>[];
    for (var i = 0; i < count; i++) {
      final ptr = allocate();
      if (ptr == null) break;
      result.add(ptr);
    }
    return result;
  }

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

  void freeMany(List<Pointer<Point>> pointers) {
    for (final ptr in pointers) {
      free(ptr);
    }
  }

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

  // Debug method to verify pool state
  String debugState() {
    return 'Pool State:\n' +
        _used.asMap().entries.map((e) =>
        '${e.key}: ${e.value ? "used" : "free"}').join('\n');
  }
}