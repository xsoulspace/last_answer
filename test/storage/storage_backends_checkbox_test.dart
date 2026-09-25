import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/settings/features/features.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final notifier = StorageBackendsNotifier.instance;

  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  late Directory tempDir;

  Future<void> resetStorage() async {
    await notifier.setEnabled(StorageBackendId.filesystem, value: false);
    await notifier.setEnabled(StorageBackendId.gitOffline, value: false);
    await notifier.setEnabled(StorageBackendId.mesh, value: false);
    await notifier.setFilesystemPath('');
    await notifier.setGitPath('');
    await notifier.setMeshConfig(
      storePath: '',
      relayEndpoint: '',
      port: 0,
    );
    await notifier.setPrimary(StorageBackendId.localDb);
  }

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('la_checkbox');
    await resetStorage();
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

  group('v1 -> v2 migration', () {
    test('legacy "backend" selection becomes enabled + primary', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('storage_backend_config_v2');
      await prefs.setString(
        'storage_backend_config_v1',
        jsonEncode({
          'backend': 'filesystem',
          'fsPath': '/tmp/legacy-migrated',
        }),
      );

      await notifier.load();

      expect(notifier.primary, StorageBackendId.filesystem);
      expect(notifier.enabled, contains(StorageBackendId.filesystem));
      expect(notifier.enabled, contains(StorageBackendId.localDb));
      expect(notifier.filesystemPath, '/tmp/legacy-migrated');
      expect(prefs.containsKey('storage_backend_config_v2'), isTrue);
    });

    test('legacy unknown name falls back, keeping localDb primary', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('storage_backend_config_v2');
      await prefs.setString(
        'storage_backend_config_v1',
        jsonEncode({'backend': 'nope'}),
      );

      await notifier.load();

      expect(notifier.primary, StorageBackendId.localDb);
      expect(notifier.enabled, contains(StorageBackendId.localDb));
      expect(notifier.enabled, isNotEmpty);
    });
  });

  group('checkbox semantics', () {
    test('multiple backends can be enabled at once and persist', () async {
      await notifier.setEnabled(StorageBackendId.filesystem, value: true);
      await notifier.setFilesystemPath('${tempDir.path}/sub');
      await notifier.setEnabled(StorageBackendId.gitOffline, value: true);
      final gitDir = Directory('${tempDir.path}/repo')..createSync();
      await notifier.setGitPath(gitDir.path);

      expect(notifier.enabled, contains(StorageBackendId.filesystem));
      expect(notifier.enabled, contains(StorageBackendId.gitOffline));
      expect(notifier.enabled, contains(StorageBackendId.localDb));
      expect(notifier.primary, StorageBackendId.localDb);

      final reloaded = StorageBackendsNotifier.instance;
      await reloaded.load();
      expect(reloaded.enabled, contains(StorageBackendId.filesystem));
      expect(reloaded.enabled, contains(StorageBackendId.gitOffline));
    });

    test('disabling the primary promotes another enabled backend', () async {
      await notifier.setEnabled(StorageBackendId.filesystem, value: true);
      await notifier.setFilesystemPath('${tempDir.path}/a');
      await notifier.setEnabled(StorageBackendId.gitOffline, value: true);
      final gitDir = Directory('${tempDir.path}/repo2')..createSync();
      await notifier.setGitPath(gitDir.path);
      await notifier.setPrimary(StorageBackendId.gitOffline);
      expect(notifier.primary, StorageBackendId.gitOffline);

      await notifier.setEnabled(StorageBackendId.gitOffline, value: false);
      expect(notifier.isEnabled(StorageBackendId.gitOffline), isFalse);
      expect(notifier.primary, StorageBackendId.filesystem);

      await notifier.setEnabled(StorageBackendId.filesystem, value: false);
      expect(notifier.primary, StorageBackendId.localDb);
    });

    test('localDb can never be disabled', () async {
      await notifier.setEnabled(StorageBackendId.localDb, value: false);
      expect(notifier.isEnabled(StorageBackendId.localDb), isTrue);
    });

    test('setPrimary rejects a disabled backend', () async {
      await notifier.setEnabled(StorageBackendId.filesystem, value: true);
      await notifier.setFilesystemPath('${tempDir.path}/x');
      // Primary cannot jump to a disabled backend.
      await notifier.setPrimary(StorageBackendId.gitOffline);
      expect(notifier.primary, StorageBackendId.localDb);
    });
  });

  group('backup fan-out', () {
    test('Back up now writes to every enabled configured target', () async {
      StorageBackendsNotifier.payloadBuilder = () async => payloadV1;

      await notifier.setEnabled(StorageBackendId.filesystem, value: true);
      await notifier.setFilesystemPath('${tempDir.path}/one');
      await notifier.setEnabled(StorageBackendId.gitOffline, value: true);
      final gitDir = Directory('${tempDir.path}/fanout')..createSync();
      await notifier.setGitPath(gitDir.path);

      final report = await notifier.backupNow();
      expect(report.ok, isTrue, reason: report.message);
      expect(report.message, contains('filesystem'));
      expect(report.message, contains('gitOffline'));

      expect(
        File('${tempDir.path}/one/last-answer-data.json').existsSync(),
        isTrue,
      );
      expect(
        File('${tempDir.path}/fanout/last-answer-data.json').existsSync(),
        isTrue,
      );

      final restored = await notifier.restoreNow(apply: false);
      expect(restored.ok, isTrue);
      expect(notifier.lastPayload, payloadV1);
    }, timeout: const Timeout(Duration(minutes: 2)));

    test('backupNow with explicit backend targets only that backend', () async {
      StorageBackendsNotifier.payloadBuilder = () async => payloadV1;

      await notifier.setEnabled(StorageBackendId.filesystem, value: true);
      await notifier.setFilesystemPath('${tempDir.path}/two');

      final report = await notifier.backupNow(
        backend: StorageBackendId.filesystem,
      );
      expect(report.ok, isTrue, reason: report.message);
      expect(
        File('${tempDir.path}/two/last-answer-data.json').existsSync(),
        isTrue,
      );
    });

    test('restore defaults to the primary backend', () async {
      StorageBackendsNotifier.payloadBuilder = () async => payloadV1;
      StorageBackendsNotifier.restoreApplier = (final _) async {};

      await notifier.setEnabled(StorageBackendId.filesystem, value: true);
      await notifier.setFilesystemPath('${tempDir.path}/three');
      await notifier.setEnabled(StorageBackendId.gitOffline, value: true);
      final gitDir = Directory('${tempDir.path}/repo3')..createSync();
      await notifier.setGitPath(gitDir.path);
      await notifier.setPrimary(StorageBackendId.gitOffline);

      final payload = jsonEncode(payloadV1);
      await notifier.replicate(
        backend: StorageBackendId.gitOffline,
        jsonPayload: payload,
      );
      await notifier.replicate(
        backend: StorageBackendId.filesystem,
        jsonPayload: jsonEncode({'projects': [], 'tags': []}),
      );

      final restored = await notifier.restoreNow();
      expect(restored.ok, isTrue);
      // Primary (gitOffline) copy wins for the default restore.
      expect(notifier.lastPayload, payload);
    }, timeout: const Timeout(Duration(minutes: 2)));
  });
}
