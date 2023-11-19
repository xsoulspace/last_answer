import 'package:lastanswer/_library/widgets/widgets.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/other/update_notification_dialog.dart';
import 'package:lastanswer/router.dart';
import 'package:lastanswer/settings/widgets/settings_button.dart';

class SettingsNavigation extends StatelessWidget {
  const SettingsNavigation({
    super.key,
  });

  @override
  Widget build(final BuildContext context) {
    final screenLayout = ScreenLayout.of(context);

    bool checkSelected(final String route) =>
        context.router.location() == route;
    final notificationController = context.read<NotificationsNotifier>();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: screenLayout.small
          ? CrossAxisAlignment.stretch
          : CrossAxisAlignment.start,
      mainAxisSize: screenLayout.small ? MainAxisSize.max : MainAxisSize.min,
      children: [
        SettingsButton(
          routeName: AppPaths.generalSettings,
          fallbackRouteName: AppPaths.settings,
          onSelected: (final route) async => context.pushNamed(route),
          checkSelected: checkSelected,
          text: screenLayout.small
              ? context.l10n.generalSettingsFullTitle
              : context.l10n.generalSettingsShortTitle,
        ),
        SettingsButton(
          routeName: AppPaths.changelog,
          onSelected: (final _) async => showNotificationDialog(
            context: context,
            notificationController: notificationController,
          ),
          checkSelected: checkSelected,
          text: context.l10n.changeLog,
        ),
      ],
    );
  }
}
