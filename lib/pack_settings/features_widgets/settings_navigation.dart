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

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SettingsButton(
          routeName: AppRoutesName.generalSettings,
          fallbackRouteName: AppRoutesName.settings,
          onSelected: onSelectRoute,
          checkSelected: routeState.checkIsCurrentRoute,
          // TODO(arenukvern): add translation
          text: 'General',
          // TODO(arenukvern): add avatar
        ),
        SettingsButton(
          routeName: AppRoutesName.profile,
          onSelected: onSelectRoute,
          checkSelected: routeState.checkIsCurrentRoute,
          // TODO(arenukvern): add translation
          text: 'My account',
          // TODO(arenukvern): add avatar
        ),
        SettingsButton(
          routeName: AppRoutesName.subscription,
          onSelected: onSelectRoute,
          checkSelected: routeState.checkIsCurrentRoute,
          // TODO(arenukvern): add translation
          text: 'Subscription',
          // TODO(arenukvern): add avatar
        ),
        SettingsButton(
          routeName: AppRoutesName.changelog,
          onSelected: onSelectRoute,
          checkSelected: routeState.checkIsCurrentRoute,
          // TODO(arenukvern): add translation
          text: 'Change Log',
          // TODO(arenukvern): add avatar
        ),
      ],
    );
  }
}
