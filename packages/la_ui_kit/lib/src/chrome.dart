import 'package:flutter/widgets.dart';

import 'pressable.dart';
import 'squircle.dart';
import 'theme.dart';

/// The one-pixel hairline (DESIGN.md §Spacing): between meaningful regions
/// only. Replaces Divider/VerticalDivider.
class LaHairline extends StatelessWidget {
  /// A horizontal hairline; [vertical] flips it.
  const LaHairline({
    this.vertical = false,
    this.color,
    this.indent = 0,
    this.endIndent = 0,
    super.key,
  });

  /// Draw as a vertical rule.
  final bool vertical;

  /// Override the rule token.
  final Color? color;

  /// Leading inset.
  final double indent;

  /// Trailing inset.
  final double endIndent;

  @override
  Widget build(final BuildContext context) {
    final theme = context.laUi;
    return vertical
        ? Padding(
            padding: EdgeInsets.symmetric(vertical: indent == 0 ? 0 : indent),
            child: SizedBox(
              width: 1,
              child: ColoredBox(color: color ?? theme.rule),
            ),
          )
        : Padding(
            padding: EdgeInsets.symmetric(
              horizontal: indent != 0 || endIndent != 0 ? 0 : 0,
            ),
            child: SizedBox(
              height: 1,
              width: double.infinity,
              child: Padding(
                padding: EdgeInsetsDirectional.only(
                  start: indent,
                  end: endIndent,
                ),
                child: ColoredBox(color: color ?? theme.rule),
              ),
            ),
          );
  }
}

/// The kit surface container: a squircle-painted box (fill / hairline /
/// the ONE floating shadow). The quiet card — used sparingly, since the law
/// prefers alignment + whitespace over boxes.
class LaBox extends StatelessWidget {
  /// A filled/stroked squircle surface.
  const LaBox({
    required this.child,
    this.color,
    this.radius,
    this.border,
    this.floating = false,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.constraints,
    this.onTap,
    super.key,
  });

  /// Content.
  final Widget child;

  /// Fill (null = transparent).
  final Color? color;

  /// Corner radii (defaults to the control radius).
  final BorderRadius? radius;

  /// Hairline stroke.
  final BorderSide? border;

  /// Earn the one floating shadow (menus/popovers/miniwindows).
  final bool floating;

  /// Inner inset.
  final EdgeInsetsGeometry? padding;

  /// Outer space.
  final EdgeInsetsGeometry? margin;

  /// Fixed width.
  final double? width;

  /// Fixed height.
  final double? height;

  /// Box constraints.
  final BoxConstraints? constraints;

  /// Optional tap (wraps in a non-state-painting LaPressable-free gesture).
  final VoidCallback? onTap;

  @override
  Widget build(final BuildContext context) {
    final theme = context.laUi;
    Widget result = DecoratedBox(
      decoration: squircleDecoration(
        color: color,
        radius: radius ?? theme.controlRadius,
        side: border,
        shadows: floating ? theme.floatingShadow : null,
        exponent: theme.squircleExponent,
      ),
      child: padding == null ? child : Padding(padding: padding!, child: child),
    );
    if (onTap != null) {
      result = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: result,
      );
    }
    if (width != null || height != null) {
      result = SizedBox(width: width, height: height, child: result);
    }
    if (constraints != null) {
      result = ConstrainedBox(constraints: constraints!, child: result);
    }
    if (margin != null) {
      result = Padding(padding: margin!, child: result);
    }
    return result;
  }
}

/// The kit tab strip: quiet labels, the ONE accent underline on the
/// selected tab (the shell tab law at content scale). The caller owns the
/// selected index and the pager; the strip owns the look.
class LaTabStrip extends StatelessWidget {
  /// A tab strip over [labels].
  const LaTabStrip({
    required this.labels,
    required this.currentIndex,
    required this.onTap,
    this.centerAligned = false,
    this.height = 40,
    super.key,
  });

  /// Tab labels in order.
  final List<String> labels;

  /// The selected tab index.
  final int currentIndex;

  /// Tab activation.
  final ValueChanged<int> onTap;

  /// Center the row (scrollable secondary tabs) instead of filling.
  final bool centerAligned;

