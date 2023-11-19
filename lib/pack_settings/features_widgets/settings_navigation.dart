import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_app/notifications/update_notification_popup.dart';
import 'package:lastanswer/pack_settings/widgets/settings_button.dart';

class SettingsNavigation extends StatelessWidget {
  const SettingsNavigation({
    required this.onSelectRoute,
    super.key,
  });
  final ValueChanged<AppRouteName> onSelectRoute;

  @override
  Widget build(final BuildContext context) {
    final routeState = RouteStateScope.of(context);
    final screenLayout = ScreenLayout.of(context);

    BoolValueChanged<AppRouteName>? effectiveSelectedRouteCheck;
    if (screenLayout.notSmall) {
      effectiveSelectedRouteCheck = routeState.checkIsCurrentRoute;
    }
    final notificationController = context.read<NotificationsNotifier>();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: screenLayout.small
          ? CrossAxisAlignment.stretch
          : CrossAxisAlignment.start,
      mainAxisSize: screenLayout.small ? MainAxisSize.max : MainAxisSize.min,
      children: [
        SettingsButton(
          routeName: AppRoutesName.generalSettings,
          fallbackRouteName: AppRoutesName.settings,
          onSelected: onSelectRoute,
          checkSelected: effectiveSelectedRouteCheck,
          text: screenLayout.small
              ? context.l10n.generalSettingsFullTitle
              : context.l10n.generalSettingsShortTitle,
          // TODO(arenukvern): add avatar
        ),
        SettingsButton(
          routeName: AppRoutesName.changelog,
          onSelected: (final _) async => showNotificationPopup(
            context: context,
            notificationController: notificationController,
          ),
          checkSelected: routeState.checkIsCurrentRoute,
          text: context.l10n.changeLog,
          // TODO(arenukvern): add avatar
        ),
      ],
    );
  }
}
