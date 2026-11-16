/// Legacy-kit replacement for `_library`'s `showRemoveTitleDialog`
/// (RemoveTitleDialog maps to `showLaConfirm` per the sweep brief — this is
/// a thin l10n wrapper, not a widget port). Public API identical to the
/// original; the Cupertino/Material dialog split collapses into the kit's
/// one confirm grammar.
library;

import 'package:lastanswer/common_imports.dart';

Future<bool> showRemoveTitleDialog({
  required final String title,
  required final BuildContext context,
}) => showLaConfirm(
  context,
  title: context.l10n.areYouSure,
  message: context.l10n.willBeLost(title),
  confirmLabel: context.l10n.delete.titleCase,
  cancelLabel: context.l10n.cancel.titleCase,
  destructive: true,
);
