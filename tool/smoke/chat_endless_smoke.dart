// The endless-chat live smoke (plan v5 verification): proves the
// plane convergence on the REAL realm — a seeded 500-beat room renders
// at its TAIL (the frozen-head bug's live negation), load-older walks
// the window, the open advances the human's durable receipt, the first
// production launch exports the kernel archive, and an addressed beat
// round-trips through the LIVE daemon drain back into the journal.
//
// Laws this script respects (each learned the hard way, 2026-11-07):
// - The rail/strip subtrees are INVISIBLE to the semantics walker on
//   live apps (the named Flutter framework live-semantics gap — the
//   gate's SKIP row). Navigation rides the ⌘K palette (typed, the
//   gate-proven lane); badge visuals are screenshot evidence, their
//   law is widget-gated in action_bar_test.
// - Seed text VARIES per beat: a 500-beat repetition chain trips the
//   ADR 0137 echo guard (correctly!) and throttles dispatch.
// - The round-trip runs in its OWN fresh room (no echo tail) and
//   targets the brainCast-bound actor with the NEWEST telemetry —
//   evidence it can actually answer (a cold key reads as
//   provider_key_limit_exhausted, not as a stall).
// - Receipts are checked journal-side (thread_reads row) — never
//   through the semantics-invisible rail.
// - Taps ride `snapshotId` (camelCase) and a refused tap is a FAIL row,
//   never a swallowed false: the 2026-11-08 boot FAIL was exactly a
//   snake_case key refused as invalid_command while the caller ignored
//   the refusal and polled a shell that could never appear.
// - The first-run flow was proven LIVE once (boot_probe, 2026-11-08:
//   skip tap → shell with edge.world in 3s). Onboarding persists, so
//   later runs take the honest SKIP branch instead of re-proving it.
//
// Run: fvm dart tool/smoke/chat_endless_smoke.dart [--skip-build]
//      [--actor <id>]
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_mcp_harness/flutter_mcp_harness.dart';
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';

final _projectDir = Directory.current.path;
final _tmp = Platform.environment['TMPDIR'] ?? '/tmp';
final _evidenceDir = Directory('$_tmp/chat_smoke_evidence')
  ..createSync(recursive: true);
final _stepsLog = File('${_evidenceDir.path}/steps.log');
final _stateFile = '${_evidenceDir.path}/fmtk_state.json';

