import 'package:lastanswer/_library/widgets/widgets.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/settings/screens/general_settings_screen.dart';
import 'package:lastanswer/settings/screens/my_account_screen.dart';
import 'package:lastanswer/settings/screens/settings_navigation_screen.dart';

class SmallSettingsScreen extends HookWidget {
  const SmallSettingsScreen({
    required this.onHome,
    super.key,
  });
  final VoidCallback onHome;

  @override
  Widget build(final BuildContext context) {
    final currentLocation = context.router.location();
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
      switch (currentLocation) {
        case ScreenPaths.profile:
          subSettingsPage.value = MyAccountScreen(onBack: onHome);
          await toPage();
        case ScreenPaths.generalSettings:
          subSettingsPage.value = GeneralSettingsScreen(onBack: onHome);
          await toPage();
        default:
          await toNavigation();
      }
    }

// TODO(arenukvern): fixme,
    pageController.addListener(() {
      if (!pageController.hasClients) return;
      final controllerPage = pageController.page?.ceil();
      if (chosenPage.value == controllerPage) return;
      unawaited(context.pushNamed(ScreenPaths.settings));
    });

    useEffect(
      () {
        unawaited(switchToPage());

        return null;
      },
      [context.router],
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
          onBack: onHome,
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
