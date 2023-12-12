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
    final isAuthorized = userNotifier.isAuthorized;
    return SettingsListContainer(
      padding: padding,
      builder: (final context, final leftColumnWidth) {
        if (!isAuthorized) {
          return [
            Text(
              'Log In',
              style: context.textTheme.headlineLarge,
            ),
            const Gap(24),
            Text(
              'For authorized users available:',
              style: context.textTheme.bodyLarge,
            ),
            const Gap(8),
            Text(
              '- Folders',
              style: context.textTheme.bodyMedium,
            ),
            Text(
              '- Option to purchase "Supporter version" of the app.',
              style: context.textTheme.bodyMedium,
            ),
            const Gap(24),
            const Text(
              'Any projects you created will still be saved on your device.',
            ),
            const Gap(24),
            const GoogleSignInButton(),
          ];
        }
        return [
          const Gap(24),
          const Text('No active subscription'),
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

          const Gap(24),
          LoadableWidget(
            builder: (final context, final setLoading, final isLoading) =>
                DangerZone(
              isLoading: isLoading,
              onRemove: () async {
                setLoading(true);
                final shouldProceed =
                    await Modals.of(context).showWarningDialog(
                  title: context.l10n.areYouSure,
                  noActionText: context.l10n.cancel,
                  yesActionText: context.l10n.delete,
                  description:
                      // TODO(arenukvern): add l10n,
                      // ignore: lines_longer_than_80_chars
                      'Your account will be deleted. \n\n- All projects will be not deleted since it is stored only your device. \n- Any payment history will be deleted and cannot be restored.',
                );
                if (shouldProceed == true) {
                  await userNotifier.deleteRemoteUser();
                }

                setLoading(false);
              },
              removeText: context.l10n.deleteMyAccount,
            ),
          ),
          const Gap(24),
        ];
      },
    );
  }
}
