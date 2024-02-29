import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

export 'toasts.dart';

class Modals {
  Modals.of(this.context);
  final BuildContext context;
  Future<T?> showConstrainedDialog<T>({
    required final WidgetBuilder builder,
  }) =>
      showAdaptiveDialog<T>(
        context: context,
        barrierDismissible: true,
        builder: (final context) => Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 450,
              maxWidth: 300,
              minWidth: 200,
              minHeight: 150,
            ),
            child: builder(context),
          ),
        ),
      );

  Future<T?> showActionDialog<T>({
    required final List<ActionButtonItem> Function(BuildContext context)
        actionsBuilder,
    required final Widget? title,
    required final Widget? content,
  }) async =>
      showAdaptiveDialog<T>(
        context: context,
        builder: (final context) => AlertDialog.adaptive(
          actions: actionsBuilder(context)
              .map((final e) => DialogActionButton(item: e))
              .toList(),
          title: title,
          content: content,
        ),
      );
  Future<bool> showWarningDialog({
    required final String title,
    required final String description,
    final String? yesActionText,
    final String? noActionText,
  }) async {
    final result = await showActionDialog(
      title: Text(title),
      content: Text(description),
      actionsBuilder: (final context) => [
        ActionButtonItem(
          title: yesActionText ?? context.l10n.yes,
          onPressed: () => Navigator.pop(context, true),
        ),
        ActionButtonItem(
          title: noActionText ?? context.l10n.no,
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context, false),
        ),
      ],
    );
    return result == true;
  }
}

class ActionButtonItem {
  ActionButtonItem({
    required this.title,
    required this.onPressed,
    this.isDefaultAction = false,
    this.isDestructiveAction = false,
  });
  final String title;
  final bool isDefaultAction;
  final bool isDestructiveAction;
  final VoidCallback onPressed;
}

class DialogActionButton extends StatelessWidget {
  const DialogActionButton({
    required this.item,
    super.key,
  });
  final ActionButtonItem item;
  @override
  Widget build(final BuildContext context) {
    final onPressed = item.onPressed;
    if (PlatformInfo.isCupertino) {
      return CupertinoDialogAction(
        isDefaultAction: item.isDefaultAction,
        isDestructiveAction: item.isDestructiveAction,
        onPressed: onPressed,
        child: Text(item.title),
      );
    } else {
      if (item.isDestructiveAction) {
        return OutlinedButton(
          onPressed: onPressed,
          child: Text(item.title),
        );
      }
      if (item.isDefaultAction) {
        return FilledButton.tonal(
          onPressed: onPressed,
          child: Text(item.title),
        );
      }
      return TextButton(onPressed: onPressed, child: Text(item.title));
    }
  }
}
