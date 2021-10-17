part of home;

Future<bool> showRemoveProjectDialog({
  required final BasicProject project,
  required final BuildContext context,
}) async {
  if (Platform.isIOS) {
    return await showCupertinoDialog(
      context: context,
      builder: (final context) {
        return CupertinoAlertDialog(
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
          content: Text(S.current.projectWillBeLost(project.title)),
          title: Text(S.current.areYouSure),
        );
      },
    );
  }
  return await showDialog(
    context: context,
    builder: (final context) {
      return AlertDialog(
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(S.current.cancel.toUpperCase()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(S.current.delete.toUpperCase()),
          ),
        ],
        content: Text(S.current.projectWillBeLost(project.title)),
        title: Text(S.current.areYouSure),
      );
    },
  );
}