  /// Strip height.
  final double height;

  @override
  Widget build(final BuildContext context) {
    final theme = context.laUi;
    final tabs = <Widget>[
      for (final (index, label) in labels.indexed)
        LaPressable(
          onTap: () => onTap(index),
          selected: currentIndex == index,
          radius: BorderRadius.zero,
          scaleOnPress: false,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: currentIndex == index
                    ? theme.control.copyWith(
                        color: theme.ink,
                        fontWeight: FontWeight.w600,
                      )
                    : theme.control.copyWith(color: theme.inkMuted),
              ),
              const SizedBox(height: 4),
              // The 2px accent underline — the selected-tab marker.
              AnimatedContainer(
                duration: theme.motionFast,
                curve: theme.motionCurve,
                height: 2,
                width: 36,
                decoration: ShapeDecoration(
                  color: currentIndex == index
                      ? theme.accent
                      : const Color(0x00000000),
                  shape: const SquircleShape(
                    radius: BorderRadius.all(Radius.circular(1)),
                  ),
                ),
              ),
            ],
          ),
        ),
    ];
    return SizedBox(
      height: height,
      child: centerAligned
          ? Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(mainAxisSize: MainAxisSize.min, children: tabs),
              ),
            )
          : Row(children: [for (final tab in tabs) Expanded(child: tab)]),
    );
  }
}

/// The quiet top bar (44 px): leading / title / trailing over the surface,
/// hairline under. Replaces AppBar's grammar without its metrics.
class LaTopBar extends StatelessWidget {
  /// A chrome header row.
  const LaTopBar({
    this.leading,
    this.title,
    this.titleText,
    this.trailing,
    this.height = 44,
    this.hairline = true,
    this.background,
    this.padding = const EdgeInsets.symmetric(horizontal: 8),
    super.key,
  });

  /// Left slot (back affordance, creature).
  final Widget? leading;

  /// Title widget.
  final Widget? title;

  /// Title as text (emphasis style).
  final String? titleText;

  /// Right slot (actions).
  final Widget? trailing;

  /// Bar height.
  final double height;

  /// Draw the hairline under the bar.
  final bool hairline;

  /// Background override (defaults to the surface token).
  final Color? background;

  /// Inner padding.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(final BuildContext context) {
    final theme = context.laUi;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background ?? theme.surface,
        border: hairline ? Border(bottom: BorderSide(color: theme.rule)) : null,
      ),
      child: SizedBox(
        height: height,
        child: Padding(
          padding: padding,
          child: Row(
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 8)],
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child:
                      title ??
                      (titleText != null
                          ? Text(
                              titleText!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.emphasis,
                            )
                          : const SizedBox.shrink()),
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            ],
          ),
        ),
      ),
    );
  }
}

/// The kit screen scaffold: canvas background + safe areas + optional
/// [LaTopBar] + body. Replaces Scaffold's grammar (no Material surface
/// stack, no SnackBar slot — toasts ride the root overlay).
class LaScaffold extends StatelessWidget {
  /// A screen: canvas, optional top bar, body.
  const LaScaffold({
    required this.body,
    this.topBar,
    this.background,
    this.safeArea = true,
    this.extendBodyBehindTopBar = false,
    super.key,
  });

  /// Screen content.
  final Widget body;

  /// Optional quiet header.
  final Widget? topBar;

  /// Background override (defaults to the canvas token).
  final Color? background;

  /// Apply SafeArea insets.
  final bool safeArea;

  /// Reserved for future immersive layouts.
  final bool extendBodyBehindTopBar;

  @override
  Widget build(final BuildContext context) {
    final theme = context.laUi;
    Widget content = ColoredBox(
      color: background ?? theme.canvas,
      child: Column(
        children: [
          ?topBar,
          // The kit owns the body's base type — a bare MaterialApp test host
          // would otherwise bleed its error style into plain Text children.
          Expanded(
            child: DefaultTextStyle(style: theme.body, child: body),
          ),
        ],
      ),
    );
    if (safeArea) {
      content = SafeArea(top: topBar == null, child: content);
    }
    return content;
  }
}
