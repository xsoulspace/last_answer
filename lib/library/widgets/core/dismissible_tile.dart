part of '../widgets.dart';

class DismissibleTile extends StatelessWidget {
  const DismissibleTile({
    required this.child,
    required this.dismissibleKey,
    required this.onDismissed,
    // final this.confirmDismiss,
    super.key,
  });
  final VoidCallback onDismissed;
  // final ConfirmDismissCallback? confirmDismiss;
  final Widget child;
  final Key dismissibleKey;
  @override
  Widget build(final BuildContext context) => slidable.Slidable(
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
