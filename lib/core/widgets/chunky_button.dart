import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../theme/app_palette.dart';

/// Primary action with a solid 4dp edge and a tactile pressed position.
class ChunkyButton extends StatefulWidget {
  const ChunkyButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
    this.radius = 16,
  }) : outlined = false;
  ChunkyButton.icon({
    super.key,
    required this.onPressed,
    required Widget icon,
    required Widget label,
    this.style,
    this.radius = 16,
  }) : outlined = false,
       child = Row(
         mainAxisSize: MainAxisSize.min,
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
           icon,
           const SizedBox(width: 8),
           Flexible(child: label),
         ],
       );
  const ChunkyButton.secondary({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
    this.radius = 16,
  }) : outlined = true;
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;
  final bool outlined;
  final double radius;
  @override
  State<ChunkyButton> createState() => _ChunkyButtonState();
}

class _ChunkyButtonState extends State<ChunkyButton> {
  late final _states = WidgetStatesController({
    if (widget.onPressed == null) WidgetState.disabled,
  })..addListener(_changed);
  bool _pressed = false;
  void _changed() {
    final pressed = _states.value.contains(WidgetState.pressed);
    if (pressed == _pressed) return;
    void update() {
      if (mounted) setState(() => _pressed = pressed);
    }

    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) => update());
    } else {
      update();
    }
  }

  @override
  void dispose() {
    _states.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(widget.radius),
    );
    final style = FilledButton.styleFrom(
      minimumSize: const Size(64, 56),
      shape: shape,
      elevation: 0,
      backgroundColor: widget.outlined ? p.surface : p.primary,
      foregroundColor: widget.outlined ? p.ink : p.onPrimary,
      disabledBackgroundColor: p.muted,
      disabledForegroundColor: p.inkMuted,
      side: widget.outlined
          ? BorderSide(color: p.outline, width: 2)
          : BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      textStyle: Theme.of(context).textTheme.labelLarge
          ?.copyWith(fontWeight: FontWeight.w700),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ).merge(widget.style);
    final pressed = widget.onPressed != null && _pressed;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Transform.translate(
        offset: Offset(0, pressed ? 4 : 0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            boxShadow: [
              if (widget.onPressed != null && !pressed)
                BoxShadow(
                  color: widget.outlined ? p.outline : p.primaryEdge,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: FilledButton(
            statesController: _states,
            onPressed: widget.onPressed,
            style: style,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
