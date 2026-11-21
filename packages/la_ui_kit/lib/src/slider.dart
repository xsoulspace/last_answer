import 'package:flutter/widgets.dart';

import 'squircle.dart';
import 'theme.dart';

/// The kit slider: 4 px track (rule → accent), 14 px thumb (surface with an
/// accent ring). Replaces Material Slider.
class LaSlider extends StatefulWidget {
  /// A continuous (or [divisions]-snapped) horizontal slider.
  const LaSlider({
    required this.value,
    required this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.enabled = true,
    this.height = 20,
    super.key,
  });

  /// Current value in [min]..[max].
  final double value;

  /// Drag callback.
  final ValueChanged<double> onChanged;

  /// Drag start.
  final ValueChanged<double>? onChangeStart;

  /// Drag end.
  final ValueChanged<double>? onChangeEnd;

  /// Range floor.
  final double min;

  /// Range ceiling.
  final double max;

  /// Snap step count (null = continuous).
  final int? divisions;

  /// Enabled flag.
  final bool enabled;

  /// Widget height (hit area).
  final double height;

  @override
  State<LaSlider> createState() => _LaSliderState();
}

class _LaSliderState extends State<LaSlider> {
  bool _dragging = false;

  double _valueAt(final double dx, final double width) {
    final t =
        ((dx / width).clamp(0.0, 1.0) * (widget.max - widget.min)) + widget.min;
    final divisions = widget.divisions;
    if (divisions == null || divisions <= 0) {
      return t;
    }
    final step = (widget.max - widget.min) / divisions;
    final snapped = (((t - widget.min) / step).round() * step) + widget.min;
    return snapped.clamp(widget.min, widget.max);
  }

  void _update(final double dx, final double width) {
    final v = _valueAt(dx, width);
    if (v != widget.value) {
      widget.onChanged(v);
    }
  }

  @override
  Widget build(final BuildContext context) {
    final theme = context.laUi;
    final fraction = ((widget.value - widget.min) / (widget.max - widget.min))
        .clamp(0.0, 1.0);
    return Semantics(
      slider: true,
      enabled: widget.enabled,
      value: '${widget.value}',
      child: SizedBox(
        height: widget.height,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final thumbX = fraction * width;
            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTapDown: widget.enabled
                  ? (details) => _update(details.localPosition.dx, width)
                  : null,
              onHorizontalDragStart: widget.enabled
                  ? (details) {
                      setState(() => _dragging = true);
                      widget.onChangeStart?.call(widget.value);
                      _update(details.localPosition.dx, width);
                    }
                  : null,
              onHorizontalDragUpdate: widget.enabled
                  ? (details) => _update(details.localPosition.dx, width)
                  : null,
              onHorizontalDragEnd: widget.enabled
                  ? (details) {
                      setState(() => _dragging = false);
                      widget.onChangeEnd?.call(widget.value);
                    }
                  : null,
              onHorizontalDragCancel: widget.enabled
                  ? () => setState(() => _dragging = false)
                  : null,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // Track.
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 7),
                    child: SizedBox(
                      height: 4,
                      width: double.infinity,
                      child: DecoratedBox(
                        decoration: ShapeDecoration(
                          color: widget.enabled
                              ? theme.rule
                              : theme.rule.withValues(alpha: 0.5),
                          shape: const SquircleShape(
                            radius: BorderRadius.all(Radius.circular(2)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Active fill.
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 7),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        height: 4,
                        width: ((width - 14) * fraction).clamp(0.0, width),
                        child: DecoratedBox(
                          decoration: ShapeDecoration(
                            color: widget.enabled
                                ? theme.accent
                                : theme.inkQuiet,
                            shape: const SquircleShape(
                              radius: BorderRadius.all(Radius.circular(2)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Thumb (grows while dragging — the v6 press feedback).
                  Positioned(
                    left: (thumbX - 7).clamp(
                      0.0,
                      (width - 14).clamp(0.0, double.infinity),
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      width: _dragging ? 17 : 14,
                      height: _dragging ? 17 : 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.surface,
                        border: Border.all(
                          color: widget.enabled ? theme.accent : theme.inkQuiet,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
