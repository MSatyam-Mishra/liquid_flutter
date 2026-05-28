typedef LiquidEventData = Map<String, Object?>;

enum LiquidEventType {
  dropSet,
  dropInvalidated,
  poolRecomputed,
  rippleFired,
  streamStarted,
  streamData,
  streamError,
}

final class LiquidEvent {
  LiquidEvent({
    required this.type,
    required this.label,
    LiquidEventData? data,
    DateTime? at,
  })  : data = data ?? const <String, Object?>{},
        at = at ?? DateTime.now();

  final LiquidEventType type;
  final String label;
  final LiquidEventData data;
  final DateTime at;
}

abstract interface class LiquidObserver {
  void onEvent(LiquidEvent event);
}

final class LiquidTimelineObserver implements LiquidObserver {
  LiquidTimelineObserver({this.maxEvents = 300});

  final int maxEvents;
  final List<LiquidEvent> _events = <LiquidEvent>[];

  List<LiquidEvent> get events => List<LiquidEvent>.unmodifiable(_events);

  @override
  void onEvent(LiquidEvent event) {
    _events.add(event);
    if (_events.length > maxEvents) {
      _events.removeRange(0, _events.length - maxEvents);
    }
  }
}

final class LiquidDiagnostics {
  LiquidDiagnostics._();

  static final Set<LiquidObserver> _observers = <LiquidObserver>{};

  static void addObserver(LiquidObserver observer) {
    _observers.add(observer);
  }

  static void removeObserver(LiquidObserver observer) {
    _observers.remove(observer);
  }

  static void emit(LiquidEvent event) {
    for (final LiquidObserver observer in _observers) {
      observer.onEvent(event);
    }
  }

  static void reset() {
    _observers.clear();
  }
}
