import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core.dart';

class GlobalStateInitializerDto {
  GlobalStateInitializerDto({
    required final BuildContext context,
  })  : emojiRepository = context.read(),
        lastUsedEmojiRepository = context.read(),
        lastEmojiState = context.read(),
        specialEmojiState = context.read(),
        emojiProvider = context.read(),
        notificationController = context.read(),
        globalStateNotifier = context.read(),
        projectsRepository = context.read(),
        assetBundle = DefaultAssetBundle.of(context);
  final EmojiRepository emojiRepository;
  final LastUsedEmojiRepository lastUsedEmojiRepository;
  final AssetBundle assetBundle;
  final LastEmojiStateNotifier lastEmojiState;
  final SpecialEmojiStateNotifier specialEmojiState;
  final EmojiStateNotifier emojiProvider;
  final NotificationController notificationController;
  final GlobalStateNotifier globalStateNotifier;
  final ProjectsRepository projectsRepository;
}

class GlobalStateInitializer implements StateInitializer {
  GlobalStateInitializer({
    required this.dto,
  });
  final GlobalStateInitializerDto dto;

  @override
  Future<void> onLoad() async {
    /// ********************************************
    /// *      CONTENT LOADING START
    /// ********************************************
    final globalStateNotifier = dto.globalStateNotifier;
    await dto.globalStateNotifier.onLoad();

    globalStateNotifier.updateAppLoadingStatus(
      AppStateLoadingStatuses.migratingOldData,
    );
    await runMutations(dto);

    globalStateNotifier.updateAppLoadingStatus(AppStateLoadingStatuses.emoji);
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

    /// ********************************************
    /// *      MIGRATIONS START
    /// ********************************************

    await dto.notificationController.onLoad();
    globalStateNotifier.updateAppLoadingStatus(
      AppStateLoadingStatuses.migratingOldData,
    );
  }
}
