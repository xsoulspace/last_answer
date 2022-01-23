part of pack_settings;

class SettingsNavigation extends StatelessWidget {
  const SettingsNavigation({
    required this.onSelectRoute,
    final Key? key,
  }) : super(key: key);
  final ValueChanged<AppRouteName> onSelectRoute;

  @override
  Widget build(final BuildContext context) {
    final routeState = RouteStateScope.of(context);
    final screenLayout = ScreenLayout.of(context);
    BoolValueChanged<AppRouteName>? effectiveSelectedRouteCheck;
    if (screenLayout.notSmall) {
      effectiveSelectedRouteCheck = routeState.checkIsCurrentRoute;
    }

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
              ? S.current.generalSettingsFullTitle
              : S.current.generalSettingsShortTitle,
          // TODO(arenukvern): add avatar
        ),
        SettingsButton(
          routeName: AppRoutesName.profile,
          onSelected: onSelectRoute,
          checkSelected: routeState.checkIsCurrentRoute,
          text: S.current.myAccount,
          // TODO(arenukvern): add avatar
        ),
        SettingsButton(
          routeName: AppRoutesName.subscription,
          onSelected: onSelectRoute,
          checkSelected: routeState.checkIsCurrentRoute,
          text: S.current.subscription,
          // TODO(arenukvern): add avatar
        ),
        SettingsButton(
          routeName: AppRoutesName.changelog,
          onSelected: onSelectRoute,
          checkSelected: routeState.checkIsCurrentRoute,
          text: S.current.changeLog,
          // TODO(arenukvern): add avatar
        ),
      ],
    );
  }
}
