// ignore_for_file: avoid_print

/// ONE-OFF: install LA on the USB-connected phone and smoke-test it over
/// the toolkit verbs — boot, embedded world state, the honest external
/// refusal (no manifests / no paired worlds on a phone), and a
/// screenshot for evidence. Usage:
///   fvm dart run tool/phone_smoke.dart <device-id>
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_mcp_harness/flutter_mcp_harness.dart';
import 'package:oka_harness/oka_harness.dart';

Future<void> main(final List<String> args) async {
  final deviceId = args.first;
  final tmp = Platform.environment['TMPDIR'] ?? '/tmp';
  final target = AndroidAppTarget(
    projectDir: '.',
    deviceId: deviceId,
    name: 'phone-smoke',
    environment: {
      'ANDROID_SDK_ROOT': '/Users/antonio/.oka/android-sdk',
      'OKA_ANDROID_SDK': '/Users/antonio/.oka/android-sdk',
    },
    sessionTimeout: const Duration(minutes: 15),
  );
  print('building + installing on $deviceId …');
  final app = await target.launch();
  print('LAUNCHED vm=${app.vmUri}');
  final vm = await VmClient.connect(app.vmUri);

  Future<void> waitVerb(final String name) async {
    for (var i = 0; i < 60; i++) {
      try {
        if ((await vm.extensionNames()).contains('ext.mcp.toolkit.$name')) {
          return;
        }
      } on Object catch (_) {}
      await Future<void>.delayed(const Duration(seconds: 1));
    }
    throw StateError('verb never registered: $name');
  }

  Future<Map<String, Object?>> verb(
    final String name, [
    final Map<String, Object?> args = const {},
  ]) async =>
      vm.callExtension('ext.mcp.toolkit.$name', args: args);

  var failures = 0;
  void check(final bool ok, final String step, final String detail) {
    print('${ok ? "PASS" : "FAIL"}  $step  $detail');
    if (!ok) failures++;
  }

  await waitVerb('app_intents');
  final intents = await verb('app_intents', {'group': 'inspector'});
  check(
    intents['ok'] == true,
    'app-intents',
    '${intents['count']} inspector intents published',
  );

  await waitVerb('world_inspector_state');
  final state = await verb('world_inspector_state');
  check(
    state['ok'] == true,
    'world-state',
    'embedded pane projection: ${state['summary'] ?? state['message']}',
  );
  check(
    state['external'] != true,
    'embedded-default',
    'no binding — the pane samples the embedded registry (default path)',
  );

  // The OSS connect contract on a phone: nothing to attach to until the
  // user pairs or adds an endpoint — the refusal must be HONEST.
  final attach = await verb('world_inspector_attach');
  check(
    attach['ok'] == false,
    'attach-honest-refusal',
    '${attach['message']?.toString().split('.').first}.',
  );

  try {
    final shot = await verb('view_screenshots', {'compress': true});
    final images = shot['images'];
    final path = '$tmp/phone_smoke_evidence.json';
    File(path).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(shot));
    check(images is List && images.isNotEmpty, 'screenshot', 'saved $path');
  } on Object catch (e) {
    print('INFO  screenshot  unavailable: ${e.toString().split('\n').first}');
  }

  print(failures == 0 ? 'VERDICT  PASS' : 'VERDICT  FAIL ($failures)');
  exitCode = failures == 0 ? 0 : 1;
  // Keep the app running on the phone for the user; just end the VM link.
  unawaited(Future<void>.delayed(const Duration(seconds: 1)));
}
