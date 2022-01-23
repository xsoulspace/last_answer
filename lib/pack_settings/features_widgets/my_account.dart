part of pack_settings;

class MyAccount extends StatelessWidget {
  const MyAccount({
    this.padding,
    final Key? key,
  }) : super(key: key);
  final EdgeInsets? padding;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<GeneralSettingsController>();

    return SettingsListContainer(
      padding: padding,
      builder: (final context, final leftColumnWidth) => [
        const ListTile(
          title: Text('Username'),
        ),
        const ListTile(
          title: Text('E-mail'),
        ),
      ],
    );
  }
}
