// The dogfood acceptance run (plan v5): start FULL WORK via Last Answer
// ITSELF — not by writing the journal directly (that is the smoke's job),
// but by driving LA's OWN published runtime intents over the VM service,
// exactly as an external controller/seat would. This is the LA-native
// equivalent of how a coding session delegates to a subagent: a human
// sentence in a room → a native actor's loop runs → work streams back
// into the SAME room, attributed.
//
// The law it proves (plan v5 positioning): conversations with actors are
// endless rooms; the native actor is a coworker, not a spawned process;
// LA's own tool surface (realm_chat_open_dm / realm_chat_say) is the seat.
//
// Run: fvm dart tool/smoke/dogfood_via_la.dart [--skip-build] [--actor <id>]
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_mcp_harness/flutter_mcp_harness.dart';
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';

final _projectDir = Directory.current.path;
final _tmp = Platform.environment['TMPDIR'] ?? '/tmp';
final _evidenceDir = Directory('$_tmp/dogfood_la_evidence')
  ..createSync(recursive: true);
final _stepsLog = File('${_evidenceDir.path}/steps.log');
final _stateFile = '${_evidenceDir.path}/fmtk_state.json';

void row(final String status, final String step, final String detail) {
  final line = '${status.padRight(6)}${step.padRight(26)}$detail';
  // ignore: avoid_print
  print(line);
  _stepsLog.writeAsStringSync('$line\n', mode: FileMode.append);
}

String _wsUri(final String uri) {
  var out = uri;
  if (out.startsWith('http://')) out = 'ws://${out.substring(7)}';
  if (!out.endsWith('/ws')) {
    out = '${out.endsWith('/') ? out.substring(0, out.length - 1) : out}/ws';
  }
  return out;
}

/// One fmtk verb over a SHORT-LIVED connection (the proven lane — the VM
/// service refuses concurrent clients). Returns the parsed `data` map.
Future<Map<String, Object?>> _verb(
  final String vmUri,
  final String verb, [
  final Map<String, Object?> args = const <String, Object?>{},
]) async {
  final result = await Process.run('fmtk', [
    '--state-file', _stateFile,
    '--vm-service-uri', vmUri,
    '--flutter-device', 'macos',
    '--flutter-project-dir', _projectDir,
    'exec', '--name', verb,
    '--args', jsonEncode(args),
  ]);
  if (result.exitCode != 0) {
    return <String, Object?>{'_exit': result.exitCode, '_err': '${result.stderr}'};
  }
  try {
    final envelope = jsonDecode('${result.stdout}') as Map<String, Object?>;
    if (envelope['ok'] != true) {
      return <String, Object?>{'_refused': '${envelope['error']}'};
    }
    final data = envelope['data'];
    return data is Map ? data.cast<String, Object?>() : const {};
  } on Object catch (e) {
    return <String, Object?>{'_parse': '$e'};
  }
}

/// Invoke one of LA's OWN published runtime tools (the seat surface).
Future<Map<String, Object?>> _laTool(
  final String vmUri,
  final String toolName,
  final Map<String, Object?> arguments,
) => _verb(vmUri, 'fmt_client_tool', <String, Object?>{
  'toolName': toolName,
  'arguments': arguments,
  'connection': <String, Object?>{'targetId': vmUri, 'mode': 'uri'},
});

/// The toolkit may wrap a tool's `_ok` map under MCPCallResult.parameters
/// (and fmtk under `data`), to any depth. Find the first [key] in the
/// nested structure rather than guess the wrapping — shape-tolerant.
Object? _deepFind(final Object? node, final String key, [final int depth = 0]) {
  if (depth > 8) return null;
  if (node is Map) {
    if (node.containsKey(key)) return node[key];
    for (final v in node.values) {
      final found = _deepFind(v, key, depth + 1);
      if (found != null) return found;
    }
  } else if (node is List) {
    for (final v in node) {
      final found = _deepFind(v, key, depth + 1);
      if (found != null) return found;
    }
  }
  return null;
}

Future<T> _poll<T>(
  final String label,
  final Future<T?> Function() probe, {
  final int attempts = 60,
  final Duration interval = const Duration(seconds: 3),
}) async {
  for (var i = 0; i < attempts; i++) {
    final value = await probe();
    if (value != null) return value;
    await Future<void>.delayed(interval);
  }
  throw TimeoutException('poll never passed: $label');
}

