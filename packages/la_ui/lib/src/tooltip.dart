import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_portal/flutter_portal.dart';

import 'package:la_ui/src/chrome.dart';
import 'package:la_ui/src/motion.dart';
import 'package:la_ui/src/theme.dart';

/// The kit tooltip: quiet overlay surface, micro type, 600 ms wait, portal-
/// anchored above the child. Replaces Material Tooltip.
class LaTooltip extends StatefulWidget {
  /// Hover-revealed label for [child].
  const LaTooltip({
    required this.message,
    required this.child,
    this.waitDuration = const Duration(milliseconds: 600),
    this.above = true,
    super.key,
  });

  /// Tooltip text.
  final String message;

  /// The hovered widget.
  final Widget child;

  /// Delay before showing.
  final Duration waitDuration;

  /// Show above (default) or below the child.
  final bool above;

  @override
  State<LaTooltip> createState() => _LaTooltipState();
}

class _LaTooltipState extends State<LaTooltip> {
  Timer? _timer;
  bool _visible = false;
  bool _pressed = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _show() {
    if (_visible || _pressed) {
      return;
    }
    setState(() => _visible = true);
  }

  void _hide() {
    _timer?.cancel();
    if (_visible) {
      setState(() => _visible = false);
    }
  }

  @override
  Widget build(final BuildContext context) {
    final theme = context.laUi;
    if (!laHasPortal(context)) {
      // Bare host: no Portal theater — skip the tooltip entirely.
      return widget.child;
    }
    return PortalTarget(
      visible: _visible,
      anchor: Aligned(
        follower: Alignment(0, widget.above ? 1 : -1),
        target: Alignment(0, widget.above ? -1 : 1),
      ),
      // The base-type law for floats (LaDialog.build): a portal follower
      // renders in the theater, OUTSIDE the anchor's ancestors — install
      // the kit base type or MaterialApp's error style underlines the
      // label.
      portalFollower: DefaultTextStyle(
        style: theme.body,
        child: IgnorePointer(
          child: AnimatedOpacity(
            opacity: _visible ? 1 : 0,
            duration: laMotion(context, theme.motionFast),
            child: LaBox(
              color: theme.surfaceOverlay,
              radius: theme.smallRadius,
              border: BorderSide(color: theme.rule),
              floating: true,
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              child: Text(
                widget.message,
                style: theme.micro.copyWith(color: theme.ink),
              ),
            ),
          ),
        ),
      ),
      child: MouseRegion(
        onEnter: (_) {
          _timer?.cancel();
          _timer = Timer(widget.waitDuration, _show);
        },
        onExit: (_) => _hide(),
        child: Listener(
          onPointerDown: (_) {
            _pressed = true;
            _hide();
          },
          onPointerUp: (_) {
            _pressed = false;
          },
          child: widget.child,
        ),
      ),
    );
  }
}
