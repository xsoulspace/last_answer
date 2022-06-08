import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart' as slidable;
import 'package:lastanswer/generated/l10n.dart';
import 'package:lastanswer/library/theme/theme.dart';

class DismissibleTile extends StatelessWidget {
  const DismissibleTile({
    required final this.child,
    required final this.dismissibleKey,
    required final this.onDismissed,
    // final this.confirmDismiss,
    final Key? key,
  }) : super(key: key);
  final VoidCallback onDismissed;
  // final ConfirmDismissCallback? confirmDismiss;
  final Widget child;
  final Key dismissibleKey;
  @override
  Widget build(final BuildContext context) {
    return slidable.Slidable(
      key: dismissibleKey,
      startActionPane: slidable.ActionPane(
        motion: const slidable.BehindMotion(),
        children: [
          slidable.SlidableAction(
            // TODO(arenukvern): uncomment if this PR will be merged
            /// https://github.com/letsar/flutter_slidable/pull/255
            // shape: RoundedRectangleBorder(
            //   borderRadius: defaultBorderRadius,
            // ),
            onPressed: (final _) => onDismissed(),
            backgroundColor: AppColors.accent2.withOpacity(0.8),
            foregroundColor: Colors.white,
            label: S.current.delete,
          ),
        ],
      ),
      child: child,
    );
  }
}
