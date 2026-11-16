/// Legacy-kit port of `_library/widgets/core/dismissible_tile.dart`.
/// The original rode `flutter_slidable` + Material theming; this port uses
/// the widgets-layer [Dismissible] with a kit-styled danger action revealed
/// behind the swipe. Public API identical to the original.
library;

import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:la_ui/la_ui.dart';

class DismissibleTile extends StatelessWidget {
  const DismissibleTile({
    required this.child,
    required this.dismissibleKey,
    required this.onDismissed,
    this.canDismiss = true,
    super.key,
  });
  final bool canDismiss;
  final VoidCallback onDismissed;
  final Widget child;
  final Key dismissibleKey;

  @override
  Widget build(final BuildContext context) {
    final laUi = context.laUi;
    final dismissAction = DecoratedBox(
      decoration: BoxDecoration(
        color: laUi.danger.withValues(alpha: 0.8),
        borderRadius: laUi.controlRadius,
      ),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Padding(
          padding: const EdgeInsetsDirectional.only(start: 16),
          child: Text(
            context.l10n.delete,
            style: laUi.body.copyWith(color: laUi.onDanger),
          ),
        ),
      ),
    );

    return Dismissible(
      key: dismissibleKey,
      direction: canDismiss
          ? DismissDirection.startToEnd
          : DismissDirection.none,
      onDismissed: (final _) => onDismissed(),
      background: dismissAction,
      child: child,
    );
  }
}
