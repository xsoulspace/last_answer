import 'package:flutter/widgets.dart';

import 'package:la_ui_kit/src/button.dart';
import 'package:la_ui_kit/src/chrome.dart';
import 'package:la_ui_kit/src/icons.dart';
import 'package:la_ui_kit/src/motion.dart';
import 'package:la_ui_kit/src/squircle.dart';
import 'package:la_ui_kit/src/theme.dart';

/// The kit dialog frame: title / description / content / footer grammar
/// (shadcn), quiet scrim, scale-and-fade entry (v6 event motion), squircle
/// floating surface. Replaces AlertDialog + showDialog grammar.
class LaDialog extends StatelessWidget {
  /// A dialog body; host it via [showLaDialog].
  const LaDialog({
    this.title,
    this.titleText,
    this.description,
    this.content,
    this.actions,
    this.leading,
    this.showClose = true,
    this.onClose,
    this.width = 420,
    this.padding = const EdgeInsets.fromLTRB(20, 18, 20, 16),
    super.key,
  });

  /// Title widget.
  final Widget? title;

  /// Title as text (section style, 16 px).
  final String? titleText;

  /// Quiet description line under the title.
  final String? description;

  /// Body content.
  final Widget? content;

  /// Footer actions (right-aligned row).
  final List<Widget>? actions;

  /// Optional leading glyph beside the title.
  final Widget? leading;

  /// Draw the ghost × close affordance.
  final bool showClose;

  /// Close handler (defaults to popping the route).
  final VoidCallback? onClose;

  /// Dialog width.
  final double width;

