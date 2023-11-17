import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:blur/blur.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart' as intl;
import 'package:json_annotation/json_annotation.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_idea/pack_idea.dart';
import 'package:lastanswer/pack_note/note_screen.dart';
import 'package:lastanswer/pack_note/note_view.dart';
import 'package:lastanswer/pack_purchases/pack_purchases.dart';
import 'package:lastanswer/pack_settings/pack_settings.dart';
import 'package:lastanswer/utils/utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:recase/recase.dart';
import 'package:universal_io/io.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class SmallHomeScreen extends StatefulHookWidget {
  const SmallHomeScreen({
    required this.onProjectTap,
    required this.onSettingsTap,
    required this.onInfoTap,
    required this.onCreateIdeaTap,
    required this.onCreateNoteTap,
    required this.onGoHome,
    required this.checkIsProjectActive,
    this.verticalMenuAlignment = Alignment.bottomLeft,
    super.key,
  });
  final ValueChanged<BasicProject> onProjectTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onInfoTap;
  final VoidCallback onCreateIdeaTap;
  final VoidCallback onCreateNoteTap;
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
    super.key,
  });
  final VoidCallback onCreateIdeaTap;
  final VoidCallback onCreateNoteTap;

  @override
  Widget build(final BuildContext context) {
    final themeDefiner = ThemeDefiner.of(context);

    return ColoredBox(
      color: themeDefiner.useContextTheme
          ? themeDefiner.effectiveTheme.primaryColor.withOpacity(.03)
          : Colors.transparent,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: _VerticalProjectsBar(
          onIdeaTap: onCreateIdeaTap,
          onNoteTap: onCreateNoteTap,
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
        style: effectiveTheme.textTheme.displayMedium,
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
