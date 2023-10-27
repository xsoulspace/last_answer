part of pack_settings;

class MyAccount extends StatelessWidget {
  const MyAccount({
    this.padding,
    super.key,
  });
  final EdgeInsets? padding;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<GeneralSettingsController>();

    return SettingsListContainer(
      padding: padding,
      builder: (final context, final leftColumnWidth) => [
        const SizedBox(height: 24),
        SettingsListTile(
          title: S.current.username,
          leftColumnWidth: leftColumnWidth,
          // TODO(arenukvern): add username
          child: const Text(''),
        ),
        const SizedBox(height: 24),
        SettingsListTile(
          title: S.current.email,
          leftColumnWidth: leftColumnWidth,
          // TODO(arenukvern): add email
          child: const Text(''),
        ),
        // TODO(arenukvern): add linked accounts
        const SizedBox(height: 24),

        Divider(
          color: theme.highlightColor,
          height: 24,
          endIndent: 10,
          indent: 10,
        ),
        const SizedBox(height: 24),
        DangerZone(
          // TODO(arenukvern): add delete account
          onRemove: () {},
          removeText: S.current.deleteMyAccount,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