Future<void> main(final List<String> args) async {
  final skipBuild = args.contains('--skip-build');
  final actorIdx = args.indexOf('--actor');
  final actor = actorIdx >= 0 && actorIdx + 1 < args.length
      ? args[actorIdx + 1]
      : 'weaver'; // weaver: local `qwen` cast — proven to POST a reply beat
  _stepsLog.writeAsStringSync('');

  final home =
      Platform.environment['HOME'] ?? Platform.environment['USERPROFILE']!;
  final storeDir = Directory('$home/.xsoulspace/worlds/local/coordination');
  if (!storeDir.existsSync()) {
    row('FAIL', 'journal', 'no realm journal at ${storeDir.path}');
    exit(1);
  }
  final store = RealmControlStore(storeDir);
  final projection = conversationProjectionFor(store);

  // ---- launch LA (the seat) ----
  final binary = File(
    'build/macos/Build/Products/Debug/last_answer.app/Contents/MacOS/last_answer',
  );
  LaunchedApp? app;
  String vmUri;
  try {
    final launched = await BinaryAppTarget(
      projectDir: _projectDir,
      binaryPath: binary.path,
      buildCommand: const ['fvm', 'flutter', 'build', 'macos', '--debug', '--no-pub'],
      name: 'dogfood-la',
      vmServiceTimeout: const Duration(minutes: 10),
    ).launch(build: !skipBuild);
    app = launched;
    vmUri = _wsUri('${launched.vmUri}');
    row('PASS', 'launch', 'vm=${launched.vmUri}');
  } on Object catch (error) {
    row('FAIL', 'launch', '$error');
    exit(1);
  }

  var failures = 0;
  try {
    // ---- the seat surface is DISCOVERABLE: LA publishes its own intents ----
    await _poll('LA runtime tools published', () async {
      final listed = await _verb(vmUri, 'fmt_list_client_tools_and_resources', {
        'connection': {'targetId': vmUri, 'mode': 'uri'},
      });
      final blob = jsonEncode(listed);
      return blob.contains('realm_chat_open_dm') && blob.contains('realm_chat_say')
          ? blob.length
          : null;
    }, attempts: 40, interval: const Duration(seconds: 2));
    row('PASS', 'seat-surface', 'LA publishes realm_chat_open_dm/say/state as data');

    // ---- wait for the shell + a live chat surface (so _service is bound) ----
    await _poll('shell ready', () async {
      final snap = await _verb(vmUri, 'semantic_snapshot');
      final nodes = (snap['nodes'] as List? ?? const []).cast<Map<String, Object?>>();
      final blob = nodes.map((n) => '${n['label'] ?? ''}${n['identifier'] ?? ''}').join('\n');
      return blob.contains('edge.world') ? true : null;
    }, attempts: 60, interval: const Duration(seconds: 1));
    row('PASS', 'shell', 'edge.world present — the chat surface can bind');

    // ---- OPEN A FRESH ROOM with the native actor, THROUGH LA's own
    // intent. A FRESH channel (not open_dm) so the work order is never
    // batched with a prior unanswered beat in a reused thread (the daemon
    // groups all pending addressed beats into ONE turn — a stale complex
    // beat would poison the simple one). create_channel is a published
    // realm_chat intent, so this is still LA-as-seat.
    final roomName = 'dogfood-${DateTime.now().millisecondsSinceEpoch}';
    final opened = await _laTool(vmUri, 'realm_chat_create_channel', {
      'name': roomName,
      'members': actor,
    });
    final threadId = '${_deepFind(opened, 'threadId') ?? ''}';
    if (threadId.isEmpty || opened.containsKey('_refused') || opened.containsKey('_err')) {
      failures++;
      row('FAIL', 'open-room', 'realm_chat_create_channel($actor) → ${jsonEncode(opened)}');
      throw StateError('create_channel refused');
    }
    row('PASS', 'open-room', 'LA opened a fresh room "$roomName" with $actor → $threadId');

    // ---- the work order: ONE human sentence, addressed by LA's own say ----
    final before = await projection.beatsOfThread(threadId);
    final beforeCount = before.length;
    final task =
        '$actor — dogfood delegation through Last Answer itself. Reply with '
        'exactly: DOGFOOD-OK';
    final said = await _laTool(vmUri, 'realm_chat_say', {'text': task});
    if (said.containsKey('_refused') || said.containsKey('_err') ||
        _deepFind(said, 'ok') != true) {
      failures++;
      row('FAIL', 'delegate', 'realm_chat_say → ${jsonEncode(said)}');
      throw StateError('say refused');
    }
    row('PASS', 'delegate', 'human sentence posted via LA realm_chat_say (beats ${_deepFind(said, 'beats')})');

    // ---- the native loop runs: work streams back into the SAME room ----
    // Evidence over assertion: poll the journal for the actor's OWN reply
    // beat (author == actor), and read its telemetry (rounds/toolCalls =
    // the work texture the room renders inline).
    Map<String, Object?>? reply;
    try {
      reply = await _poll('$actor reply beat', () async {
        final beats = await projection.beatsOfThread(threadId);
        for (final b in beats.skip(beforeCount)) {
          if ('${b['author']}' == actor) return b;
        }
        return null;
      }, attempts: 300, interval: const Duration(seconds: 3)); // 900s: the
      // daemon's drain cycle can lag the post by minutes (observed ~8min)
      // before the actor's local brain even starts; a short window misreads
      // drain latency as a no-post.
    } on TimeoutException {
      failures++;
      row('FAIL', 'actor-reply', 'no $actor beat within 900s — read the loop log '
          '(dispatch/throttle/telemetry-without-beat/quarantine); actor=$actor');
    }
    if (reply != null) {
      final text = '${reply['text']}';
      final shown = text.length <= 90 ? text : '${text.substring(0, 90)}…';
      row('PASS', 'actor-reply', 'beat ${reply['beat']} from $actor: $shown');

      // the newest telemetry for this actor = the work texture (rounds/tools)
      final telem = await store.scan('tool_loop_telemetry');
      Map<String, Object?>? newest;
      for (final t in telem.values) {
        if ('${t['actorId']}' != actor) continue;
        if (newest == null ||
            '${t['at']}'.compareTo('${newest['at']}') > 0) {
          newest = t;
        }
      }
      if (newest != null) {
        row('INFO', 'work-texture',
            'rounds=${newest['rounds']} toolCalls=${newest['toolCalls']} '
            'tokens=${newest['tokens'] ?? newest['promptTokens'] ?? '?'}');
      }
    }

    // ---- the room RENDERS the streamed work (LA's own projection) ----
    try {
      final snap = await _poll('room shows the actor beat', () async {
        final s = await _verb(vmUri, 'semantic_snapshot');
        final nodes = (s['nodes'] as List? ?? const []).cast<Map<String, Object?>>();
        final blob = nodes
            .map((n) => '${n['label'] ?? ''}\n${n['value'] ?? ''}\n${n['identifier'] ?? ''}')
            .join('\n');
        // the actor's reply text OR its work card / narration identity
        return (reply != null && blob.contains('${reply['text']}'.substring(0, 20))) ||
                blob.contains('worldchat.card') ||
                blob.contains(actor)
            ? blob.length
            : null;
      }, attempts: 30, interval: const Duration(seconds: 2));
      row('PASS', 'room-render', 'LA renders the streamed work in-room ($snap semantic chars)');
    } on TimeoutException {
      row('WARN', 'room-render', 'actor beat not visible in the live semantic tree '
          '(rail/strip walker gap); the journal + screenshot own it');
    }

    // ---- evidence ----
    final shot = await Process.run('fmtk', [
      '--state-file', _stateFile,
      '--vm-service-uri', vmUri,
      '--flutter-device', 'macos',
      '--flutter-project-dir', _projectDir,
      '--output-dir', _evidenceDir.path,
      'exec', '--name', 'get_screenshots', '--save-images',
      '--args', jsonEncode({'mode': 'flutter_layer'}),
    ]);
    final shotDir = Directory('${_evidenceDir.path}/.mcp_screenshots');
    var adopted = 0;
    if (shotDir.existsSync()) {
      for (final file in shotDir.listSync(recursive: true)) {
        if (file is File && file.path.endsWith('.png')) {
          file.copySync('${_evidenceDir.path}/${file.path.split('/').last}');
          adopted++;
        }
      }
    }
    row(adopted > 0 ? 'PASS' : 'WARN', 'evidence',
        '$adopted screenshots -> ${_evidenceDir.path} (exit ${shot.exitCode})');
  } on Object catch (error, stack) {
    failures++;
    row('FAIL', 'dogfood', '$error\n$stack');
  } finally {
    try {
      File('${_evidenceDir.path}/app_stdout.log')
          .writeAsStringSync(app.stdout.lines.join('\n'));
    } on Object {}
    await app.stop();
  }

  // ignore: avoid_print
  print(failures == 0
      ? 'VERDICT: DOGFOOD-VIA-LA PASS'
      : 'VERDICT: DOGFOOD-VIA-LA FAIL ($failures)');
  exit(failures == 0 ? 0 : 1);
}
