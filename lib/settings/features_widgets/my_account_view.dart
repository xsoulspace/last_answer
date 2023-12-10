import 'package:lastanswer/_library/widgets/widgets.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/settings/widgets/settings_list_container.dart';

class MyAccountView extends StatelessWidget {
  const MyAccountView({
    this.padding,
    super.key,
  });
  final EdgeInsets? padding;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final userNotifier = context.watch<UserNotifier>();
    return SettingsListContainer(
      padding: padding,
      builder: (final context, final leftColumnWidth) => [
        const SizedBox(height: 24),
        // SettingsListTile(
        //   title: context.l10n.username,
        //   leftColumnWidth: leftColumnWidth,
        // TODO(arenukvern): add username
        //   child: const Text(''),
        // ),
        // const SizedBox(height: 24),
        // SettingsListTile(
        //   title: context.l10n.email,
        //   leftColumnWidth: leftColumnWidth,
        // TODO(arenukvern): add email
        //   child: const Text(''),
        // ),
        // TODO(arenukvern): add linked accounts
        // const SizedBox(height: 24),

        // Divider(
        //   color: theme.highlightColor,
        //   height: 24,
        //   endIndent: 10,
        //   indent: 10,
        // ),
        const SizedBox(height: 24),
        DangerZone(
          // TODO(arenukvern): add delete account
          onRemove: () async {
            final shouldProceed = await Modals.of(context).showWarningDialog(
              title: 'Are you sure?',
              description:
                  'Your account will be deleted. \n- All projects will be not deleted since it is stored only your device. \n- Any payment history will be deleted and cannot be restored.',
            );
          },
          removeText: context.l10n.deleteMyAccount,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
