part of '../widgets.dart';

Future<bool> showRemoveTitleDialog({
  required final String title,
  required final BuildContext context,
}) async {
  if (PlatformInfo.isCupertino) {
    return await showCupertinoDialog(
      context: context,
      builder: (final context) => CupertinoAlertDialog(
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.cancel.titleCase),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.delete.titleCase),
          ),
        ],
        content: Text(context.l10n.willBeLost(title)),
        title: Text(context.l10n.areYouSure),
      ),
    );
  }

  return await showDialog(
    context: context,
    builder: (final context) {
      final theme = Theme.of(context);

      return AlertDialog(
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              context.l10n.cancel.toUpperCase(),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              context.l10n.delete.toUpperCase(),
              style: theme.textTheme.labelLarge
                  ?.copyWith(color: AppColors.accent2),
            ),
          ),
        ],
        content: Text(context.l10n.willBeLost(title)),
        title: Text(context.l10n.areYouSure),
      );
    },
  );
}
