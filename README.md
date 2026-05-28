# liquidx

`liquidx` is the Flutter package for **Liquid** state management.
Liquid follows **Onion Architecture** with clear boundaries between
presentation, application, domain, and infrastructure.

Use this package when you want lightweight reactive state in Flutter with explicit scope ownership and granular rebuild control.

## What Is Liquid

Liquid is a scalable reactive state management + dependency scoping approach for Flutter and Dart.
It is designed so core business logic remains isolated from widgets and external systems.

Liquid uses a water-based mental model:

- `Drop`: atomic state
- `Flow`: async state stream model
- `Pool`: derived/business orchestration
- `Ripple`: side-effect reaction
- `Tub`: scoped container + lifecycle owner

## Onion Architecture Mapping

Liquid keeps dependencies flowing inward and uses each component at a clear layer boundary.

| Liquid Component | Typical Onion Layer | Purpose |
| --- | --- | --- |
| `Drop`, `Flow` | Application state boundary (close to domain) | Hold reactive state and async state representations used by use-cases |
| `Pool` | Application layer | Compose and derive business state from Drops |
| `Ripple`, `RippleEffect`, `WatchDrop` | Presentation layer | Trigger and consume UI reactions from state changes |
| `Tub` | Application composition/root | Scope and lifecycle container for feature/module state graphs |
| Repositories, APIs, DB adapters | Infrastructure layer | Feed data into `Drop`/`Flow` through application logic |

Notes for correctness with current implementation:

- `Drop` is mutable through `value` and `update` (not immutable snapshots).
- `Tub` is scoped, not necessarily global.
- `Ripple` reacts on state change; it is not a built-in one-time event queue.

## Features

- `LiquidScope` for dependency-free `Tub` access in widget trees
- `WatchDrop<T, S>` with selector-based rebuild minimization
- `RippleEffect` for lifecycle-safe side effects
- `LiquidDebugTimeline` for debug UIs and event feeds
- Full re-export of `liquidx_core` primitives

## Installation (pub.dev)

```yaml
dependencies:
  liquidx: ^0.1.0
```

Then run:

```bash
flutter pub get
```

## Usage

### Example 1: Counter with `WatchDrop`

```dart
import 'package:flutter/material.dart';
import 'package:liquidx/liquidx.dart';

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
import 'package:liquidx/liquidx.dart';

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
import 'package:liquidx/liquidx.dart';

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
import 'package:liquidx/liquidx.dart';

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
- Use `Pool` for computed/read-only projections.
- Use `WatchDrop` selectors for performance-sensitive areas.
- Dispose `Tub` in `State.dispose`.

## Full Example App

This package includes a complete Feature Catalog counter demo in:

- `example/`

The catalog lists Liquid features on one screen. Tapping a feature opens a counter-focused showcase screen for that feature. It demonstrates:

- `Drop`, `Flow`, `Tub`, `Ripple`, `Pool`
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
  - widgets read from Drops/Pools via `WatchDrop`
  - side effects via `RippleEffect`
- Application:
  - owns Tub and mutation commands
- Domain:
  - independent of Flutter
- Infrastructure:
  - pushes data into `Flow` or commands
