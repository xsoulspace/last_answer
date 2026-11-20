import 'dart:async';
import 'dart:collection';

import 'package:flutter/widgets.dart';

import 'package:la_ui_kit/src/button.dart';
import 'package:la_ui_kit/src/chrome.dart';
import 'package:la_ui_kit/src/icons.dart';
import 'package:la_ui_kit/src/motion.dart';
import 'package:la_ui_kit/src/squircle.dart';
import 'package:la_ui_kit/src/theme.dart';

/// Toast severity — the only color the toast may carry (honest state).
enum LaToastVariant { info, success, danger }

class _ToastRecord {
  _ToastRecord({
    required this.id,
    required this.message,
    required this.variant,
    this.title,
    this.actionLabel,
    this.onAction,
  });

  final int id;
  final String message;
  final LaToastVariant variant;
  final String? title;
  final String? actionLabel;
  final VoidCallback? onAction;
  bool visible = false;
}

/// The kit toast: corner-stacked (bottom-right desktop / top phone), quiet
/// overlay surface, variant dot, optional action, slide-in (v6 event
/// motion), auto-dismiss. Replaces SnackBar — and rides the ROOT OVERLAY,
/// so it needs no Scaffold.
class LaToast {
  LaToast._();

  static final Map<OverlayState, _ToastHost> _hosts = {};
  static int _nextId = 1;

  /// Shows a toast. Safe to call from anywhere with an Overlay ancestor.
  static void show(
    final BuildContext context, {
    required final String message,
    final LaToastVariant variant = LaToastVariant.info,
    final String? title,
    final String? actionLabel,
    final VoidCallback? onAction,
    final Duration duration = const Duration(milliseconds: 4000),
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) {
      return;
    }
    final theme = LaUiTheme.of(context);
    // Drop a host whose overlay died (hot restart, test teardown, root
    // swap) before reuse — a stale entry can never rebuild.
    final stale = _hosts[overlay];
    if (stale != null && stale.isDead) {
      _hosts.remove(overlay);
    }
    final host = _hosts.putIfAbsent(overlay, () => _ToastHost(overlay, theme));
    final record = _ToastRecord(
      id: _nextId++,
      message: message,
      variant: variant,
      title: title,
      actionLabel: actionLabel,
      onAction: onAction,
    );
    host.push(record, duration);
  }

  /// Info shortcut.
  static void info(final BuildContext context, final String message) =>
      show(context, message: message);

  /// Success shortcut.
  static void success(final BuildContext context, final String message) =>
      show(context, message: message, variant: LaToastVariant.success);

  /// Danger shortcut.
  static void danger(final BuildContext context, final String message) =>
      show(context, message: message, variant: LaToastVariant.danger);
}

class _ToastHost {
  _ToastHost(this._overlay, this._theme) {
    _entry = OverlayEntry(builder: _build);
    if (_overlay.mounted) {
      _overlay.insert(_entry);
    } else {
      _disposed = true;
    }
  }

  final OverlayState _overlay;
  final LaUiTheme _theme;
  final Queue<_ToastRecord> _records = Queue<_ToastRecord>();
  late final OverlayEntry _entry;
  bool _disposed = false;

  /// True when this host can no longer render (overlay gone or disposed).
  bool get isDead => _disposed || !_entry.mounted || !_overlay.mounted;

  void push(final _ToastRecord record, final Duration duration) {
    if (_disposed) {
      return;
    }
    _records.add(record);
    _entry.markNeedsBuild();
    // Slide in on the next frame, auto-dismiss after [duration].
    Timer(const Duration(milliseconds: 30), () {
      if (_disposed) {
        return;
      }
      record.visible = true;
      _entry.markNeedsBuild();
    });
    Timer(duration, () => dismiss(record.id));
  }

  void dismiss(final int id) {
    if (_disposed) {
      return;
    }
    for (final record in _records) {
      if (record.id == id) {
        record.visible = false;
      }
    }
    _entry.markNeedsBuild();
    Timer(const Duration(milliseconds: 220), () {
      if (_disposed) {
        return;
      }
      _records.removeWhere((r) => r.id == id && !r.visible);
      if (_records.isEmpty) {
        _dispose();
      } else {
        _entry.markNeedsBuild();
      }
    });
  }

  void _dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    if (_entry.mounted) {
      _entry.remove();
    }
    LaToast._hosts.remove(_overlay);
  }

  Widget _build(final BuildContext context) {
    if (_records.isEmpty) {
      return const SizedBox.shrink();
    }
    final records = _records.toList();
    final size = MediaQuery.maybeSizeOf(context);
    final top = size != null && size.width < 600;
    return LaUiThemeProvider(
      theme: _theme,
      // The base-type law for floats (LaDialog.build): the toast rides the
      // ROOT overlay, above every DefaultTextStyle any route installs —
      // without this, MaterialApp's error style underlines the message.
      child: DefaultTextStyle(
        style: _theme.body,
        child: Stack(
          children: [
            Positioned(
              right: 16,
              left: top ? 16 : null,
              top: top ? 12 : null,
              bottom: top ? null : 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: top
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.end,
                children: [
                  for (final record in records)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _ToastCard(
                        record: record,
                        onDismiss: () => dismiss(record.id),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToastCard extends StatelessWidget {
  const _ToastCard({required this.record, required this.onDismiss});

  final _ToastRecord record;
  final VoidCallback onDismiss;

  @override
  Widget build(final BuildContext context) {
    final theme = context.laUi;
    final dotColor = switch (record.variant) {
      LaToastVariant.info => theme.inkMuted,
      LaToastVariant.success => theme.success,
      LaToastVariant.danger => theme.danger,
    };
    return AnimatedSlide(
      offset: record.visible ? Offset.zero : const Offset(0.3, 0),
      duration: laMotion(context, theme.motionSettle),
      curve: theme.motionCurve,
      child: AnimatedOpacity(
        opacity: record.visible ? 1 : 0,
        duration: laMotion(context, theme.motionSettle),
        child: LaBox(
          color: theme.surfaceOverlay,
          radius: theme.controlRadius,
          border: BorderSide(color: theme.rule),
          floating: true,
          padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: ShapeDecoration(
                      color: dotColor,
                      shape: const SquircleShape(
                        radius: BorderRadius.all(Radius.circular(3.5)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (record.title != null)
                        Text(
                          record.title!,
                          style: theme.control.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      Text(
                        record.message,
                        style: theme.compact.copyWith(color: theme.ink),
                      ),
                      if (record.actionLabel != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: LaButton(
                            label: record.actionLabel,
                            variant: LaButtonVariant.link,
                            size: LaButtonSize.sm,
                            onPressed: () {
                              record.onAction?.call();
                              onDismiss();
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                LaButton.icon(
                  icon: const LaClose(size: 12),
                  size: LaButtonSize.sm,
                  onPressed: onDismiss,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
