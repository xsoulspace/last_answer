part of pack_app;

class SettingsListTile extends StatelessWidget {
  const SettingsListTile({
    required final this.title,
    required final this.child,
    required final this.leftPadding,
    required final this.rightPadding,
    final Key? key,
  }) : super(key: key);
  final double leftPadding;
  final double rightPadding;
  final String title;
  final Widget child;
  @override
  Widget build(final BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: leftPadding,
          child: Text(
            '$title:',
            textAlign: TextAlign.end,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: child,
        ),
        SizedBox(width: rightPadding),
      ],
    );
  }
}
