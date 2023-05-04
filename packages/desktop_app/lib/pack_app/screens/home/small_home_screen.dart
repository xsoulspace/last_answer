import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_app/navigation/app_router_controller.dart';
import 'package:lastanswer/pack_app/screens/home/projects_list_view.dart';
import 'package:lastanswer/pack_app/screens/home_mouse/widgets/home_vertical_menu.dart';
import 'package:lastanswer/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:universal_io/io.dart';

class SmallHomeScreen extends HookWidget {
  const SmallHomeScreen({
    this.verticalMenuAlignment = Alignment.bottomLeft,
    final Key? key,
  }) : super(key: key);
  final Alignment verticalMenuAlignment;

  @override
  Widget build(final BuildContext context) {
    final themeDefiner = ThemeDefiner.of(context);
    final effectiveTheme = themeDefiner.effectiveTheme;

    final body = Scaffold(
      appBar: HomeAppBar.build(
        context: context,
        onInfoTap: () => context.read<AppRouterController>().toAppInfo(),
        onSettingsTap: () => context.read<AppRouterController>().toSettings(),
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                const SizedBox(height: 2),
                if (verticalMenuAlignment == Alignment.bottomLeft)
                  const HomeVerticalMenu(),
                const Expanded(
                  child: ProjectsListView(),
                ),
                if (verticalMenuAlignment == Alignment.bottomRight)
                  const HomeVerticalMenu(),
              ],
            ),
          ),
          const SizedBox(height: 5),
          const BottomSafeArea(),
        ],
      ),
    );

    return Theme(
      data: effectiveTheme,
      child: body,
    );
  }
}

class HomeAppBar {
  HomeAppBar._();
  static PreferredSizeWidget build({
    required final VoidCallback onSettingsTap,
    required final VoidCallback onInfoTap,
    required final BuildContext context,
  }) {
    final greeting = Greeting();
    final themeDefiner = ThemeDefiner.of(context);
    final effectiveTheme = themeDefiner.effectiveTheme;

    if (Platform.isMacOS) {
      return LeftPanelMacosAppBar(
        context: context,
        title: greeting.current,
        actions: [
          IconButton(
            onPressed: onInfoTap,
            icon: const Icon(Icons.info_outline),
          ),
          IconButton(
            onPressed: onSettingsTap,
            icon: const Icon(CupertinoIcons.settings),
          ),
        ]
            .map(
              (final child) => Padding(
                padding: const EdgeInsets.only(right: 18),
                child: child,
              ),
            )
            .toList(),
      );
    }

    return AppBar(
      // TODO(arenukvern): make popup with translation for native language
      title: SelectableText(
        greeting.current,
        style: effectiveTheme.textTheme.headline2,
      ),
      actions: [
        IconButton(
          onPressed: onInfoTap,
          icon: const Icon(Icons.info_outline),
        ),
        IconButton(
          onPressed: onSettingsTap,
          icon: const Icon(CupertinoIcons.gear),
        ),
      ]
          .map(
            (final child) => Padding(
              padding: const EdgeInsets.only(right: 18),
              child: child,
            ),
          )
          .toList(),
    );
  }
}
