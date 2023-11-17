import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart' as intl;
import 'package:json_annotation/json_annotation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:recase/recase.dart';
import 'package:universal_io/io.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

import '../../core.dart';
import 'notifications_controller.dart';

class GlobalStateInitializerDto {
  GlobalStateInitializerDto({
    required this.context,
  })  : emojiRepository = context.read(),
        lastUsedEmojiRepository = context.read(),
        lastEmojiState = context.read(),
        specialEmojiState = context.read(),
        emojiProvider = context.read(),
        notificationController = context.read(),
        assetBundle = DefaultAssetBundle.of(context);
  final BuildContext context;
  final EmojiRepository emojiRepository;
  final LastUsedEmojiRepository lastUsedEmojiRepository;
  final AssetBundle assetBundle;
  final LastEmojiStateNotifier lastEmojiState;
  final SpecialEmojiStateNotifier specialEmojiState;
  final EmojiStateNotifier emojiProvider;
  final NotificationController notificationController;
}

class GlobalStateInitializer implements StateInitializer {
  GlobalStateInitializer({
    required this.dto,
    required this.settings,
  });
  final GlobalStateInitializerDto dto;
  final GeneralSettingsController settings;

  @override
  Future<void> onLoad() async {
    /// ********************************************
    /// *      CONTENT LOADING START
    /// ********************************************

    /// Loadindependent controllers
    await settings.onLoad();

    settings.loadingStatus = AppStateLoadingStatuses.emoji;
    final emojis = await dto.emojiRepository.getAllEmoji(dto.assetBundle);

    dto.emojiProvider
        .loadIterable(values: emojis, toKey: (final p0) => p0.emoji);

    final specialEmojis =
        await dto.emojiRepository.getSpecialEmoji(dto.assetBundle);
    dto.specialEmojiState.loadIterable(
      values: specialEmojis,
      toKey: (final p0) => p0.emoji,
    );

    final lastUsedEmojis = dto.lastUsedEmojiRepository.getAll();
    dto.lastEmojiState.putAll(lastUsedEmojis);
    settings.loadingStatus = AppStateLoadingStatuses.ideas;

    settings.loadingStatus = AppStateLoadingStatuses.questionsForAnswers;

    settings.loadingStatus = AppStateLoadingStatuses.answersForIdeas;

    settings.loadingStatus = AppStateLoadingStatuses.answersForIdeas;

    settings.loadingStatus = AppStateLoadingStatuses.notes;

    final notes = await Hive.openBox<NoteProject>(
      HiveBoxesIds.noteProjectKey,
    );

    /// ********************************************
    /// *      CONTENT LOADING END
    /// ********************************************

    /// ********************************************
    /// *      MIGRATIONS START
    /// ********************************************

    // TODO(arenukvern): keep it in case of future migrations - how to automate it?
    // settings.loadingStatus = AppStateLoadingStatuses.migratingOldData;
    // if (!settings.migrated) {
    //   await settings.setMigrated();
    // }
    settings.loadingStatus = AppStateLoadingStatuses.settings;

    await dto.notificationController.onLoad();

    /// ********************************************
    /// *      MIGRATIONS END
    /// ********************************************
    // WidgetsBinding.instance.addPostFrameCallback((final _) {
    //   settings.notify();
    // });
  }
}
