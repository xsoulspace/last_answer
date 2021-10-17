part of widgets;

class DismissibleTile extends StatelessWidget {
  const DismissibleTile({
    required final this.child,
    required final this.dismissibleKey,
    final this.confirmDismiss,
    final this.onDismissed,
    final Key? key,
  }) : super(key: key);
  final ValueChanged<DismissDirection>? onDismissed;
  final ConfirmDismissCallback? confirmDismiss;
  final Widget child;
  final Key dismissibleKey;
  @override
  Widget build(final BuildContext context) {
    return Dismissible(
      key: dismissibleKey,
      confirmDismiss: confirmDismiss,
      onDismissed: onDismissed,
      background: Container(
        decoration: BoxDecoration(
          borderRadius: defaultBorderRadius,
          color: AppColors.accent2,
        ),
        padding: const EdgeInsets.only(right: 12),
        alignment: Alignment.centerLeft,
        child: const Icon(
          Icons.delete,
          color: AppColors.white,
        ),
      ),
      secondaryBackground: Container(),
      child: child,
    );
  }
}
