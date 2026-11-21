import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'theme.dart';

/// Chevron glyph drawn as a polyline (no icon-font dependency in the kit).
class LaChevron extends StatelessWidget {
  /// A down/right/up/left chevron.
  const LaChevron({
    this.direction = LaChevronDirection.down,
    this.size = 14,
    this.color,
    this.strokeWidth = 1.75,
    super.key,
  });

  /// Pointing direction.
  final LaChevronDirection direction;

  /// Glyph box size.
  final double size;

  /// Stroke color (defaults to inkMuted).
  final Color? color;

  /// Stroke width.
  final double strokeWidth;

  @override
  Widget build(final BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(
      painter: _ChevronPainter(
        direction: direction,
        color: color ?? context.laUi.inkMuted,
        strokeWidth: strokeWidth,
      ),
    ),
  );
}

/// Chevron pointing.
enum LaChevronDirection { down, right, up, left }

class _ChevronPainter extends CustomPainter {
  const _ChevronPainter({
    required this.direction,
    required this.color,
    required this.strokeWidth,
  });

  final LaChevronDirection direction;
  final Color color;
  final double strokeWidth;

  @override
  void paint(final Canvas canvas, final Size size) {
    final w = size.width;
    final h = size.height;
    // Base "v" shape, then rotated per direction.
    final path = Path()
      ..moveTo(w * 0.25, h * 0.38)
      ..lineTo(w * 0.5, h * 0.62)
      ..lineTo(w * 0.75, h * 0.38);
    final angle = switch (direction) {
      LaChevronDirection.down => 0.0,
      LaChevronDirection.left => math.pi / 2,
      LaChevronDirection.up => math.pi,
      LaChevronDirection.right => -math.pi / 2,
    };
    canvas
      ..translate(w / 2, h / 2)
      ..rotate(angle)
      ..translate(-w / 2, -h / 2)
      ..drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = color,
      );
  }

  @override
  bool shouldRepaint(final _ChevronPainter oldDelegate) =>
      oldDelegate.direction != direction || oldDelegate.color != color;
}

/// Check glyph (menu selection, checkbox).
class LaCheck extends StatelessWidget {
  /// A checkmark.
  const LaCheck({this.size = 14, this.color, this.strokeWidth = 2, super.key});

  /// Glyph box size.
  final double size;

  /// Stroke color (defaults to current ink).
  final Color? color;

  /// Stroke width.
  final double strokeWidth;

  @override
  Widget build(final BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(
      painter: _CheckPainter(
        color: color ?? context.laUi.ink,
        strokeWidth: strokeWidth,
      ),
    ),
  );
}

class _CheckPainter extends CustomPainter {
  const _CheckPainter({required this.color, required this.strokeWidth});

  final Color color;
  final double strokeWidth;

  @override
  void paint(final Canvas canvas, final Size size) {
    final w = size.width;
    final h = size.height;
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.2, h * 0.52)
        ..lineTo(w * 0.42, h * 0.72)
        ..lineTo(w * 0.8, h * 0.28),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(final _CheckPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Close (×) glyph.
class LaClose extends StatelessWidget {
  /// An × mark.
  const LaClose({
    this.size = 14,
    this.color,
    this.strokeWidth = 1.75,
    super.key,
  });

  /// Glyph box size.
  final double size;

  /// Stroke color (defaults to inkMuted).
  final Color? color;

  /// Stroke width.
  final double strokeWidth;

  @override
  Widget build(final BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(
      painter: _ClosePainter(
        color: color ?? context.laUi.inkMuted,
        strokeWidth: strokeWidth,
      ),
    ),
  );
}

class _ClosePainter extends CustomPainter {
  const _ClosePainter({required this.color, required this.strokeWidth});

  final Color color;
  final double strokeWidth;

  @override
  void paint(final Canvas canvas, final Size size) {
    final inset = size.width * 0.26;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas
      ..drawLine(
        Offset(inset, inset),
        Offset(size.width - inset, size.height - inset),
        paint,
      )
      ..drawLine(
        Offset(size.width - inset, inset),
        Offset(inset, size.height - inset),
        paint,
      );
  }

  @override
  bool shouldRepaint(final _ClosePainter oldDelegate) =>
      oldDelegate.color != color;
}
