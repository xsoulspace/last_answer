import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_settings/screens/general_settings_screen.dart';
import 'package:lastanswer/pack_settings/screens/my_account_screen.dart';
import 'package:lastanswer/pack_settings/screens/settings_navigation_screen.dart';

class SmallSettingsScreen extends HookWidget {
  const SmallSettingsScreen({
    required this.onSelectRoute,
    required this.onBack,
    super.key,
  });
  final ValueChanged<AppRouteName> onSelectRoute;
  final VoidCallback onBack;

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
        duration: const Duration(milliseconds: 200),
        curve: Curves.linearToEaseOut,
      );
    }

    Future<void> toNavigation() async => toPage(page: 0);

    Future<void> switchToPage() async {
      switch (routeState.route.pathTemplate) {
        case AppRoutesName.profile:
          subSettingsPage.value = MyAccountScreen(onBack: onBack);
          await toPage();
        case AppRoutesName.generalSettings:
          subSettingsPage.value = GeneralSettingsScreen(onBack: onBack);
          await toPage();
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
      () {
        unawaited(switchToPage());

        return null;
      },
      [routeState.route],
    );
    final screenLayout = ScreenLayout.of(context);
    useEffect(
      () {
        WidgetsBinding.instance
            .addPostFrameCallback((final _) async => switchToPage());

        return null;
      },
      [screenLayout.small],
    );
    final subPage = subSettingsPage.value;

    return PageView(
      physics: const SpeedyPageViewScrollPhysics(),
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

class SpeedyPageViewScrollPhysics extends ScrollPhysics {
  const SpeedyPageViewScrollPhysics({super.parent});

  @override
  SpeedyPageViewScrollPhysics applyTo(final ScrollPhysics? ancestor) =>
      SpeedyPageViewScrollPhysics(parent: buildParent(ancestor));

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 80,
        stiffness: 100,
        damping: 1,
      );
}
