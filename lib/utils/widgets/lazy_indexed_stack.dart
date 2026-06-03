import 'package:flutter/material.dart';

/// Like [IndexedStack] but only builds a child the first time its index is
/// shown — then keeps it alive via [Offstage] so subsequent visits don't pay
/// a rebuild cost.
///
/// Use for bottom-nav scaffolds where eagerly building every tab on mount
/// causes after-login lag (every tab's controller spins up, every Obx fires,
/// every network call kicks off). With this widget, only the visible tab is
/// built; switching tabs builds them on first reveal.
class LazyIndexedStack extends StatefulWidget {
  final int index;
  final List<WidgetBuilder> builders;
  final AlignmentGeometry alignment;
  final TextDirection? textDirection;
  final StackFit sizing;

  const LazyIndexedStack({
    super.key,
    required this.index,
    required this.builders,
    this.alignment = AlignmentDirectional.topStart,
    this.textDirection,
    this.sizing = StackFit.loose,
  });

  @override
  State<LazyIndexedStack> createState() => _LazyIndexedStackState();
}

class _LazyIndexedStackState extends State<LazyIndexedStack> {
  late List<Widget?> _children;

  @override
  void initState() {
    super.initState();
    _children = List<Widget?>.filled(widget.builders.length, null, growable: false);
    _ensureBuilt(widget.index);
  }

  @override
  void didUpdateWidget(covariant LazyIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.builders.length != widget.builders.length) {
      _children = List<Widget?>.filled(widget.builders.length, null, growable: false);
    }
    _ensureBuilt(widget.index);
  }

  void _ensureBuilt(int idx) {
    if (idx < 0 || idx >= _children.length) return;
    if (_children[idx] == null) {
      _children[idx] = Builder(builder: widget.builders[idx]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: widget.index,
      alignment: widget.alignment,
      textDirection: widget.textDirection,
      sizing: widget.sizing,
      children: List<Widget>.generate(
        _children.length,
        (i) => _children[i] ?? const SizedBox.shrink(),
      ),
    );
  }
}
