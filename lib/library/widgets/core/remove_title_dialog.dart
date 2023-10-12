part of widgets;

Future<bool> showRemoveTitleDialog({
  required final String title,
  required final BuildContext context,
}) async {
  if (isAppleDevice) {
    return await showCupertinoDialog(
      context: context,
      builder: (final context) => CupertinoAlertDialog(
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context, false),
              child: Text(S.current.cancel.titleCase),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.pop(context, true),
              child: Text(S.current.delete.titleCase),
            ),
          ],
          content: Text(S.current.willBeLost(title)),
          title: Text(S.current.areYouSure),
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
              S.current.cancel.toUpperCase(),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              S.current.delete.toUpperCase(),
              style: theme.textTheme.labelLarge?.copyWith(color: AppColors.accent2),
            ),
          ),
        ],
        content: Text(S.current.willBeLost(title)),
        title: Text(S.current.areYouSure),
      );
    },
  );
}
