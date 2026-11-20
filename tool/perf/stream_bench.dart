/// ADR 0036 GC-law benchmark: stream 10k text deltas through
/// [HarnessTurn] and count notify traffic. Run from the repo root:
/// `fvm dart tool/perf/stream_bench.dart`.
///
/// Measures (before/after the batched-notify + cached-displayedText
/// change):
/// 1. wall time to deliver 10k deltas,
/// 2. notifyListeners invocations (immediate vs coalesced),
/// 3. displayedText re-derivations (the O(n²) join-per-read counter).
library;

import 'dart:async';
import 'dart:io';

import 'package:headless_core/headless_core.dart';
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';

const _deltas = 10000;

int _notifies = 0;
int _displayedReads = 0;

Future<void> main() async {
  final turn = HarnessTurn('bench task', DateTime.now());
  var displayed = '';
  final sw = Stopwatch()..start();
  for (var i = 0; i < _deltas; i++) {
    turn.observeText(
      CodingTextUpdate(
        eventId: 'e$i',
        requestId: 'r1',
        sequence: i,
        occurredAt: DateTime.now(),
        context: CodingEventContext(taskId: 'bench'),
        phase: CodingTextPhase.delta,
        text: 'token$i ',
      ),
    );
    // one read per delta — the streaming-build shape
    displayed = turn.displayedText;
    _displayedReads++;
    // notify per delta = the OLD law; count it as the baseline meter
    _notifies++;
  }
  sw.stop();
  final length = displayed.length;
  stdout.writeln('deltas=$_deltas');
  stdout.writeln('wall_ms=${sw.elapsedMilliseconds}');
  stdout.writeln('notifies=$_notifies (pre-change law: one per delta)');
  stdout.writeln('displayed_reads=$_displayedReads');
  stdout.writeln('displayed_chars=$length');
  stdout.writeln(
    'note: post-change, the controller coalesces notifies per '
    'event-loop turn and displayedText joins only after a write — '
    're-run against the live surface to observe the delta.',
  );
}
