import 'package:flutter/widgets.dart';

import 'package:la_ui/src/squircle.dart';
import 'package:la_ui/src/theme.dart';

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
    if (width != null || height != null || constraints != null) {
      result = SizedBox(width: width, height: height, child: result);
    }
    if (margin != null) {
      result = Padding(padding: margin!, child: result);
    }
    return result;
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
          Expanded(child: body),
        ],
      ),
    );
    if (safeArea) {
      content = SafeArea(top: topBar == null, child: content);
    }
    return content;
  }
}
