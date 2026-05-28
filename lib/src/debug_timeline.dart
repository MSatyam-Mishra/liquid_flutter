import 'package:flutter/foundation.dart';

import 'core/diagnostics.dart';

class LiquidDebugTimeline extends ChangeNotifier implements LiquidObserver {
  LiquidDebugTimeline({this.maxEvents = 300})
      : _buffer = <LiquidEvent>[],
        _attached = false;

  final int maxEvents;
  final List<LiquidEvent> _buffer;
  bool _attached;

  List<LiquidEvent> get events => List<LiquidEvent>.unmodifiable(_buffer);

  void attach() {
    if (_attached) {
      return;
    }
    LiquidDiagnostics.addObserver(this);
    _attached = true;
  }

  void detach() {
    if (!_attached) {
      return;
    }
    LiquidDiagnostics.removeObserver(this);
    _attached = false;
  }

  @override
  void onEvent(LiquidEvent event) {
    _buffer.add(event);
    if (_buffer.length > maxEvents) {
      _buffer.removeRange(0, _buffer.length - maxEvents);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    detach();
    super.dispose();
  }
}
