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

class AppStateProvider extends StatelessWidget {
  const AppStateProvider({
    required this.builder,
    super.key,
  });
  final WidgetBuilder builder;
  GeneralSettingsController get _settings => GlobalStateNotifiers.settings;
  @override
  Widget build(final BuildContext context) {
    final child = MultiProvider(
      providers: [
        /// Keep _settings is global is important as it will not lose all
        /// changes during global rebuild
        ChangeNotifierProvider(create: (final _) => _settings),
        ChangeNotifierProvider(create: createEmojiProvider),
        ChangeNotifierProvider(create: createLastUsedEmojisProvider),
        ChangeNotifierProvider(create: createSpecialEmojisProvider),
        ChangeNotifierProvider(create: createProjectsFoldersProvider),
        ChangeNotifierProvider(create: createCurrentFolderProvider),
        ChangeNotifierProvider(create: createIdeaProjectsState),
        ChangeNotifierProvider(create: createIdeaProjectQuestionsState),
        ChangeNotifierProvider(create: createNoteProjectsState),
        ChangeNotifierProvider(create: createNotificationController),
        ChangeNotifierProvider(create: createPaymentsController),
      ],
      child: Portal(
        child: Builder(
          builder: (final context) => StateLoader(
            initializer: GlobalStateInitializer(
              settings: _settings,
              dto: GlobalStateInitializerDto(context: context),
            ),
            loader: const AppLoadingScreen(),
            child: builder(context),
          ),
        ),
      ),
    );
    if (isNativeDesktop) {
      return child;
    }

    return Directionality(
      // TODO(arenukvern): replace with default device textDirection
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          Container(color: AppColors.black),
          child,
        ],
      ),
    );
  }
}
