import 'package:flutter/widgets.dart';
import 'package:liquid_core/liquid_core.dart';

class LiquidScope extends InheritedWidget {
  const LiquidScope({
    required this.tub,
    required super.child,
    super.key,
  });

  final Tub tub;

  static Tub of(BuildContext context) {
    final LiquidScope? scope =
        context.dependOnInheritedWidgetOfExactType<LiquidScope>();
    if (scope == null) {
      throw FlutterError('No LiquidScope found in widget tree.');
    }
    return scope.tub;
  }

  static Tub? maybeOf(BuildContext context) {
    final LiquidScope? scope =
        context.dependOnInheritedWidgetOfExactType<LiquidScope>();
    return scope?.tub;
  }

  @override
  bool updateShouldNotify(LiquidScope oldWidget) => tub != oldWidget.tub;
}
