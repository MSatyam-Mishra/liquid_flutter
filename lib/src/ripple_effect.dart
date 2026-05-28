import 'package:flutter/widgets.dart';

import 'core/pool.dart';
import 'core/ripple.dart';

class RippleEffect extends StatefulWidget {
  const RippleEffect({
    required this.source,
    required this.onRipple,
    required this.child,
    this.fireImmediately = false,
    this.label = 'ripple_effect',
    super.key,
  });

  final ReactiveSource source;
  final VoidCallback onRipple;
  final Widget child;
  final bool fireImmediately;
  final String label;

  @override
  State<RippleEffect> createState() => _RippleEffectState();
}

class _RippleEffectState extends State<RippleEffect> {
  Ripple? _ripple;

  @override
  void initState() {
    super.initState();
    _createRipple();
  }

  @override
  void didUpdateWidget(RippleEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source != widget.source ||
        oldWidget.onRipple != widget.onRipple ||
        oldWidget.fireImmediately != widget.fireImmediately) {
      _ripple?.dispose();
      _createRipple();
    }
  }

  void _createRipple() {
    _ripple = Ripple(
      source: widget.source,
      effect: widget.onRipple,
      fireImmediately: widget.fireImmediately,
      label: widget.label,
    );
  }

  @override
  void dispose() {
    _ripple?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
