// The work-order acceptance run (the scoping model, owner-approved
// 2026-11-09): prove the FULL delegation loop from a GENERAL room —
// the human sentence in a realm-sealed room, LA auto-spawning the
// project-SEALED work thread (ADR 0129: the seal is the daemon
// actor's sandbox), the native actor editing a real file IN THE NAMED
// REPO, running its own acceptance through the armed run allowlist,
// and the reply beat landing attributed in the work thread.
//
// The law it proves: general rooms stay conversational (no project,
// no sandbox); WORK gets a sealed thread per (room × project); the
// actor's workRoot is the repo the order named — never the daemon's
// own project (the projectless-fallback gun, filed in surface_gaps.md).
//
// The smoke is the mechanism proof, not the adoption authority: the
// actor's edit is verified (git diff receipt saved to the evidence
// dir) and then RESTORED, so runs are repeatable. --keep-edit leaves
// it in the tree for a human adoption demo.
//
// Run: fvm dart tool/smoke/work_order_smoke.dart [--skip-build]
//      [--actor cache-probe] [--keep-edit]
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_mcp_harness/flutter_mcp_harness.dart';
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';

final _projectDir = Directory.current.path;
final _tmp = Platform.environment['TMPDIR'] ?? '/tmp';
final _evidenceDir = Directory('$_tmp/work_order_evidence')
  ..createSync(recursive: true);
final _stepsLog = File('${_evidenceDir.path}/steps.log');
final _stateFile = '${_evidenceDir.path}/fmtk_state.json';

/// The workspace the work order targets — this repo. The seal makes it
/// the actor's filesystem root; the same path the human grant names.
final _targetRepo = _projectDir;

/// The file the actor edits (committed, real content, harmless — and
/// the postscript it adds is genuinely useful documentation).
const _targetFile = 'docs/design/visual-feedback-loop-analysis-2026-11-08.md';

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

/// One fmtk verb over a SHORT-LIVED connection (the proven lane — the
/// VM service refuses concurrent clients).
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

