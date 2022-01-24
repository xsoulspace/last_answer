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
    final subSettingsPage = useState<Widget?>(null);
    final pageController = usePageController();
    final chosenPage = useState(0);
    Future<void> toPage({final int page = 1}) async {
      if (!pageController.hasClients) return;
      chosenPage.value = page;
      await pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 350),
        curve: Curves.linear,
      );
    }

    Future<void> toNavigation() async => toPage(page: 0);

    Future<void> switchToPage() async {
      switch (routeState.route.pathTemplate) {
        case AppRoutesName.profile:
          subSettingsPage.value = MyAccountScreen(onBack: onBack);
          await toPage();
          break;
        case AppRoutesName.generalSettings:
          subSettingsPage.value = GeneralSettingsScreen(onBack: onBack);
          await toPage();
          break;
        case AppRoutesName.subscription:
          subSettingsPage.value = SubscriptionScreen(onBack: onBack);
          await toPage();
          break;
        default:
          await toNavigation();
      }
    }

    pageController.addListener(() {
      if (!pageController.hasClients) return;
      final controllerPage = pageController.page?.ceil();
      if (chosenPage.value == controllerPage) return;
      onSelectRoute(AppRoutesName.settings);
    });

    useEffect(
      // ignore: unnecessary_lambdas
      () {
        switchToPage();
      },
      [routeState.route],
    );
    final screenLayout = ScreenLayout.of(context);
    useEffect(
      () {
        WidgetsBinding.instance?.addPostFrameCallback((final _) {
          switchToPage();
        });
      },
      [screenLayout.small],
    );
    final subPage = subSettingsPage.value;

    return PageView(
      controller: pageController,
      children: [
        SettingsNavigationScreen(
          onBack: onBack,
          onSelectRoute: onSelectRoute,
        ),
        if (subPage != null) subPage,
      ],
    );
  }
}
