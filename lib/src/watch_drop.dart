import 'package:flutter/widgets.dart';

import 'core/drop.dart';

typedef WatchDropBuilder<T> = Widget Function(
  BuildContext context,
  T value,
  Widget? child,
);

typedef Selector<T, S> = S Function(T value);

class WatchDrop<T, S> extends StatefulWidget {
  const WatchDrop({
    required this.source,
    required this.builder,
    required this.select,
    this.child,
    super.key,
  });

  final ReadDrop<T> source;
  final Selector<T, S> select;
  final WatchDropBuilder<S> builder;
  final Widget? child;

  @override
  State<WatchDrop<T, S>> createState() => _WatchDropState<T, S>();
}

class _WatchDropState<T, S> extends State<WatchDrop<T, S>> {
  late S _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.select(widget.source.value);
    widget.source.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(WatchDrop<T, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source != widget.source) {
      oldWidget.source.removeListener(_onChanged);
      _selected = widget.select(widget.source.value);
      widget.source.addListener(_onChanged);
    }
  }

  @override
  void dispose() {
    widget.source.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (!mounted) {
      return;
    }
    final S next = widget.select(widget.source.value);
    if (_selected == next) {
      return;
    }
    setState(() {
      _selected = next;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _selected, widget.child);
  }
}
