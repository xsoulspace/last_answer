import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import 'package:la_ui/src/theme.dart';

/// The kit scroll behavior: precise desktop dragging (all pointer kinds),
/// no glow/overscroll indicator, the thin 6 px scrollbar. Wrap a scrolling
/// region (or the whole app) once.
class LaScrollBehavior extends ScrollBehavior {
  /// Kit scroll behavior.
  const LaScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    final BuildContext context,
    final Widget child,
    final ScrollableDetails details,
  ) => child;

  @override
  Widget buildScrollbar(
    final BuildContext context,
    final Widget child,
    final ScrollableDetails details,
  ) {
    switch (getPlatform(context)) {
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return RawScrollbar(
          controller: details.controller,
          thickness: 6,
          radius: const Radius.circular(3),
          thumbColor: LaUiTheme.of(context).rule,
          child: child,
        );
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.iOS:
        return child;
    }
  }

  @override
  Set<PointerDeviceKind> get dragDevices => const {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}

/// Applies [LaScrollBehavior] to [child] — the scrollable-region wrapper.
class LaScrollArea extends StatelessWidget {
  /// Kit scroll behavior for a subtree.
  const LaScrollArea({required this.child, super.key});

  /// The subtree (usually a scroll view).
  final Widget child;

  @override
  Widget build(final BuildContext context) =>
      ScrollConfiguration(behavior: const LaScrollBehavior(), child: child);
}

/// Convenience: a vertical list with the kit scroll behavior applied.
class LaListView extends StatelessWidget {
  /// A scrollable column of children with kit scroll grammar.
  const LaListView({
    required this.children,
    this.padding,
    this.controller,
    this.primary,
    super.key,
  });

  /// The rows.
  final List<Widget> children;

  /// Content padding.
  final EdgeInsetsGeometry? padding;

  /// External controller.
  final ScrollController? controller;

  /// Primary scroll view flag.
  final bool? primary;

  @override
  Widget build(final BuildContext context) => LaScrollArea(
    child: SingleChildScrollView(
      controller: controller,
      primary: primary,
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    ),
  );
}