void row(final String status, final String step, final String detail) {
  final line = '${status.padRight(6)}${step.padRight(28)}$detail';
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

/// One verb over the fmtk CLI: a SHORT-LIVED connection per call (the
/// gate's proven lane — the VM service refuses concurrent clients).
Future<Map<String, Object?>> _verb(
  final String vmUri,
  final String verb, [
  final Map<String, Object?> args = const <String, Object?>{},
]) async {
  final result = await Process.run('fmtk', [
    '--state-file',
    _stateFile,
    '--vm-service-uri',
    vmUri,
    '--flutter-device',
    'macos',
    '--flutter-project-dir',
    _projectDir,
    'exec',
    '--name',
    verb,
    '--args',
    jsonEncode(args),
  ]);
  if (result.exitCode != 0) return const <String, Object?>{};
  try {
    final envelope = jsonDecode('${result.stdout}') as Map<String, Object?>;
    if (envelope['ok'] != true) return const <String, Object?>{};
    final data = envelope['data'];
    return data is Map ? data.cast<String, Object?>() : const {};
  } on Object {
    return const <String, Object?>{};
  }
}

Future<T> _poll<T>(
  final String label,
  final Future<T?> Function() probe, {
  final int attempts = 40,
  final Duration interval = const Duration(milliseconds: 500),
}) async {
  for (var i = 0; i < attempts; i++) {
    final value = await probe();
    if (value != null) return value;
    await Future<void>.delayed(interval);
  }
  throw TimeoutException('poll never passed: $label');
}

Future<(int, String, List<Map<String, Object?>>)> _snapshot(
  final String vmUri,
) async {
  final out = await _verb(vmUri, 'semantic_snapshot');
  final nodes = (out['nodes'] as List? ?? const [])
      .cast<Map<String, Object?>>();
  final blob = nodes
      .map(
        (final node) =>
            '${node['label'] ?? ''}\n${node['hint'] ?? ''}\n'
            '${node['identifier'] ?? ''}\n${node['value'] ?? ''}',
      )
      .join('\n');
  return (out['snapshot_id'] as int? ?? 0, blob, nodes);
}

String? _refFor(
  final List<Map<String, Object?>> nodes,
  final String labelPrefix,
) {
  for (final node in nodes) {
    if (node['identifier'] == labelPrefix) return node['ref'] as String?;
    final label = '${node['label'] ?? ''}';
    if (label.startsWith(labelPrefix)) return node['ref'] as String?;
  }
  return null;
}

/// Tap one semantics ref. The arg key is `snapshotId` (camelCase — the
/// fmtk schema is additionalProperties:false, so a snake_case key is an
/// invalid_command the verb refuses; paid for once on 2026-11-08 when a
/// swallowed refusal read as "the skip tap never lands"). Callers MUST
/// honour the false: a refused tap leaves the app where it was.
Future<bool> _tapRef(
  final String vmUri,
  final int snapshotId,
  final String ref,
) async {
  final out = await _verb(vmUri, 'tap_widget', {
    'ref': ref,
    'snapshotId': snapshotId,
  });
  return out['success'] == true;
}

/// The gate-proven palette lane: ⌘K, type the query, Enter. The rail
/// is semantics-invisible live (framework gap), the palette is not.
Future<void> _paletteTo(final String vmUri, final String query) async {
  await _poll('palette opens for $query', () async {
    await _verb(vmUri, 'press_key', {'key': 'k', 'meta': true});
    final snap = await _snapshot(vmUri);
    return snap.$2.contains('palette.query') ? snap : null;
  }, attempts: 60);
  final (sid, _, nodes) = await _poll('palette field ref', () async {
    final snap = await _snapshot(vmUri);
    return _refFor(snap.$3, 'palette.query') != null ? snap : null;
  }, attempts: 20);
  final fieldRef = _refFor(nodes, 'palette.query')!;
  await _verb(vmUri, 'enter_text', {
    'ref': fieldRef,
    'text': query,
    'snapshotId': sid,
  });
  await _verb(vmUri, 'press_key', {'key': 'Enter'});
}

const _smokeThread = 'thread-smoke-endless';
const _smokeChannel = 'channel-smoke-endless';

/// The roundtrip room is FRESH per run (the header law: "its OWN fresh
/// room, no echo tail"). A constant id would inherit the prior run's
/// beats — and since the human identity is itself a registered realm
/// actor, N≥8 accumulated human beats arm ADR 0137's throttle
/// (`maxConsecutiveDaemonActorBeats`) and the addressed beat never
/// dispatches (observed live: "beat 12 throttled — next dispatch at
/// beat 20"). A per-run suffix keeps trailingInternal at 0, so the
/// addressed beat drains immediately. The throttle-on-human-beats
/// behavior is a harness fact LA surfaces, not edits.
final _roundtripThread =
    'thread-smoke-roundtrip-${DateTime.now().millisecondsSinceEpoch}';
const _beatCount = 500;

/// Varied seed sentences — a repetition chain would trip the ADR 0137
/// echo guard (correctly), throttling any later dispatch in the room.
const _seedTails = <String>[
  'the fold keeps the tail warm',
  'cursor deltas beat full scans',
  'one plane, many projections',
  'receipts are durable, badges are views',
  'the window is a viewport, never the room',
  'verbatim writes, budgeted reads',
  'creatures carry world truth',
  'a sentence starts the work',
];

Future<void> main(final List<String> args) async {
  final skipBuild = args.contains('--skip-build');
  final actorIdx = args.indexOf('--actor');
  final actorFlag = actorIdx >= 0 && actorIdx + 1 < args.length
      ? args[actorIdx + 1]
      : null;
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

  // ---- seed: the smoke room (realm-sealed) with 500 VARIED beats ----
  final identity = await store.read('world_identity', 'human');
  final humanId = '${identity?['actorId'] ?? 'human-smoke'}';
  final existing = await store.read('threads', _smokeThread);
  if (existing == null) {
    await store.transact((tx) {
      tx
        ..put('threads', _smokeThread, <String, Object?>{
          'threadId': _smokeThread,
          'projectId': null,
          'projectRoot': null,
          'topic': 'smoke-endless',
          'createdBy': humanId,
          'createdAt': DateTime.now().toUtc().toIso8601String(),
          'closed': false,
          'participants': [humanId],
          'lastBeat': _beatCount,
        })
        ..put('channels', _smokeChannel, <String, Object?>{
          'channelId': _smokeChannel,
          'name': 'smoke-endless',
          'threadId': _smokeThread,
          'memberIds': [humanId],
          'createdAt': DateTime.now().toUtc().toIso8601String(),
        });
      return null;
    });
    for (var batch = 0; batch < _beatCount ~/ 50; batch++) {
      await store.transact((tx) {
        for (var j = 1; j <= 50; j++) {
          final i = batch * 50 + j;
          tx.put('thread_beats', '$_smokeThread#$i', <String, Object?>{
            'threadId': _smokeThread,
            'beat': i,
            'author': humanId,
            'conversationId': 'lastanswer',
            'text': 'smoke beat $i — ${_seedTails[i % _seedTails.length]}',
            'at': DateTime.now().toUtc().toIso8601String(),
            'addressedTo': const <String>[],
          });
        }
        return null;
      });
    }
    row('PASS', 'seed', '$_beatCount varied beats + channel as $humanId');
  } else {
    row(
      'SKIP',
      'seed',
      'smoke room already exists (lastBeat ${existing['lastBeat']})',
    );
  }

  // ---- the round-trip target: evidence over scan order ----
  // The brainCast-bound actor with the NEWEST telemetry row — proof it
  // answered recently (a cold key shows as exhausted telemetry, not as
  // a silent stall). --actor overrides.
  String? daemonActor = actorFlag;
  if (daemonActor == null) {
    final actors = await store.scan('realm_actors');
    final bound = <String>{
      for (final entry in actors.entries)
        if ('${entry.value['brainCast'] ?? ''}'.isNotEmpty &&
            entry.key != humanId)
          entry.key,
    };
    final telemetry = await store.scan('tool_loop_telemetry');
    String? newestAt;
    for (final telemetryRow in telemetry.values) {
      final id = '${telemetryRow['actorId'] ?? ''}';
      if (!bound.contains(id)) continue;
      final at = '${telemetryRow['at'] ?? ''}';
      if (newestAt == null || at.compareTo(newestAt) > 0) {
        newestAt = at;
        daemonActor = id;
      }
    }
    daemonActor ??= bound.isEmpty ? null : bound.first;
  }

  // ---- launch ----
  final binary = File(
    'build/macos/Build/Products/Debug/last_answer.app/Contents/'
    'MacOS/last_answer',
  );
  LaunchedApp? app;
  String vmUri;
  try {
    final launched = await BinaryAppTarget(
      projectDir: _projectDir,
      binaryPath: binary.path,
      buildCommand: const [
        'fvm',
        'flutter',
        'build',
        'macos',
        '--debug',
        '--no-pub',
      ],
      name: 'chat-smoke',
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
    // ---- boot: the first-run flow OR the shell (POLLED — a single
    // snapshot races the LoadingScreen and misreads a pending
    // first-run as "already complete") ----
    final boot = await _poll(
      'boot: first-run or shell',
      () async {
        final snap = await _snapshot(vmUri);
        if (_refFor(snap.$3, 'firstrun.skip') != null) {
          return ('firstrun', snap);
        }
        if (snap.$2.contains('edge.world')) return ('shell', snap);
        return null;
      },
      attempts: 60,
      interval: const Duration(seconds: 1),
    );
    if (boot.$1 == 'firstrun') {
      final skipRef = _refFor(boot.$2.$3, 'firstrun.skip')!;
      final tapped = await _tapRef(vmUri, boot.$2.$1, skipRef);
      if (!tapped) {
        row(
          'FAIL',
          'first-run-skip',
          'fmtk refused the skip tap — app stays '
              'on first-run; every later step would misread it',
        );
        throw StateError('skip tap refused');
      }
      await _poll(
        'shell after first-run skip',
        () async {
          final snap = await _snapshot(vmUri);
          return snap.$2.contains('edge.world') ? true : null;
        },
        attempts: 90,
        interval: const Duration(seconds: 1),
      );
      row('PASS', 'first-run-skip', 'flow rendered, skip landed in shell');
    } else {
      row('SKIP', 'first-run-skip', 'onboarding already complete here');
    }

    // ---- the export: kernel archive threads landed in the journal ----
    final archiveHome = Directory(
      '$home/.xsoulspace/worlds/local/project/lastanswer/threads',
    );
    if (archiveHome.existsSync()) {
      final ids = [
        for (final file in archiveHome.listSync())
          if (file is File && file.path.endsWith('.json'))
            file.path.split('/').last.replaceAll('.json', ''),
      ];
      await _poll(
        'kernel export',
        () async {
          // The export contract: every archive thread gains (or keeps)
          // a journal `threads` row — merged, never re-sealed when the
          // row predates the export with its own project seal.
          for (final id in ids) {
            final exported = await store.read('threads', id);
            if (exported == null) return null;
          }
          return true;
        },
        attempts: 90,
        interval: const Duration(seconds: 1),
      );
      var sealed = 0;
      for (final id in ids) {
        final exported = await store.read('threads', id);
        if (exported != null && exported['projectId'] == null) sealed++;
      }
      row(
        'PASS',
        'kernel-export',
        '${ids.length} archive threads in the journal ($sealed realm-sealed, '
            '${ids.length - sealed} merged under their original seal)',
      );
    } else {
      row('SKIP', 'kernel-export', 'no archive home');
    }

    // ---- rail badge: semantics-INVISIBLE live (framework gap) ----
    // The badge law is widget-gated (action_bar_test); live evidence is
    // the screenshot below. Named WARN, never a silent skip.
    row(
      'WARN',
      'rail-badge',
      'rail subtree semantics-invisible live (named framework gap); '
          'widget gate + screenshot own it',
    );

    // ---- open the room: layout restore may ALREADY show it (the shell
    // persists open tabs), so the palette is the fallback, not the door.
    // Then: TAIL renders ----
    try {
      var already = false;
      try {
        await _poll('room open from restored layout', () async {
          final s = await _snapshot(vmUri);
          return s.$2.contains('smoke beat $_beatCount') ? s : null;
        }, attempts: 6);
        already = true;
      } on TimeoutException {
        already = false;
      }
      if (already) {
        row('INFO', 'open-room', 'restored layout already shows the room');
      } else {
        await _paletteTo(vmUri, 'smoke-endless');
      }
      await _poll('tail beat 500', () async {
        final s = await _snapshot(vmUri);
        return s.$2.contains('smoke beat $_beatCount') ? true : null;
      });
      final snap = await _snapshot(vmUri);
      if (snap.$2.contains('smoke beat 100 —') ||
          snap.$2.contains('smoke beat 100\n')) {
        failures++;
        row('FAIL', 'tail-law', 'beat 100 visible — head-freeze alive?!');
      } else {
        row('PASS', 'tail-law', 'beat $_beatCount renders; beat 100 absent');
      }

      // ---- the receipt: journal-side truth (thread_reads) ----
      final receiptBeat = await _poll('receipt advanced', () async {
        final receipt = await store.read(
          'thread_reads',
          '$humanId@$_smokeThread',
        );
        final beat = receipt?['lastReadBeat'];
        return beat is int && beat >= _beatCount ? beat : null;
      });
      row('PASS', 'receipt', 'thread_reads at $receiptBeat (ADR 0124)');

      // ---- load-older walks the window ----
      // The row itself lives at the TOP of the reversed list — 500 beats
      // up, off-viewport, and the snapshot only sees the viewport — so
      // the product path is the scroll TRIGGER: near the top extent the
      // list fetches the previous page by itself. Scroll until beat 245
      // (two pages deep) renders. The jump pill is the movement oracle
      // that decides the gesture direction on the first two attempts.
      var walked = false;
      var direction = 'up';
      for (var i = 0; i < 20 && !walked; i++) {
        final before = await _snapshot(vmUri);
        if (before.$2.contains('smoke beat 245')) {
          walked = true;
          break;
        }
        await _verb(vmUri, 'scroll', {
          'direction': direction,
          'distance': 2000,
        });
        await Future<void>.delayed(const Duration(milliseconds: 600));
        final after = await _snapshot(vmUri);
        if (after.$2.contains('smoke beat 245')) {
          walked = true;
          break;
        }
        if (i == 1 && !after.$2.contains('worldchat.jumpLatest')) {
          direction = direction == 'up' ? 'down' : 'up';
        }
      }
      if (walked) {
        row(
          'PASS',
          'load-older',
          'scroll trigger walked the window to beat 245',
        );
      } else {
        // Named gap, not a blind fail: fmtk's scroll verb carries no
        // target ref and never moved the reversed transcript live
        // (proven 2026-11-08: twenty attempts, pixel-identical end
        // state). The trigger law is widget-gated instead.
        row(
          'WARN',
          'load-older',
          'fmtk scroll cannot reach the reversed transcript live '
              '(named gap); trigger + jump pill widget-gated in '
              'world_chat_tail_trigger_test',
        );
      }
    } on TimeoutException catch (error) {
      failures++;
      row('FAIL', 'open-room', '$error');
      // The next failure explains itself: what the live tree actually
      // showed at timeout (palette overlay? wrong surface? loading?).
      try {
        final diag = await _snapshot(vmUri);
        final labels = diag.$3
            .map((final n) => '${n['label'] ?? ''}')
            .where((final l) => l.isNotEmpty)
            .take(25)
            .join(' | ');
        row('DIAG', 'open-room', 'live labels at timeout: $labels');
      } on Object {
        // A dead diagnostic must never mask the failure it serves.
      }
    }

    // ---- the daemon round-trip (1e tail): FRESH room, addressed
    // beat, evidence-picked actor; the reply lands on the shared
    // journal plane ----
    if (daemonActor == null) {
      row('SKIP', 'daemon-roundtrip', 'no brainCast-bound actor in realm');
    } else {
      final existingRt = await store.read('threads', _roundtripThread);
      var last = (existingRt?['lastBeat'] as int?) ?? 0;
      if (existingRt == null) {
        final target = daemonActor;
        await store.transact((tx) {
          tx.put('threads', _roundtripThread, <String, Object?>{
            'threadId': _roundtripThread,
            'projectId': null,
            'projectRoot': null,
            'topic': 'smoke-roundtrip',
            'createdBy': humanId,
            'createdAt': DateTime.now().toUtc().toIso8601String(),
            'closed': false,
            'participants': [humanId, target],
            'lastBeat': 0,
          });
          return null;
        });
      }
      Future<void> say(
        final int beat,
        final String text,
        final List<String> addressed,
      ) async {
        await store.transact((tx) {
          final threadRow = tx.get('threads', _roundtripThread);
          tx
            ..put('threads', _roundtripThread, <String, Object?>{
              ...?threadRow,
              'lastBeat': beat,
              'participants': <String>{
                ...(threadRow?['participants'] as List? ?? const <Object?>[])
                    .cast<String>(),
                humanId,
                ...addressed,
              }.toList()..sort(),
            })
            ..put('thread_beats', '$_roundtripThread#$beat', <String, Object?>{
              'threadId': _roundtripThread,
              'beat': beat,
              'author': humanId,
              'conversationId': 'lastanswer',
              'text': text,
              'at': DateTime.now().toUtc().toIso8601String(),
              'addressedTo': addressed,
            });
          return null;
        });
      }

      last++;
      await say(
        last,
        'Roundtrip room, take ${DateTime.now().millisecondsSinceEpoch}: one '
        'human, one daemon-bound actor, a single addressed sentence — the '
        'journal is the beat plane, so this write is all the ceremony.',
        const [],
      );
      last++;
      await say(
        last,
        '$daemonActor — reply with exactly: SMOKE-OK '
        '(take ${DateTime.now().millisecondsSinceEpoch})',
        [daemonActor],
      );
      row(
        'INFO',
        'daemon-roundtrip',
        'beat $last addressed to $daemonActor (evidence-picked); '
            'waiting for the drain',
      );
      try {
        final reply = await _poll(
          'daemon reply',
          () async {
            final beats = await projection.beatsOfThread(_roundtripThread);
            for (final beat in beats) {
              if (beat['author'] == daemonActor) return beat;
            }
            return null;
          },
          attempts: 180,
          interval: const Duration(seconds: 1),
        );
        final text = '${reply['text']}';
        final shown = text.length <= 60 ? text : '${text.substring(0, 60)}…';
        row(
          'PASS',
          'daemon-roundtrip',
          'reply beat ${reply['beat']} from $daemonActor: $shown',
        );
      } on TimeoutException {
        failures++;
        // The honest diagnosis pointers, named (the loop log is the
        // authority: <world>/logs/daemon_actor_loops.jsonl — dispatch
        // line? throttle line? telemetry without a beat = the silent
        // no-post class, evidence broadcast 2026-11-07).
        row(
          'FAIL',
          'daemon-roundtrip',
          'no reply within 180s — read the loop log (dispatch/throttle/ '
              'telemetry-without-beat); actor=$daemonActor',
        );
      }
    }

    // ---- evidence ----
    final shot = await Process.run('fmtk', [
      '--state-file',
      _stateFile,
      '--vm-service-uri',
      vmUri,
      '--flutter-device',
      'macos',
      '--flutter-project-dir',
      _projectDir,
      '--output-dir',
      _evidenceDir.path,
      'exec',
      '--name',
      'get_screenshots',
      '--save-images',
      '--args',
      jsonEncode({'mode': 'flutter_layer'}),
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
    row(
      adopted > 0 ? 'PASS' : 'WARN',
      'evidence',
      '$adopted screenshots -> ${_evidenceDir.path} (exit ${shot.exitCode})',
    );
  } on Object catch (error, stack) {
    failures++;
    row('FAIL', 'smoke', '$error\n$stack');
  } finally {
    // The app's own voice: LogTap buffers the child's stdout (4000
    // lines). When a lane flakes, the answer is usually in here.
    File(
      '${_evidenceDir.path}/app_stdout.log',
    ).writeAsStringSync(app.stdout.lines.join('\n'));
    await app.stop();
  }

  // ignore: avoid_print
  print(
    failures == 0
        ? 'VERDICT: CHAT-SMOKE PASS'
        : 'VERDICT: CHAT-SMOKE FAIL ($failures)',
  );
  exit(failures == 0 ? 0 : 1);
}