/// Shape-tolerant deep find (the toolkit wraps results to any depth).
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
  final keepEdit = args.contains('--keep-edit');
  final actorIdx = args.indexOf('--actor');
  // cache-probe (modelscope_qwen37plus): the cheap rung the owner wants
  // for iteration, historically the healthiest loops, LA-granted
  // 2026-11-09 via the canonical `ecsai --grant`.
  final actor = actorIdx >= 0 && actorIdx + 1 < args.length
      ? args[actorIdx + 1]
      : 'cache-probe';
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

  // Precondition: a clean edit surface for the actor's file (the smoke
  // restores what it verifies; a dirty target file would blur the
  // receipt). Uncommitted work ELSEWHERE in the repo is none of this
  // smoke's business.
  final targetPath = '$_targetRepo/$_targetFile';
  if (!File(targetPath).existsSync()) {
    row('FAIL', 'precondition', 'target file missing: $_targetFile');
    exit(1);
  }

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
      name: 'work-order-smoke',
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
    // ---- the seat surface publishes the scoping intents ----
    await _poll('scoping intents published', () async {
      final listed = await _verb(vmUri, 'fmt_list_client_tools_and_resources', {
        'connection': {'targetId': vmUri, 'mode': 'uri'},
      });
      final blob = jsonEncode(listed);
      return blob.contains('realm_chat_spawn_work') &&
              blob.contains('realm_project_access')
          ? blob.length
          : null;
    }, attempts: 40, interval: const Duration(seconds: 2));
    row('PASS', 'seat-surface', 'LA publishes realm_chat_spawn_work + realm_project_access');

    // ---- wait for the shell + a live chat surface ----
    await _poll('shell ready', () async {
      final snap = await _verb(vmUri, 'semantic_snapshot');
      final nodes = (snap['nodes'] as List? ?? const []).cast<Map<String, Object?>>();
      final blob = nodes.map((n) => '${n['label'] ?? ''}${n['identifier'] ?? ''}').join('\n');
      return blob.contains('edge.world') ? true : null;
    }, attempts: 60, interval: const Duration(seconds: 1));
    row('PASS', 'shell', 'edge.world present — the chat surface can bind');

    // ---- the GENERAL room: realm-sealed, conversational, no project ----
    final roomName = 'workorder-${DateTime.now().millisecondsSinceEpoch}';
    final opened = await _laTool(vmUri, 'realm_chat_create_channel', {
      'name': roomName,
      'members': actor,
    });
    final parentThread = '${_deepFind(opened, 'threadId') ?? ''}';
    if (parentThread.isEmpty) {
      failures++;
      row('FAIL', 'parent-room', 'create_channel → ${jsonEncode(opened)}');
      throw StateError('create_channel refused');
    }
    // Journal truth: the parent room carries NO project seal.
    final parentRow = await store.read('threads', parentThread);
    if (parentRow == null || parentRow['projectId'] != null) {
      failures++;
      row('FAIL', 'parent-room', 'parent is not realm-sealed: $parentRow');
    } else {
      row('PASS', 'parent-room', '"$roomName" realm-sealed (projectId: null) → $parentThread');
    }

    // ---- grants manageable from LA: list, self-heal, verify ----
    final state = await _laTool(vmUri, 'realm_chat_state', {});
    final human = '${_deepFind(state, 'human') ?? ''}';
    if (human.isEmpty) {
      failures++;
      row('FAIL', 'human-id', 'realm_chat_state carried no human id');
      throw StateError('no human id');
    }
    final grants = await _laTool(vmUri, 'realm_project_access', {'action': 'list'});
    final grantList = ((_deepFind(grants, 'grants') as List? ?? const [])
        .cast<Object?>()).map((e) => '$e').toList();
    if (!grantList.contains(_targetRepo)) {
      final heal = await _laTool(vmUri, 'realm_project_access', {
        'action': 'grant',
        'actor': human,
        'project': _targetRepo,
      });
      final granted = _deepFind(heal, 'ok') == true;
      row(granted ? 'PASS' : 'FAIL', 'grant-self-heal',
          'human grant for $_targetRepo via LA → ${jsonEncode(heal)}');
      if (!granted) {
        failures++;
        throw StateError('grant self-heal failed');
      }
    } else {
      row('PASS', 'grants', 'human ($human) already holds the LA grant');
    }
    // The ACTOR's grant is the sandbox door on the dispatch side.
    final actorGrants = await _laTool(vmUri, 'realm_project_access', {
      'action': 'list',
      'actor': actor,
    });
    final actorGrantList = ((_deepFind(actorGrants, 'grants') as List? ?? const [])
        .cast<Object?>()).map((e) => '$e').toList();
    if (!actorGrantList.contains(_targetRepo)) {
      final heal = await _laTool(vmUri, 'realm_project_access', {
        'action': 'grant',
        'actor': actor,
        'project': _targetRepo,
      });
      row(_deepFind(heal, 'ok') == true ? 'PASS' : 'FAIL', 'actor-grant',
          '$actor grant for $_targetRepo → ${jsonEncode(heal)}');
      if (_deepFind(heal, 'ok') != true) {
        failures++;
        throw StateError('actor grant failed');
      }
    } else {
      row('PASS', 'actor-grant', '$actor holds the LA grant');
    }

    // ---- the work order: ONE human sentence in the GENERAL room,
    // scoped — LA auto-spawns the sealed work thread and forwards.
    // Probe law (2026-11-09): never "reply with exactly X" — the
    // harness echo guard's containment clause would eat the answer;
    // the reply must be an original sentence + the diff stat (which by
    // construction cannot be contained in the order).
    final order = '$actor — work order in the last_answer workspace: '
        'append a short "Postscript (2026-11-09)" section to the END of '
        '$_targetFile recording in 2-3 lines that the room-scoping model '
        'landed: general rooms stay realm-sealed and conversational; '
        'work orders auto-spawn project-sealed threads (ADR 0129) so '
        'delegated work is sandboxed into the repository the order '
        'named. Then run: git diff --stat $_targetFile — and reply here '
        'with that diff stat plus ONE original sentence of your own '
        'about the change. Do not quote this beat.';
    final spawned = await _laTool(vmUri, 'realm_chat_spawn_work', {
      'project': _targetRepo,
      'text': order,
      'members': actor,
      'parentThreadId': parentThread,
      'topic': 'last_answer · $roomName',
    });
    final workThread = '${_deepFind(spawned, 'workThreadId') ?? ''}';
    if (_deepFind(spawned, 'ok') != true || workThread.isEmpty) {
      failures++;
      row('FAIL', 'spawn', 'realm_chat_spawn_work → ${jsonEncode(spawned)}');
      throw StateError('spawn refused');
    }
    row('PASS', 'spawn', 'work thread $workThread (reused=${_deepFind(spawned, 'reused')})');
    // Journal truth: the work thread IS sealed to the target repo —
    // this projectId is the daemon actor's workRoot at dispatch.
    final workRow = await store.read('threads', workThread);
    if (workRow == null || workRow['projectId'] != _targetRepo) {
      failures++;
      row('FAIL', 'seal', 'work thread not sealed to $_targetRepo: $workRow');
    } else {
      row('PASS', 'seal', 'journal projectId == $_targetRepo (the seal IS the sandbox)');
    }
    final orderBeatNo = _deepFind(spawned, 'orderBeat');
    row(orderBeatNo != null ? 'PASS' : 'WARN', 'forward',
        'order landed as beat $orderBeatNo in the work thread');

    // ---- the reuse law: same (room × project) never mints a second ----
    final again = await _laTool(vmUri, 'realm_chat_spawn_work', {
      'project': _targetRepo,
      'parentThreadId': parentThread,
    });
    if (_deepFind(again, 'reused') == true &&
        '${_deepFind(again, 'workThreadId')}' == workThread) {
      row('PASS', 'reuse', 'second spawn reused $workThread (one thread per scope)');
    } else {
      failures++;
      row('FAIL', 'reuse', 'second spawn → ${jsonEncode(again)}');
    }

    // ---- the native loop runs: the actor edits IN THE NAMED REPO and
    // replies in the work thread. 900s: the daemon's drain cycle can
    // lag minutes before the actor's brain even starts. The author
    // filter IS the check — every pre-existing beat of a fresh work
    // thread is human-authored (the forwarded order).
    Map<String, Object?>? reply;
    try {
      reply = await _poll('$actor reply beat', () async {
        final beats = await projection.beatsOfThread(workThread);
        for (final b in beats) {
          if ('${b['author']}' == actor) return b;
        }
        return null;
      }, attempts: 300, interval: const Duration(seconds: 3));
    } on TimeoutException {
      failures++;
      row('FAIL', 'actor-reply', 'no $actor beat within 900s — read the loop '
          'log (dispatch/throttle/echo-drop/quarantine); actor=$actor');
    }
    if (reply != null) {
      final text = '${reply['text']}';
      final shown = text.length <= 110 ? text : '${text.substring(0, 110)}…';
      row('PASS', 'actor-reply', 'beat ${reply['beat']} from $actor: $shown');
    }

    // ---- the work EVIDENCE: the edit landed in the target repo ----
    final diffRun = await Process.run('git', ['diff', '--', _targetFile],
        workingDirectory: _targetRepo);
    final diff = '${diffRun.stdout}';
    if (diff.trim().isEmpty) {
      failures++;
      row('FAIL', 'work-evidence', 'no diff on $_targetFile — the actor '
          'replied without editing (check its workRoot/telemetry)');
    } else {
      final diffFile = File('${_evidenceDir.path}/actor_edit.diff')
        ..writeAsStringSync(diff);
      final added = diff.split('\n').where((l) => l.startsWith('+') && !l.startsWith('+++')).length;
      row('PASS', 'work-evidence',
          '$added added lines on $_targetFile → ${diffFile.path}');
      if (keepEdit) {
        row('INFO', 'work-evidence', '--keep-edit: the actor edit stays for human adoption');
      } else {
        await Process.run('git', ['checkout', '--', _targetFile],
            workingDirectory: _targetRepo);
        row('INFO', 'work-evidence', 'edit RESTORED (the smoke is the proof, not the adopter)');
      }
    }

    // ---- the work texture (telemetry) ----
    final telem = await store.scan('tool_loop_telemetry');
    Map<String, Object?>? newest;
    for (final t in telem.values) {
      if ('${t['actorId']}' != actor) continue;
      if (newest == null || '${t['at']}'.compareTo('${newest['at']}') > 0) {
        newest = t;
      }
    }
    if (newest != null) {
      row('INFO', 'work-texture',
          'rounds=${newest['rounds']} toolCalls=${newest['toolCalls']} '
          'tokens=${newest['tokens'] ?? newest['promptTokens'] ?? '?'}');
    }

    // ---- the parent room RENDERS the work (card or reply visible) ----
    try {
      final snap = await _poll('parent room shows the work', () async {
        final s = await _verb(vmUri, 'semantic_snapshot');
        final nodes = (s['nodes'] as List? ?? const []).cast<Map<String, Object?>>();
        final blob = nodes
            .map((n) => '${n['label'] ?? ''}\n${n['value'] ?? ''}\n${n['identifier'] ?? ''}')
            .join('\n');
        return blob.contains('worldchat.workthread.') ||
                blob.contains(workThread) ||
                blob.contains(actor)
            ? blob.length
            : null;
      }, attempts: 30, interval: const Duration(seconds: 2));
      row('PASS', 'room-render', 'the parent room surfaces the work ($snap semantic chars)');
    } on TimeoutException {
      row('WARN', 'room-render', 'no work card/thread visible in the live tree '
          '(UI layer may predate this build); the journal + diff own it');
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
    row('FAIL', 'work-order', '$error\n$stack');
  } finally {
    try {
      File('${_evidenceDir.path}/app_stdout.log')
          .writeAsStringSync(app.stdout.lines.join('\n'));
    } on Object {}
    await app.stop();
  }

  // ignore: avoid_print
  print(failures == 0
      ? 'VERDICT: WORK-ORDER-SMOKE PASS'
      : 'VERDICT: WORK-ORDER-SMOKE FAIL ($failures)');
  exit(failures == 0 ? 0 : 1);
}
