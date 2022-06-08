import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:la_core/la_core.dart';
import 'package:lastanswer/generated/l10n.dart';
import 'package:lastanswer/library/theme/theme.dart';
import 'package:recase/recase.dart';

Future<bool> showRemoveTitleDialog({
  required final String title,
  required final BuildContext context,
}) async {
  if (DeviceRuntimeType.isApple) {
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
          content: Text(S.current.willBeLost(title)),
          title: Text(S.current.areYouSure),
        );
      },
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
              style: theme.textTheme.button?.copyWith(color: AppColors.accent2),
            ),
          ),
        ],
        content: Text(S.current.willBeLost(title)),
        title: Text(S.current.areYouSure),
      );
    },
  );
}
