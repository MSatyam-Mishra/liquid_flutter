# liquid_flutter

`liquid_flutter` is the Flutter package for **Liquid** state management.
Liquid follows **Onion Architecture** with clear boundaries between
presentation, application, domain, and infrastructure.

Use this package when you want lightweight reactive state in Flutter with explicit scope ownership and granular rebuild control.

## Features

- `LiquidScope` for dependency-free `Tub` access in widget trees
- `WatchDrop<T, S>` with selector-based rebuild minimization
- `RippleEffect` for lifecycle-safe side effects
- `LiquidDebugTimeline` for debug UIs and event feeds
- Full re-export of `liquid_core` primitives

## Installation (pub.dev)

```yaml
dependencies:
  liquid_flutter: ^0.1.0
```

Then run:

```bash
flutter pub get
```

## Usage

### Example 1: Counter with `WatchDrop`

```dart
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  late final Tub tub;
  late final Drop<int> count;

  @override
  void initState() {
    super.initState();
    tub = Tub(label: 'counter_page');
    count = tub.drop<int>('count', 0, label: 'count');
  }

  @override
  void dispose() {
    tub.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LiquidScope(
      tub: tub,
      child: Column(
        children: [
          WatchDrop<int, int>(
            source: count,
            select: (value) => value,
            builder: (_, value, __) => Text('Count: $value'),
          ),
          ElevatedButton(
            onPressed: () => count.value = count.value + 1,
            child: const Text('Increment'),
          ),
        ],
      ),
    );
  }
}
```

### Example 2: Granular rebuild with selector

```dart
import 'package:flutter/widgets.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class EvenOddBadge extends StatelessWidget {
  const EvenOddBadge({required this.count, super.key});
  final Drop<int> count;

  @override
  Widget build(BuildContext context) {
    return WatchDrop<int, bool>(
      source: count,
      select: (value) => value.isEven,
      builder: (_, isEven, __) {
        return Text(isEven ? 'EVEN' : 'ODD');
      },
    );
  }
}
```

In this pattern, the widget rebuilds only when parity changes (even -> odd or odd -> even), not on every count value.

### Example 3: Side effects with `RippleEffect`

```dart
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class LoginEffectView extends StatelessWidget {
  const LoginEffectView({required this.authState, super.key});

  final Drop<String> authState;

  @override
  Widget build(BuildContext context) {
    return RippleEffect(
      source: authState,
      onRipple: () {
        if (authState.value == 'authenticated') {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      },
      child: const SizedBox.shrink(),
    );
  }
}
```

### Example 4: Debug timeline panel

```dart
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class EventConsole extends StatefulWidget {
  const EventConsole({super.key});

  @override
  State<EventConsole> createState() => _EventConsoleState();
}

class _EventConsoleState extends State<EventConsole> {
  final timeline = LiquidDebugTimeline(maxEvents: 200);

  @override
  void initState() {
    super.initState();
    timeline.attach();
  }

  @override
  void dispose() {
    timeline.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: timeline,
      builder: (context, _) {
        final events = timeline.events.reversed.take(20).toList();
        return ListView(
          children: [
            for (final e in events) Text('${e.type.name}: ${e.label}'),
          ],
        );
      },
    );
  }
}
```

## Recommended Structure in Flutter Apps

- Create one `Tub` per feature/page scope.
- Create `Drop`s in stateful owner classes or module coordinators.
- Use `Flow` for computed/read-only projections.
- Use `WatchDrop` selectors for performance-sensitive areas.
- Dispose `Tub` in `State.dispose`.

## Full Example App

This package includes a complete Feature Catalog counter demo in:

- `example/`

The catalog lists Liquid features on one screen. Tapping a feature opens a counter-focused showcase screen for that feature. It demonstrates:

- `Drop`, `Flow`, `Tub`, `Ripple`, `StreamDrop`
- nested state counters (parent/child + derived total)
- search state over generated counter values
- editor state (character count)
- folder hierarchy state (depth-weighted counter)
- theme state (light/dark toggle)

Run it with:

```bash
cd packages/liquid_flutter/example
flutter pub get
flutter run
```

## Onion Architecture Fit

- Presentation:
  - widgets read from Drops/Flows via `WatchDrop`
  - side effects via `RippleEffect`
- Application:
  - owns Tub and mutation commands
- Domain:
  - independent of Flutter
- Infrastructure:
  - pushes data into `StreamDrop` or commands
