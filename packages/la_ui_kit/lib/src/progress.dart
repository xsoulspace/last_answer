import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:la_ui_kit/src/motion.dart';
import 'package:la_ui_kit/src/theme.dart';

/// The honest loading arc — a spinner is durable-status-adjacent, so DESIGN's
/// "never substitute a spinner for durable status" still binds WHERE it is
/// used; the kit only owns the paint. Replaces CircularProgressIndicator.
class LaSpinner extends StatefulWidget {
  /// A rotating accent arc.
  const LaSpinner({
    this.size = 18,
    this.strokeWidth = 2,
    this.color,
    super.key,
  });

  /// Diameter.
  final double size;

  /// Arc stroke.
  final double strokeWidth;

  /// Arc color (defaults to accent).
  final Color? color;

  @override
  State<LaSpinner> createState() => _LaSpinnerState();
}

class _LaSpinnerState extends State<LaSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  // NOTE (test-pass sweep 2026-11-16): the previous initState override
  // called laReducedMotion(context) — a MediaQuery dependency lookup —
  // which is illegal before initState completes (framework assert:
  // dependOnInheritedElement() called before initState() completed) and
  // threw on every LaSpinner mount under a MaterialApp in debug/tests.
  // didChangeDependencies below runs immediately after initState and
  // owns the whole reduced-motion decision, so the override is gone.

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (laReducedMotion(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final theme = context.laUi;
    final color = widget.color ?? theme.accent;
    return SizedBox.square(
      dimension: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _SpinnerPainter(
            progress: _controller.value,
            color: color,
            strokeWidth: widget.strokeWidth,
          ),
        ),
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  const _SpinnerPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final double strokeWidth;

  @override
  void paint(final Canvas canvas, final Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final start = progress * math.pi * 2;
    // Static quarter arc under reduced motion; sweeping arc otherwise.
    const sweep = 0.25 * math.pi * 2;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(final _SpinnerPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

/// The determinate 2 px bar (progress law: linearMinHeight 2). Replaces
/// LinearProgressIndicator.
class LaProgress extends StatelessWidget {
  /// A determinate bar; [value] in 0..1 (null renders a quiet track).
  const LaProgress({
    required this.value,
    this.color,
    this.trackColor,
    this.height = 2,
    super.key,
  });

  /// Completion 0..1.
  final double? value;

  /// Fill (defaults to accent).
  final Color? color;

  /// Track (defaults to rule).
  final Color? trackColor;

  /// Bar height.
  final double height;

  @override
  Widget build(final BuildContext context) {
    final theme = context.laUi;
    final v = (value ?? 0).clamp(0.0, 1.0);
    return SizedBox(
      height: height,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) => Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: trackColor ?? theme.rule)),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: constraints.maxWidth * v,
              child: ColoredBox(color: color ?? theme.accent),
            ),
          ],
        ),
      ),
    );
  }
}
