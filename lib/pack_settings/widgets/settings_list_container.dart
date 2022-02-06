part of pack_settings;

class SettingsListContainer extends StatelessWidget {
  const SettingsListContainer({
    required this.builder,
    this.padding,
    final Key? key,
  }) : super(key: key);
  final EdgeInsets? padding;
  final List<Widget> Function(BuildContext context, double leftColumnWidth)
      builder;
  @override
  Widget build(final BuildContext context) {
    final screenLayout = ScreenLayout.of(context);

    final leftColumnWidth = screenLayout.small ? 90.0 : 150.0;

    return SingleChildScrollView(
      padding: padding ?? const EdgeInsets.all(18),
      child: Column(
        children: builder(
          context,
          leftColumnWidth,
        ),
      ),
    );
  }
}