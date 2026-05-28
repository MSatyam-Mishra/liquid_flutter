import 'diagnostics.dart';
import 'drop.dart';

typedef ComputePool<T> = T Function();

abstract interface class ReactiveSource {
  String get label;
  void addListener(LiquidListener listener);
  void removeListener(LiquidListener listener);
}

final class DependencyCollector {
  DependencyCollector._();

  static final List<Set<ReactiveSource>> _stack = <Set<ReactiveSource>>[];

  static T collect<T>(Set<ReactiveSource> target, T Function() read) {
    _stack.add(target);
    try {
      return read();
    } finally {
      _stack.removeLast();
    }
  }

  static void capture(Object source) {
    if (_stack.isEmpty || source is! ReactiveSource) {
      return;
    }
    _stack.last.add(source);
  }
}

class Pool<T> implements ReadDrop<T>, ReactiveSource {
  Pool(this._compute, {String? label}) : label = label ?? 'pool<$T>';

  final ComputePool<T> _compute;
  @override
  final String label;
  final Set<LiquidListener> _listeners = <LiquidListener>{};
  final Set<ReactiveSource> _dependencies = <ReactiveSource>{};

  T? _value;
  bool _hasValue = false;
  bool _dirty = true;
  bool _disposed = false;

  @override
  T get value {
    _assertNotDisposed();
    DependencyCollector.capture(this);
    if (_dirty || !_hasValue) {
      _recompute();
    }
    return _value as T;
  }

  @override
  void addListener(LiquidListener listener) {
    _assertNotDisposed();
    _listeners.add(listener);
  }

  @override
  void removeListener(LiquidListener listener) {
    _listeners.remove(listener);
  }

  void invalidate() {
    _assertNotDisposed();
    _markDirty();
  }

  void dispose() {
    _disposed = true;
    for (final ReactiveSource source in _dependencies) {
      source.removeListener(_markDirty);
    }
    _dependencies.clear();
    _listeners.clear();
  }

  void _recompute() {
    final Set<ReactiveSource> nextDependencies = <ReactiveSource>{};
    final T next = DependencyCollector.collect(nextDependencies, _compute);
    final Set<ReactiveSource> toRemove = _dependencies.difference(nextDependencies);
    final Set<ReactiveSource> toAdd = nextDependencies.difference(_dependencies);

    for (final ReactiveSource source in toRemove) {
      source.removeListener(_markDirty);
    }
    for (final ReactiveSource source in toAdd) {
      source.addListener(_markDirty);
    }

    _dependencies
      ..clear()
      ..addAll(nextDependencies);

    _value = next;
    _dirty = false;
    _hasValue = true;
    LiquidDiagnostics.emit(
      LiquidEvent(
        type: LiquidEventType.poolRecomputed,
        label: label,
        data: <String, Object?>{'deps': nextDependencies.length},
      ),
    );
  }

  void _markDirty() {
    if (_disposed || _dirty) {
      return;
    }
    _dirty = true;
    for (final LiquidListener listener in List<LiquidListener>.from(_listeners)) {
      listener();
    }
  }

  void _assertNotDisposed() {
    if (_disposed) {
      throw StateError('Pool "$label" was already disposed.');
    }
  }
}
