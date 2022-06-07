import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_app/screens/home/projects_list_view.dart';
import 'package:lastanswer/pack_app/screens/home/vertical_projects_bar.dart';
import 'package:lastanswer/pack_app/widgets/project_tile.dart';
import 'package:lastanswer/utils/utils.dart';
import 'package:universal_io/io.dart';

class SmallHomeScreen extends StatefulHookWidget {
  const SmallHomeScreen({
    required this.onProjectTap,
    required this.onSettingsTap,
    required this.onInfoTap,
    required this.onCreateIdeaTap,
    required this.onCreateNoteTap,
    required this.onGoHome,
    required this.checkIsProjectActive,
    required this.onFolderTap,
    final this.verticalMenuAlignment = Alignment.bottomLeft,
    final Key? key,
  }) : super(key: key);
  final ValueChanged<BasicProject> onProjectTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onInfoTap;
  final VoidCallback onCreateIdeaTap;
  final VoidCallback onCreateNoteTap;
  final ValueChanged<ProjectFolder> onFolderTap;
  final Alignment verticalMenuAlignment;
  final BoolValueChanged<BasicProject> checkIsProjectActive;
  final VoidCallback onGoHome;

  @override
  _SmallHomeScreenState createState() => _SmallHomeScreenState();
}

class _SmallHomeScreenState extends State<SmallHomeScreen> {
  @override
  Widget build(final BuildContext context) {
    final themeDefiner = ThemeDefiner.of(context);
    final effectiveTheme = themeDefiner.effectiveTheme;

    final verticalMenu = HomeVerticalMenu(
      onCreateIdeaTap: widget.onCreateIdeaTap,
      onCreateNoteTap: widget.onCreateNoteTap,
      onFolderTap: widget.onFolderTap,
    );

    final projectsList = ProjectsListView(
      checkIsProjectActive: widget.checkIsProjectActive,
      onGoHome: widget.onGoHome,
      onProjectTap: widget.onProjectTap,
      themeDefiner: themeDefiner,
    );

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
                Expanded(
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
    required this.onCreateIdeaTap,
    required this.onCreateNoteTap,
    required this.onFolderTap,
    final Key? key,
  }) : super(key: key);
  final VoidCallback onCreateIdeaTap;
  final VoidCallback onCreateNoteTap;
  final ValueChanged<ProjectFolder> onFolderTap;

  @override
  Widget build(final BuildContext context) {
    final themeDefiner = ThemeDefiner.of(context);

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
