// ignore_for_file: lines_longer_than_80_chars

/// The F1 PROOF (native-image-assets DMs/channels wave): a human share
/// — bytes → `media v1` attachment → `say` → the durable record → the
/// projection → the rendered media card in the room. Every stage is
/// the REAL production code on a hermetic world; the live-app drive is
/// the same path (the composer's image button) — the hermetic run
/// just settles deterministically.
library;

import 'dart:convert' show utf8;
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/media_asset_card.dart';
import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_chat_media.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_world.dart';
import 'package:lastanswer/coding_agent/realm_chat/world_chat_surface.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_models/shared_models.dart' show ActorKind;

/// A VALID png (real CRC — Flutter's own decoder reads it).
Uint8List pngBytes({final int width = 64, final int height = 48}) {
  final b = BytesBuilder();
  b.add([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]);
  final ihdr = BytesBuilder()
    ..add([...utf8.encode('IHDR')])
    ..add([
      (width >> 24) & 0xff, (width >> 16) & 0xff,
      (width >> 8) & 0xff, width & 0xff,
      (height >> 24) & 0xff, (height >> 16) & 0xff,
      (height >> 8) & 0xff, height & 0xff,
      8, 6, 0, 0, 0,
    ]);
  final chunk = ihdr.toBytes();
  final length = chunk.length - 4;
  b.add([0, 0, (length >> 8) & 0xff, length & 0xff]);
  b.add(chunk);
  b.add([0, 0, 0, 0, 0x49, 0x45, 0x4e, 0x44, 0xae, 0x42, 0x60, 0x82]);
  return b.toBytes();
}

void main() {
  testWidgets('a human image share lands as a media card in the room',
      (final tester) async {
    // ignore: avoid_print

    SharedPreferences.setMockInitialValues({});
    final pin = Directory.systemTemp.createTempSync('wc_media_proof_');
    RealmWorld.debugDeviceHome = pin.path;
    addTearDown(() {
      RealmWorld.debugDeviceHome = null;
      pin.deleteSync(recursive: true);
    });

    late final RealmWorld world;
    late final RealmChatService service;
    late final String threadId;
    await tester.runAsync(() async {

      final temp = await Directory.systemTemp.createTemp('wc_media_ws_');
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
      // A DM needs a peer: create one worker actor and open the DM
      // (the messages-test fixture pattern — a fresh service starts
      // with no active thread).
      final peer = (await service.createActor(
        displayName: 'Worker A',
        kind: ActorKind.model,
        brainRef: '',
      ))!;
      await service.openDm(peer.actorId);
      threadId = service.activeThreadId!;
    });
    expect(service.isReady, isTrue, reason: service.error);

    // The SHARE: bytes → the media v1 entry (sniffed mime/dims +
    // sha256-16 revision, file copied into the world asset dir).
    // REAL IO — the write, the say and the journal watch all run
    // outside the fake-async zone (the house image-test law).
    late final Map<String, Object?> entry;
    await tester.runAsync(() async {
      final share = RealmChatMediaShare(worldHome: pin);
      entry = await share.buildFromBytes(
        bytes: pngBytes(width: 64, height: 48),
        threadId: threadId,
        nameHint: 'lighthouse.png',
      );
      await service.say(
        'The proof image — a two-tone lighthouse card.',
        attachments: [entry],
      );
    });
    expect(entry['kind'], 'media');
    expect(entry['mimeType'], 'image/png');
    expect((entry['width'] as num), 64);
    expect((entry['revision'] as String).length, 16);
    // The file landed under the world's asset dir, byte-exact.
    final assetFile = File(entry['path']! as String);
    expect(assetFile.existsSync(), isTrue);
    expect(assetFile.lengthSync(), greaterThan(0));
    // The projection refreshes through the watch debounce; re-select
    // forces the public refresh lane (the house pattern).
    await tester.runAsync(() async {
      for (var waited = 0; waited < 20; waited++) {
        if ((await service.beatsFor(threadId)).last['attachments'] != null) {
          break;
        }
        await Future<void>.delayed(const Duration(milliseconds: 150));
      }
    });
    final beats =
        await tester.runAsync(() => service.beatsFor(threadId)) ?? const [];
    expect(beats, isNotEmpty, reason: 'the share beat must land');
    final shared = beats.last;
    expect(shared['text'], contains('The proof image'));
    // The TEXT projection rode the record (the header line).
    expect(shared['text'], contains('asset-media v1 mime=image/png'));
    final recordAttachments = (shared['attachments']! as List).cast<Map>();
    expect(recordAttachments, hasLength(1));
    expect(recordAttachments.single['revision'], entry['revision']);

    // The RENDER: the room shows the honest card from the file.
    await tester.pumpWidget(
      ChangeNotifierProvider<RealmChatService>.value(
        value: service,
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: S.localizationsDelegates,
          supportedLocales: S.supportedLocales,
          home: Scaffold(body: WorldChatSurface(service: service)),
        ),
      ),
    );
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 120));
      if (find.byType(MediaAssetCard).evaluate().isNotEmpty) break;
    }
    expect(find.byType(MediaAssetCard), findsOneWidget);
    expect(find.textContaining('The proof image'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('a share refusal is named: the non-media bytes refuse',
      (final tester) async {
    final dir = Directory.systemTemp.createTempSync('wc_media_refuse_');
    addTearDown(() => dir.deleteSync(recursive: true));
    final share = RealmChatMediaShare(worldHome: dir);
    expect(
      share.buildFromBytes(
        bytes: Uint8List.fromList(utf8.encode('# not an image')),
        threadId: 'thread-x',
      ),
      throwsA(isA<RealmMediaShareException>().having(
        (e) => e.code,
        'code',
        'media_share_not_media',
      )),
    );
  });
}
