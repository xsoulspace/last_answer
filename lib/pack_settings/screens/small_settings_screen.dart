part of pack_settings;

class SmallSettingsScreen extends HookWidget {
  const SmallSettingsScreen({
    required this.onSelectRoute,
    required this.onBack,
    required this.onPopPage,
    final Key? key,
  }) : super(key: key);
  final ValueChanged<AppRouteName> onSelectRoute;
  final VoidCallback onBack;
  final PopPageCallback? onPopPage;

  @override
  Widget build(final BuildContext context) {
    final routeState = RouteStateScope.of(context);
    final subSettingsPage = useState<Widget>(const SizedBox());
    final pageController = usePageController();

    Future<void> toPage({final int page = 1}) async {
      if (!pageController.hasClients) return;
      await pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 350),
        curve: Curves.linear,
      );
    }

    Future<void> toNavigation() async => toPage(page: 0);

    useEffect(
      // ignore: unnecessary_lambdas
      () {
        () async {
          switch (routeState.route.pathTemplate) {
            case AppRoutesName.generalSettings:
              subSettingsPage.value = GeneralSettingsScreen(onBack: onBack);
              await toPage();
              break;
            default:
              await toNavigation();
              subSettingsPage.value = const SizedBox();
          }
        }();
      },
      [routeState.route],
    );

    return PageView(
      controller: pageController,
      children: [
        SettingsNavigationScreen(
          onBack: onBack,
          onSelectRoute: onSelectRoute,
        ),
        subSettingsPage.value,
      ],
    );
  }
}
