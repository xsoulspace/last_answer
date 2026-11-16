import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

/// The v6 squircle law as geometry: a continuous-curvature superellipse
/// rounded-rect path (the Discord/iOS corner grammar). `|x/a|^n + |y/b|^n = 1`
/// with n = [exponent] (default 4) replaces the circular-arc corner; sampled
/// as a polyline dense enough to be visually exact.
///
/// Per-corner radii come from a [BorderRadius]; a zero-radius corner stays a
/// sharp 90° join.
ui.Path squirclePath(
  final Rect rect, {
  final BorderRadius borderRadius = BorderRadius.zero,
  final double exponent = 4,
}) {
  final radii = borderRadius.resolve(TextDirection.ltr);
  final path = ui.Path();
  final p = 2 / math.max(1.0001, exponent);

  void corner({
    required ui.Radius radius,
    required Offset center,
    required double sx,
    required double sy,
    required bool cosFirst,
  }) {
    if (radius.x <= 0 || radius.y <= 0) {
      return;
    }
    final steps = (math.max(radius.x, radius.y) / 1.5).clamp(8, 32).ceil();
    for (var i = 1; i <= steps; i++) {
      final t = (math.pi / 2) * i / steps;
      final c = math.pow(math.cos(t).abs(), p).toDouble();
      final s = math.pow(math.sin(t).abs(), p).toDouble();
      final dx = cosFirst ? c : s;
      final dy = cosFirst ? s : c;
      path.lineTo(
        center.dx + sx * radius.x * dx,
        center.dy + sy * radius.y * dy,
      );
    }
  }

  final tl = radii.topLeft;
  final tr = radii.topRight;
  final br = radii.bottomRight;
  final bl = radii.bottomLeft;

  path.moveTo(rect.left, rect.top + tl.y);
  // Top-left: (left, top+ry) → (left+rx, top).
  corner(
    radius: tl,
    center: Offset(rect.left + tl.x, rect.top + tl.y),
    sx: -1,
    sy: -1,
    cosFirst: true,
  );
  path.lineTo(rect.right - tr.x, rect.top);
  // Top-right: (right-rx, top) → (right, top+ry).
  corner(
    radius: tr,
    center: Offset(rect.right - tr.x, rect.top + tr.y),
    sx: 1,
    sy: -1,
    cosFirst: false,
  );
  path.lineTo(rect.right, rect.bottom - br.y);
  // Bottom-right: (right, bottom-ry) → (right-rx, bottom).
  corner(
    radius: br,
    center: Offset(rect.right - br.x, rect.bottom - br.y),
    sx: 1,
    sy: 1,
    cosFirst: true,
  );
  path.lineTo(rect.left + bl.x, rect.bottom);
  // Bottom-left: (left+rx, bottom) → (left, bottom-ry).
  corner(
    radius: bl,
    center: Offset(rect.left + bl.x, rect.bottom - bl.y),
    sx: -1,
    sy: 1,
    cosFirst: false,
  );
  path.close();
  return path;
}

/// The kit's [ShapeBorder] — a squircle outline that composes with
/// [ShapeDecoration], `ShapeBorder` APIs and the kit painters. Replaces
/// `RoundedRectangleBorder` everywhere the kit draws a corner (v6).
@immutable
class SquircleShape extends ShapeBorder {
  /// A superellipse border with optional [side] stroke.
  const SquircleShape({
    this.radius = const BorderRadius.all(Radius.circular(8)),
    this.side = BorderSide.none,
    this.exponent = 4,
  });

  /// Per-corner radii (a [BorderRadius], squircle-swept).
  final BorderRadius radius;

  /// The hairline/stroke to paint along the edge.
  final BorderSide side;

  /// Superellipse exponent (4 ≈ Discord/iOS continuity).
  final double exponent;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  @override
  ui.Path getInnerPath(final Rect rect, {final TextDirection? textDirection}) =>
      squirclePath(
        rect.deflate(side.width),
        borderRadius: radius,
        exponent: exponent,
      );

  @override
  ui.Path getOuterPath(final Rect rect, {final TextDirection? textDirection}) =>
      squirclePath(rect, borderRadius: radius, exponent: exponent);

  @override
  void paint(
    final Canvas canvas,
    final Rect rect, {
    final TextDirection? textDirection,
  }) {
    if (side.style == BorderStyle.none ||
        side.width <= 0 ||
        side.color.a == 0) {
      return;
    }
    final half = side.width / 2;
    final strokeRect = rect.deflate(half);
    canvas.drawPath(
      squirclePath(
        strokeRect,
        borderRadius: _deflateRadius(half),
        exponent: exponent,
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = side.width
        ..color = side.color,
    );
  }

  BorderRadius _deflateRadius(final double delta) {
    ui.Radius shrink(final ui.Radius r) => ui.Radius.elliptical(
      math.max(0, r.x - delta),
      math.max(0, r.y - delta),
    );

    return BorderRadius.only(
      topLeft: shrink(radius.topLeft),
      topRight: shrink(radius.topRight),
      bottomLeft: shrink(radius.bottomLeft),
      bottomRight: shrink(radius.bottomRight),
    );
  }

  @override
  ShapeBorder scale(final double t) => SquircleShape(
    radius: BorderRadius.only(
      topLeft: radius.topLeft * t,
      topRight: radius.topRight * t,
      bottomLeft: radius.bottomLeft * t,
      bottomRight: radius.bottomRight * t,
    ),
    side: side.scale(t),
    exponent: exponent,
  );

  @override
  bool operator ==(final Object other) =>
      other is SquircleShape &&
      other.radius == radius &&
      other.side == side &&
      other.exponent == exponent;

  @override
  int get hashCode => Object.hash(radius, side, exponent);
}

/// Sugar for the common decoration: a filled (and optionally stroked/shadowed)
/// squircle surface.
ShapeDecoration squircleDecoration({
  final Color? color,
  final BorderRadius radius = const BorderRadius.all(Radius.circular(8)),
  final BorderSide? side,
  final List<BoxShadow>? shadows,
  final double exponent = 4,
}) => ShapeDecoration(
  color: color,
  shadows: shadows,
  shape: SquircleShape(
    radius: radius,
    side: side ?? BorderSide.none,
    exponent: exponent,
  ),
);

/// Clips [child] to a squircle (v6) — avatars, media cards, thumbnails.
class LaClipSquircle extends StatelessWidget {
  /// Clips with per-corner [radius].
  const LaClipSquircle({
    required this.child,
    this.radius = const BorderRadius.all(Radius.circular(8)),
    this.exponent = 4,
    super.key,
  });

  /// The clipped child.
  final Widget child;

  /// Per-corner radii.
  final BorderRadius radius;

  /// Superellipse exponent.
  final double exponent;

  @override
  Widget build(final BuildContext context) => ClipPath(
    clipper: _SquircleClipper(radius: radius, exponent: exponent),
    child: child,
  );
}

class _SquircleClipper extends CustomClipper<Path> {
  const _SquircleClipper({required this.radius, required this.exponent});

  final BorderRadius radius;
  final double exponent;

  @override
  Path getClip(final Size size) => squirclePath(
    Offset.zero & size,
    borderRadius: radius,
    exponent: exponent,
  );

  @override
  bool shouldReclip(final _SquircleClipper oldClipper) =>
      oldClipper.radius != radius || oldClipper.exponent != exponent;
}
