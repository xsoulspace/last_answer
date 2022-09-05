import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:la_core/la_core.dart';
import 'package:la_design_core/la_design_core.dart';
import 'package:lastanswer/pack_app/navigation/app_router_controller.dart';
import 'package:lastanswer/pack_app/screens/home/home_layout_screen.dart';
import 'package:provider/provider.dart';

class AppNavigator extends HookWidget {
  const AppNavigator({
    required this.navigatorKey,
    final Key? key,
  }) : super(key: key);
  final GlobalKey<NavigatorState> navigatorKey;
  @override
  Widget build(final BuildContext context) {
    context.watch<RouteState>();

    final keys = useState(const _AppPageBuilderKeys());
    final pageBuilder =
        _AppPageBuilder.use(keys: keys.value, read: context.read);
    final layoutBuilder = _AppLayoutBuilder(pageBuilder: pageBuilder);

    return Navigator(
      key: navigatorKey,
      onPopPage: const RouterPopper().onPopPage,
      pages: layoutBuilder.buildPages(),
    );
  }
}

@immutable
class _AppPageBuilderKeys {
  const _AppPageBuilderKeys();
  ValueKey get home => const ValueKey('home');
}

class _AppPageBuilder extends RouterPageBuilder<AppRouterController> {
  _AppPageBuilder.use({
    required this.keys,
    required super.read,
  }) : super.use();
  static final emptyPage = NavigatorPage(
    child: const EmptyScreen(),
    key: const ValueKey('loading-screen'),
  );

  final _AppPageBuilderKeys keys;

  Page home() => NavigatorPage(
        child: const HomeLayoutScreen(),
        key: keys.home,
      );
}

class _AppLayoutBuilder
    extends RouterLayoutBuilder<AppRouterController, _AppPageBuilder> {
  _AppLayoutBuilder({required super.pageBuilder});
  @override
  List<Page> buildPages() {
    final pages = <Page>[
      _AppPageBuilder.emptyPage,
      pageBuilder.home(),
    ];
    return pages;
  }
}
