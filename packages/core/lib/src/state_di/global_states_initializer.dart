import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core.dart';

class GlobalStatesInitializerDto {
  GlobalStatesInitializerDto({
    required final BuildContext context,
  })  : emojiRepository = context.read(),
        lastUsedEmojiRepository = context.read(),
        lastEmojiState = context.read(),
        specialEmojiState = context.read(),
        emojiProvider = context.read(),
        notificationController = context.read(),
        projectsNotifier = context.read(),
        userNotifier = context.read(),
        appNotifier = context.read(),
        projectsRepository = context.read(),
        assetBundle = DefaultAssetBundle.of(context);
  final EmojiRepository emojiRepository;
  final LastUsedEmojiRepository lastUsedEmojiRepository;
  final AssetBundle assetBundle;
  final LastEmojiStateNotifier lastEmojiState;
  final SpecialEmojiStateNotifier specialEmojiState;
  final EmojiStateNotifier emojiProvider;
  final NotificationsNotifier notificationController;
  final ProjectsNotifier projectsNotifier;
  final UserNotifier userNotifier;
  final AppNotifier appNotifier;
  final ProjectsRepository projectsRepository;
}

class GlobalStatesInitializer implements StateInitializer {
  GlobalStatesInitializer({
    required this.dto,
  });
  final GlobalStatesInitializerDto dto;

  @override
  Future<void> onLoad() async {
    /// ********************************************
    /// *      CONTENT LOADING START
    /// ********************************************
    final emojis = await dto.emojiRepository.getAllEmoji();

    dto.emojiProvider
        .loadIterable(values: emojis, toKey: (final p0) => p0.emoji);

    final specialEmojis = await dto.emojiRepository.getSpecialEmoji();
    dto.specialEmojiState.loadIterable(
      values: specialEmojis,
      toKey: (final p0) => p0.emoji,
    );

    final lastUsedEmojis = dto.lastUsedEmojiRepository.getAll();
    dto.lastEmojiState.putAll(lastUsedEmojis);

    await dto.notificationController.onLoad();

    final isConnected = await PlatformInfo.isConnected;
    dto.appNotifier.updateAppStatus(
      isConnected ? AppStatus.online : AppStatus.offline,
    );

    /// we may not await for user, as it has its own loader
    unawaited(dto.userNotifier.onLoad());
  }
}
