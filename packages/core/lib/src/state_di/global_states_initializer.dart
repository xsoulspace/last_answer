import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_models/shared_models.dart';

import '../../core.dart';
import '../state/user_remote_initializer.dart';

class GlobalStatesInitializerDto {
  GlobalStatesInitializerDto({
    required this.context,
  })  : emojiRepository = context.read(),
        lastUsedEmojiRepository = context.read(),
        lastEmojiState = context.read(),
        specialEmojiState = context.read(),
        emojiProvider = context.read(),
        notificationController = context.read(),
        projectsNotifier = context.read(),
        userNotifier = context.read(),
        appNotifier = context.read(),
        complexLocalDb = context.read(),
        localDbDataSource = context.read(),
        remoteClient = context.read(),
        purchasesNotifier = context.read(),
        projectsRepository = context.read(),
        assetBundle = DefaultAssetBundle.of(context);
  final BuildContext context;
  final RemoteClient remoteClient;
  final LocalDbDataSource localDbDataSource;
  final ComplexLocalDb complexLocalDb;
  final EmojiRepository emojiRepository;
  final LastUsedEmojiRepository lastUsedEmojiRepository;
  final AssetBundle assetBundle;
  final LastEmojiStateNotifier lastEmojiState;
  final SpecialEmojiStateNotifier specialEmojiState;
  final EmojiStateNotifier emojiProvider;
  final NotificationsNotifier notificationController;
  final ProjectsNotifier projectsNotifier;
  final UserNotifier userNotifier;
  final PurchasesNotifier purchasesNotifier;
  final AppNotifier appNotifier;
  final ProjectsRepository projectsRepository;
}

class GlobalStatesInitializer implements StateInitializer {
  GlobalStatesInitializer({
    required this.dto,
    required this.router,
  });
  final GlobalStatesInitializerDto dto;
  final GoRouter router;
  late final _localUserInitializer = LocalUserInitializer(dto.context);
  late final _remoteUserInitializer = RemoteUserInitializer(dto.context);
  @override
  Future<void> onLoad() async {
    await dto.complexLocalDb.open();
    await dto.localDbDataSource.onLoad();
    await dto.remoteClient.onLoad();
    await dto.userNotifier.onLoad(
      local: _localUserInitializer,
      remote: _remoteUserInitializer,
    );
    // final isConnected = await PlatformInfo.isConnected;
    dto.appNotifier.updateAppStatus(
      AppStatus.offline,
      // isConnected ? AppStatus.online : AppStatus.offline,
    );
    if (dto.userNotifier.hasCompletedOnboarding) {
      router.go(ScreenPaths.home);
    } else {
      router.go(ScreenPaths.home);
      // router.go(ScreenPaths.intro);
    }
    unawaited(_loadPost());
  }

  /// ********************************************
  /// *      CONTENT LOADING START
  /// ********************************************
  Future<void> _loadPost() async {
    final emojis = await dto.emojiRepository.getAllEmoji();

    dto.emojiProvider.loadIterable(
      values: emojis,
      toKey: (final p0) => p0.emoji,
    );

    final specialEmojis = await dto.emojiRepository.getSpecialEmoji();
    dto.specialEmojiState.loadIterable(
      values: specialEmojis,
      toKey: (final p0) => p0.emoji,
    );

    final lastUsedEmojis = dto.lastUsedEmojiRepository.getAll();
    dto.lastEmojiState.putAll(lastUsedEmojis);

    await dto.notificationController.onLoad();
  }

  @override
  void dispose() {
    _remoteUserInitializer.dispose();
  }
}
