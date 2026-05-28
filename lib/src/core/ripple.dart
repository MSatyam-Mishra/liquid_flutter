import 'diagnostics.dart';
import 'pool.dart';

class Ripple {
  Ripple({
    required ReactiveSource source,
    required void Function() effect,
    this.label = 'ripple',
    bool fireImmediately = false,
  })  : _source = source,
        _effect = effect {
    _source.addListener(_onSourceChanged);
    if (fireImmediately) {
      _onSourceChanged();
    }
  }

  final ReactiveSource _source;
  final void Function() _effect;
  final String label;
  bool _disposed = false;

  void _onSourceChanged() {
    if (_disposed) {
      return;
    }
    _effect();
    LiquidDiagnostics.emit(
      LiquidEvent(
        type: LiquidEventType.rippleFired,
        label: label,
        data: <String, Object?>{'source': _source.label},
      ),
    );
  }

  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _source.removeListener(_onSourceChanged);
  }
}