  /// Inner padding.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(final BuildContext context) {
    final theme = context.laUi;
    // The base-type law for floats: a dialog is hosted in the root
    // navigator's overlay, ABOVE LaChrome's body DefaultTextStyle, so
    // without this the MaterialApp error style (the yellow double
    // underline on every inheriting Text) bleeds in — the chrome.dart
    // body law applied to floating surfaces.
    return DefaultTextStyle(
      style: theme.body,
      child: ConstrainedBox(
        // Height cap: a dialog taller than the viewport must shrink its
        // Flexible content (which scrolls when the host wraps it) instead of
        // pushing controls off-screen (caught live by the consent tests on a
        // 600px window).
        constraints: BoxConstraints(
          maxWidth: width,
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
        child: LaBox(
          color: theme.surfaceOverlay,
          radius: BorderRadius.circular(14),
          border: BorderSide(color: theme.rule),
          floating: true,
          padding: padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null || titleText != null || showClose)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (leading != null) ...[
                      leading!,
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child:
                          title ??
                          Text(
                            titleText ?? '',
                            style: theme.section.copyWith(fontSize: 16),
                          ),
                    ),
                    if (showClose)
                      LaButton.icon(
                        icon: const LaClose(),
                        size: LaButtonSize.sm,
                        onPressed:
                            onClose ??
                            () {
                              Navigator.maybeOf(
                                context,
                                rootNavigator: true,
                              )?.pop();
                            },
                      ),
                  ],
                ),
              if (description != null) ...[
                const SizedBox(height: 6),
                Text(
                  description!,
                  style: theme.compact.copyWith(color: theme.inkMuted),
                ),
              ],
              if (content != null) ...[
                const SizedBox(height: 14),
                Flexible(child: content!),
              ],
              if (actions != null && actions!.isNotEmpty) ...[
                const SizedBox(height: 18),
                // Wrap, not Row: narrow panes (a 320px compact region) must
                // fold the action row to a second line instead of
                // overflowing (caught live by the consent tests).
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  runSpacing: 8,
                  children: actions!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows a kit dialog (quiet scrim, 140 ms scale+fade, barrier-dismissible
/// by default). The [builder] typically returns an [LaDialog].
Future<T?> showLaDialog<T>({
  required final BuildContext context,
  required final WidgetBuilder builder,
  final bool barrierDismissible = true,
  final bool useRootNavigator = true,
  final Alignment alignment = Alignment.center,
}) => showGeneralDialog<T>(
  context: context,
  barrierDismissible: barrierDismissible,
  barrierLabel: 'Dismiss dialog',
  barrierColor: LaUiTheme.of(context).scrim,
  transitionDuration: const Duration(milliseconds: 140),
  useRootNavigator: useRootNavigator,
  // Belt-and-braces on top of LaDialog's own wrap: the builder may return
  // a custom body that is not an LaDialog — it must still get the kit
  // base type, not MaterialApp's error style (nearest wins, so this is
  // harmless when LaDialog installs its own).
  pageBuilder: (context, animation, secondaryAnimation) => DefaultTextStyle(
    style: LaUiTheme.of(context).body,
    child: builder(context),
  ),
  transitionBuilder: (context, animation, secondaryAnimation, child) => Align(
    alignment: alignment,
    child: laOverlayEntryMotion(
      context: context,
      animation: animation,
      child: Padding(padding: const EdgeInsets.all(24), child: child),
    ),
  ),
);

/// The confirm grammar: title, message, one destructive-or-primary confirm,
/// one cancel. Returns true only on confirm.
Future<bool> showLaConfirm(
  final BuildContext context, {
  required final String title,
  final String? message,
  final String confirmLabel = 'Confirm',
  final String cancelLabel = 'Cancel',
  final bool destructive = false,
  final Widget? content,
}) async {
  final result = await showLaDialog<bool>(
    context: context,
    builder: (context) => LaDialog(
      titleText: title,
      description: message,
      width: 380,
      content: content,
      showClose: false,
      actions: [
        LaButton(
          label: cancelLabel,
          variant: LaButtonVariant.ghost,
          onPressed: () =>
              Navigator.of(context, rootNavigator: true).pop(false),
        ),
        LaButton(
          label: confirmLabel,
          variant: destructive
              ? LaButtonVariant.destructive
              : LaButtonVariant.primary,
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(true),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Convenience confirm widget for inline use (same grammar as
/// [showLaConfirm]).
class LaConfirm extends StatelessWidget {
  /// An inline confirm dialog body.
  const LaConfirm({
    required this.title,
    this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.destructive = false,
    this.onConfirm,
    this.onCancel,
    super.key,
  });

  /// Dialog title.
  final String title;

  /// Quiet message line.
  final String? message;

  /// Confirm button label.
  final String confirmLabel;

  /// Cancel button label.
  final String cancelLabel;

  /// Render the confirm button in the destructive grammar.
  final bool destructive;

  /// Confirm handler (defaults to popping true).
  final VoidCallback? onConfirm;

  /// Cancel handler (defaults to popping false).
  final VoidCallback? onCancel;

  @override
  Widget build(final BuildContext context) => LaDialog(
    titleText: title,
    description: message,
    width: 380,
    showClose: false,
    actions: [
      LaButton(
        label: cancelLabel,
        variant: LaButtonVariant.ghost,
        onPressed:
            onCancel ??
            () => Navigator.of(context, rootNavigator: true).pop(false),
      ),
      LaButton(
        label: confirmLabel,
        variant: destructive
            ? LaButtonVariant.destructive
            : LaButtonVariant.primary,
        onPressed:
            onConfirm ??
            () => Navigator.of(context, rootNavigator: true).pop(true),
      ),
    ],
  );
}

/// The kit bottom sheet (narrow/touch grammar): slides up, top-rounded
/// squircle, optional drag handle. Replaces showModalBottomSheet.
Future<T?> showLaSheet<T>({
  required final BuildContext context,
  required final WidgetBuilder builder,
  final bool barrierDismissible = true,
  final bool showHandle = true,
  final bool useRootNavigator = true,
}) => showGeneralDialog<T>(
  context: context,
  barrierDismissible: barrierDismissible,
  barrierLabel: 'Dismiss sheet',
  barrierColor: LaUiTheme.of(context).scrim,
  transitionDuration: const Duration(milliseconds: 180),
  useRootNavigator: useRootNavigator,
  pageBuilder: (context, animation, secondaryAnimation) => Align(
    alignment: Alignment.bottomCenter,
    child: LaSheet(showHandle: showHandle, child: builder(context)),
  ),
  transitionBuilder: (context, animation, secondaryAnimation, child) {
    final reduced = laReducedMotion(context);
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );
    return reduced
        ? FadeTransition(opacity: curved, child: child)
        : SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          );
  },
);

/// The sheet surface (usable standalone inside custom routes).
class LaSheet extends StatelessWidget {
  /// A bottom-anchored surface with rounded top corners.
  const LaSheet({
    required this.child,
    this.showHandle = true,
    this.maxWidth = 560,
    this.maxHeightFactor = 0.85,
    super.key,
  });

  /// Sheet content.
  final Widget child;

  /// Draw the quiet drag handle.
  final bool showHandle;

  /// Width cap (desktop centers the sheet).
  final double maxWidth;

  /// Height cap as a fraction of the screen.
  final double maxHeightFactor;

  @override
  Widget build(final BuildContext context) {
    final theme = context.laUi;
    final maxHeight = MediaQuery.sizeOf(context).height * maxHeightFactor;
    // The base-type law for floats (LaDialog.build): the sheet rides a
    // route in the root overlay.
    return DefaultTextStyle(
      style: theme.body,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
        child: DecoratedBox(
          decoration: ShapeDecoration(
            color: theme.surface,
            shape: SquircleShape(
              radius: const BorderRadius.vertical(top: Radius.circular(14)),
              exponent: theme.squircleExponent,
            ),
            shadows: theme.floatingShadow,
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showHandle)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 4),
                    child: Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: ShapeDecoration(
                          color: theme.rule,
                          shape: const SquircleShape(
                            radius: BorderRadius.all(Radius.circular(2)),
                          ),
                        ),
                      ),
                    ),
                  ),
                Flexible(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
