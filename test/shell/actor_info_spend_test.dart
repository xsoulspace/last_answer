// ignore_for_file: lines_longer_than_80_chars

/// The actor info tab's durable IMAGE SPEND section (the ledger's
/// per-actor projection, native-image-assets follow-up): rows folded
/// from the realm store render the honest line; an actor with no rows
/// renders NO section — honest absence, not zeros. REAL IO for the
/// store writes (the house image-test law).
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_bot_host.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_world.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/ui_shell/actor_info_surface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';

void main() {
  testWidgets('the actor info tab renders the folded image spend line',
      (final tester) async {
    SharedPreferences.setMockInitialValues({});
    late final RealmWorld world;
    late final RealmChatService service;
    await tester.runAsync(() async {
      final temp = await Directory.systemTemp.createTemp('actor_spend_ws_');
      addTearDown(() => temp.delete(recursive: true));
      world = (await RealmWorld.open(rootOverride: temp.path))!;
      service = RealmChatService(
        debugWorldOverride: world,
        debugRosterOverride: ActorRoster(replicaId: 'tester'),
        debugStartBotDispatcher: false,
      );
      addTearDown(service.dispose);
      service.firstRunSeedEnabled = false;
      await service.ensureReady();
    });

    // Slice-2 rows: one settled + one refused — the projection's full
    // honest line.
    await tester.runAsync(() async {
      // 0.28 admits the first 0.25 call, then 0.28 − 0.04 committed
      // = 0.24 remaining refuses the next one.
      final ledger = RealmImageSpendLedger(world.store, ceilingUsd: 0.28);
      final first = await ledger.reserve(
        actor: 'scout',
        requestId: 'spend-1',
        images: 1,
      );
      expect(first, isNull);
      await ledger.settle(
        actor: 'scout',
        requestId: 'spend-1',
        images: 1,
        costUsd: 0.04,
        providerId: 'openrouter',
        modelId: 'test-image-model',
      );
      final refused = await ledger.reserve(
        actor: 'scout',
        requestId: 'spend-2',
        images: 1,
      );
      expect(refused!.code, 'image_budget_exhausted');
    });

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        home: Scaffold(
          body: ActorInfoSurface(service: service, actorId: 'scout'),
        ),
      ),
    );
    // The fold rides an async store scan — settle the future.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    expect(find.byKey(const ValueKey('actor.info.imageSpend')), findsOneWidget);
    expect(find.textContaining(r'$0.04'), findsOneWidget);
    expect(find.textContaining('refused'), findsOneWidget);
  });

  testWidgets('an actor with no spend rows renders NO section',
      (final tester) async {
    SharedPreferences.setMockInitialValues({});
    late final RealmChatService service;
    await tester.runAsync(() async {
      final temp = await Directory.systemTemp.createTemp('actor_spend_ws2_');
      addTearDown(() => temp.delete(recursive: true));
      final world = (await RealmWorld.open(rootOverride: temp.path))!;
      service = RealmChatService(
        debugWorldOverride: world,
        debugRosterOverride: ActorRoster(replicaId: 'tester'),
        debugStartBotDispatcher: false,
      );
      addTearDown(service.dispose);
      service.firstRunSeedEnabled = false;
      await service.ensureReady();
    });
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        home: Scaffold(
          body: ActorInfoSurface(service: service, actorId: 'weaver'),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    expect(find.byKey(const ValueKey('actor.info.imageSpend')), findsNothing);
  });

  testWidgets('the NOW section folds the live status; absent facts '
      'render nothing', (final tester) async {
    SharedPreferences.setMockInitialValues({});
    late final RealmChatService service;
    late final String scoutId;
    await tester.runAsync(() async {
      final temp = await Directory.systemTemp.createTemp('actor_now_ws_');
      addTearDown(() => temp.delete(recursive: true));
      final world = (await RealmWorld.open(rootOverride: temp.path))!;
      service = RealmChatService(
        debugWorldOverride: world,
        debugRosterOverride: ActorRoster(replicaId: 'tester'),
        debugStartBotDispatcher: false,
      );
      addTearDown(service.dispose);
      service.firstRunSeedEnabled = false;
      await service.ensureReady();
      final scout = (await service.createActor(
        displayName: 'Scout',
        kind: ActorKind.model,
        brainRef: '',
      ))!;
      scoutId = scout.actorId;
    });
    service.debugNarrationOverride = <String, BotNarration>{
      scoutId: BotNarration(
        state: BotNarrationState.generating,
        detail: 'lab',
        since: DateTime.now(),
      ),
    };
    Widget surface(final String actorId) => MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: S.localizationsDelegates,
      supportedLocales: S.supportedLocales,
      home: Scaffold(
        body: ActorInfoSurface(service: service, actorId: actorId),
      ),
    );
    await tester.pumpWidget(surface(scoutId));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    expect(find.byKey(const ValueKey('actor.info.now')), findsOneWidget);
    expect(find.text('working'), findsOneWidget);
    expect(find.text('generating reply to lab'), findsOneWidget);

    // An id with no foldable facts: NO section — honest absence.
    await tester.pumpWidget(surface('no-such-actor'));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    expect(find.byKey(const ValueKey('actor.info.now')), findsNothing);
  });
}
