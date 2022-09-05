import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_app/navigation/app_router_controller.dart';
import 'package:lastanswer/pack_app/screens/home/projects_list_view.dart';
import 'package:lastanswer/pack_app/screens/home/vertical_projects_bar.dart';
import 'package:lastanswer/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:universal_io/io.dart';

class SmallHomeScreen extends StatefulHookWidget {
  const SmallHomeScreen({
    this.verticalMenuAlignment = Alignment.bottomLeft,
    final Key? key,
  }) : super(key: key);
  final Alignment verticalMenuAlignment;

  @override
  _SmallHomeScreenState createState() => _SmallHomeScreenState();
}

class _SmallHomeScreenState extends State<SmallHomeScreen> {
  @override
  Widget build(final BuildContext context) {
    final themeDefiner = ThemeDefiner.of(context);
    final effectiveTheme = themeDefiner.effectiveTheme;

    const verticalMenu = HomeVerticalMenu();

    const projectsList = ProjectsListView();

    final body = Scaffold(
      appBar: HomeAppBar.build(
        context: context,
        onInfoTap: widget.onInfoTap,
        onSettingsTap: widget.onSettingsTap,
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                const SizedBox(height: 2),
                if (widget.verticalMenuAlignment == Alignment.bottomLeft)
                  verticalMenu,
                const Expanded(
                  child: projectsList,
                ),
                if (widget.verticalMenuAlignment == Alignment.bottomRight)
                  verticalMenu,
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

class HomeVerticalMenu extends StatelessWidget {
  const HomeVerticalMenu({
    final Key? key,
  }) : super(key: key);

  @override
  Widget build(final BuildContext context) {
    final themeDefiner = ThemeDefiner.of(context);
    final appRouterController = context.read<AppRouterController>();

    return ColoredBox(
      color: themeDefiner.useContextTheme
          ? themeDefiner.effectiveTheme.primaryColor.withOpacity(.03)
          : Colors.transparent,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: VerticalProjectsBar(
          onIdeaTap: onCreateIdeaTap,
          onNoteTap: onCreateNoteTap,
          onFolderTap: onFolderTap,
        ),
      ),
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
