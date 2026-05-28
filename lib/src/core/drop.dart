import 'diagnostics.dart';
import 'pool.dart';

typedef LiquidListener = void Function();

abstract interface class ReadDrop<T> {
  T get value;
  void addListener(LiquidListener listener);
  void removeListener(LiquidListener listener);
}

class Drop<T> implements ReadDrop<T>, ReactiveSource {
  Drop(this._value, {String? label}) : label = label ?? 'drop<$T>';

  @override
  final String label;
  final Set<LiquidListener> _listeners = <LiquidListener>{};
  T _value;
  bool _disposed = false;

  bool get isDisposed => _disposed;

  @override
  T get value {
    _assertNotDisposed();
    DependencyCollector.capture(this);
    return _value;
  }

  set value(T next) {
    _assertNotDisposed();
    if (_value == next) {
      return;
    }
    _value = next;
    LiquidDiagnostics.emit(
      LiquidEvent(
        type: LiquidEventType.dropSet,
        label: label,
        data: <String, Object?>{'value': next},
      ),
    );
    _notify();
  }

  void update(T Function(T current) transform) {
    value = transform(value);
  }

  void invalidate() {
    _assertNotDisposed();
    LiquidDiagnostics.emit(
      LiquidEvent(type: LiquidEventType.dropInvalidated, label: label),
    );
    _notify();
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

  void dispose() {
    _disposed = true;
    _listeners.clear();
  }

  void _notify() {
    for (final LiquidListener listener in List<LiquidListener>.from(_listeners)) {
      listener();
    }
  }

  void _assertNotDisposed() {
    if (_disposed) {
      throw StateError('Drop "$label" was already disposed.');
    }
  }
}
