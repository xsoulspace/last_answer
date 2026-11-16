import 'package:flutter/widgets.dart';

/// True when the platform asks for reduced motion — the v6 law: chrome
/// event-motion is disabled too (state then renders through posture/color
/// alone, like the creatures).
bool laReducedMotion(final BuildContext context) =>
    MediaQuery.maybeDisableAnimationsOf(context) ?? false;

/// [base] normally, [Duration.zero] under reduced motion — every kit
/// animation duration passes through here.
Duration laMotion(final BuildContext context, final Duration base) =>
    laReducedMotion(context) ? Duration.zero : base;

/// Fades + slightly scales [child] for overlay entry (dialog/menu/toast,
/// the v6 event-motion budget). Under reduced motion this is a plain fade
/// with no scale and no duration.
Widget laOverlayEntryMotion({
  required final BuildContext context,
  required final Animation<double> animation,
  required final Widget child,
  final double fromScale = 0.96,
  final Alignment alignment = Alignment.center,
}) {
  final reduced = laReducedMotion(context);
  final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
  return FadeTransition(
    opacity: curved,
    child: reduced
        ? child
        : ScaleTransition(
            scale: Tween<double>(begin: fromScale, end: 1).animate(curved),
            alignment: alignment,
            child: child,
          ),
  );
}
