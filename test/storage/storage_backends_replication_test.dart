import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/settings/features/features.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() async {
    // Call once: repeated mocks desync SharedPreferences' cached instance.
    SharedPreferences.setMockInitialValues({});
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('last_answer_storage');
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
    StorageBackendsNotifier.payloadBuilder = null;
    StorageBackendsNotifier.restoreApplier = null;
  });

  final payloadV1 = jsonEncode({
    'projects': [
      {'id': 'p1', 'title': 'First idea'},
    ],
    'tags': <String>[],
  });
  final payloadV2 = jsonEncode({
    'projects': [
      {'id': 'p1', 'title': 'First idea'},
      {'id': 'p2', 'title': 'Second idea'},
    ],
    'tags': ['tagged'],
  });

  group('filesystem backend', () {
    test('replicate then restore round-trips the payload', () async {
      final notifier = StorageBackendsNotifier.instance;
      await notifier.setFilesystemPath(tempDir.path);

      final report = await notifier.replicate(
        backend: StorageBackendId.filesystem,
        jsonPayload: payloadV1,
      );
      expect(report.ok, isTrue, reason: report.message);
      expect(report.bytes, payloadV1.length);

      // The file actually landed in the chosen folder.
      final file = File('${tempDir.path}/last-answer-data.json');
      expect(file.existsSync(), isTrue);
      expect(await file.readAsString(), payloadV1);

      final restored = await notifier.restore(StorageBackendId.filesystem);
      expect(restored.ok, isTrue, reason: restored.message);
      expect(notifier.lastPayload, payloadV1);
    });

    test('re-replication syncs newer payloads (v2 wins)', () async {
      final notifier = StorageBackendsNotifier.instance;
      await notifier.setFilesystemPath(tempDir.path);

      await notifier.replicate(
        backend: StorageBackendId.filesystem,
        jsonPayload: payloadV1,
      );
      await notifier.replicate(
        backend: StorageBackendId.filesystem,
        jsonPayload: payloadV2,
      );

      final restored = await notifier.restore(StorageBackendId.filesystem);
      expect(restored.ok, isTrue);
      expect(notifier.lastPayload, payloadV2);
    });
  });

  group('git offline backend', () {
    test('replicate then restore round-trips the payload', () async {
      final notifier = StorageBackendsNotifier.instance;
      final gitDir = Directory('${tempDir.path}/repo')..createSync();
      await notifier.setGitPath(gitDir.path);

      final report = await notifier.replicate(
        backend: StorageBackendId.gitOffline,
        jsonPayload: payloadV1,
      );
      expect(report.ok, isTrue, reason: report.message);

      final restored = await notifier.restore(StorageBackendId.gitOffline);
      expect(restored.ok, isTrue, reason: restored.message);
      expect(notifier.lastPayload, payloadV1);
    }, timeout: const Timeout(Duration(minutes: 2)));

    test('re-replication commits and syncs newer payloads', () async {
      final notifier = StorageBackendsNotifier.instance;
      final gitDir = Directory('${tempDir.path}/repo')..createSync();
      await notifier.setGitPath(gitDir.path);

      await notifier.replicate(
        backend: StorageBackendId.gitOffline,
        jsonPayload: payloadV1,
      );
      await notifier.replicate(
        backend: StorageBackendId.gitOffline,
        jsonPayload: payloadV2,
      );

      final restored = await notifier.restore(StorageBackendId.gitOffline);
      expect(restored.ok, isTrue);
      expect(notifier.lastPayload, payloadV2);

      // A versioned repository was really created on disk.
      expect(Directory('${gitDir.path}/.git').existsSync(), isTrue);
    }, timeout: const Timeout(Duration(minutes: 2)));
  });

  group('backend selection persistence', () {
    test('selection survives reload from SharedPreferences', () async {
      final notifier = StorageBackendsNotifier.instance;
      await notifier.selectBackend(StorageBackendId.filesystem);
      await notifier.setFilesystemPath('/tmp/last-answer-fs');

      final reloaded = StorageBackendsNotifier.instance;
      await reloaded.load();

      expect(reloaded.active, StorageBackendId.filesystem);
      expect(reloaded.filesystemPath, '/tmp/last-answer-fs');
      expect(reloaded.isConfigured, isTrue);
    });

    test('unknown persisted name falls back to localDb', () async {
      // Same cached mock store the singleton already holds.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'storage_backend_config_v1',
        jsonEncode({'backend': 'nope'}),
      );
      final notifier = StorageBackendsNotifier.instance;
      await notifier.load();
      expect(notifier.active, StorageBackendId.localDb);
    });
  });

  group('payload hooks (used by MCP tools without UI)', () {
    test('backupNow uses payloadBuilder and restoreNow applies', () async {
      final notifier = StorageBackendsNotifier.instance;
      final gitDir = Directory('${tempDir.path}/repo-hooks')..createSync();
      await notifier.setGitPath(gitDir.path);
      await notifier.selectBackend(StorageBackendId.gitOffline);

      String? applied;
      StorageBackendsNotifier.payloadBuilder = () async => payloadV1;
      StorageBackendsNotifier.restoreApplier = (final json) async {
        applied = json;
      };

      final backup = await notifier.backupNow();
      expect(backup.ok, isTrue, reason: backup.message);

      var restored = await notifier.restoreNow();
      expect(restored.ok, isTrue, reason: restored.message);
      expect(applied, payloadV1);

      // Read-only restore does not touch the live DB.
      applied = null;
      restored = await notifier.restoreNow(apply: false);
      expect(restored.ok, isTrue);
      expect(applied, isNull);
    }, timeout: const Timeout(Duration(minutes: 2)));
  });
}
