// UI gate — the DESIGN.md v6 component-carrier law, enforced.
//
// Gates (run from the repo root: `fvm dart run tool/check_ui_gates.dart`):
//   1. packages/la_ui/lib/** must never import package:flutter/material.dart
//      (the kit is widgets-layer only).
//   2. lib/** must not import package:flutter/material.dart except:
//        - files listed in tool/ui_gate_allowlist.txt (engine-host plumbing),
//        - imports whose `show` clause exposes only data constants
//          (Icons, Colors) — glyphs and color data are not grammar.
//   3. lib/** must not import package:blur or package:flutter_animate
//      (glass blur is banned as decoration; ambient animation is banned
//      in chrome — DESIGN.md §Elevation and motion, v6).
//
// Exit code 0 = green; 1 = violations printed one per line (file:line: rule).
import 'dart:io';

const _bannedDataDeps = ['package:blur/', 'package:flutter_animate/'];

/// Identifiers allowed in a material `show` clause (data, not grammar).
const _dataOnlyShows = {'Icons', 'Colors', 'ThemeMode'};

void main() {
  final violations = <String>[];
  final allowlist = _loadAllowlist();

  // Gate 1: the kit itself.
  for (final file in _dartFiles(Directory('packages/la_ui/lib'))) {
    for (final line in _importsOf(file)) {
      if (line.uri == 'package:flutter/material.dart') {
        violations.add('${file.path}:${line.no}: la_ui must not import '
            'material (component-carrier law)');
      }
    }
  }

  // Gates 2+3: the app.
  for (final file in _dartFiles(Directory('lib'))) {
    final rel = _relative(file.path);
    final isAllowlisted = allowlist.contains(rel);
    for (final line in _importsOf(file)) {
      if (line.uri == 'package:flutter/material.dart' && !isAllowlisted) {
        if (!line.isDataOnlyShow) {
          violations.add('${file.path}:${line.no}: material import outside '
              'the allowlist (add `show Icons` for glyphs, or migrate to '
              'la_ui; allowlist: tool/ui_gate_allowlist.txt)');
        }
      }
      for (final banned in _bannedDataDeps) {
        if (line.uri.startsWith(banned)) {
          violations.add('${file.path}:${line.no}: banned dependency '
              '${line.uri} (DESIGN.md §Elevation/motion)');
        }
      }
    }
  }

  if (violations.isEmpty) {
    stdout.writeln('ui gates: OK (la_ui material-free; lib/ imports gated)');
    exit(0);
  }
  stderr.writeln('ui gates: ${violations.length} violation(s)');
  for (final v in violations) {
    stderr.writeln('  $v');
  }
  exit(1);
}

Set<String> _loadAllowlist() {
  final file = File('tool/ui_gate_allowlist.txt');
  if (!file.existsSync()) {
    return const {};
  }
  return file
      .readAsLinesSync()
      .map((l) => l.split('#').first.trim())
      .where((l) => l.isNotEmpty)
      .toSet();
}

String _relative(final String path) =>
    path.startsWith('./') ? path.substring(2) : path;

Iterable<File> _dartFiles(final Directory dir) sync* {
  if (!dir.existsSync()) {
    return;
  }
  for (final entity in dir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      yield entity;
    }
  }
}

final _importPattern = RegExp(
  r'''^\s*import\s+'([^']+)'(\s+show\s+([^;]+))?;''',
);

class _ImportLine {
  _ImportLine(this.no, this.uri, this.shows);

  final int no;
  final String uri;
  final Set<String> shows;

  bool get isDataOnlyShow =>
      shows.isNotEmpty && shows.every(_dataOnlyShows.contains);
}

Iterable<_ImportLine> _importsOf(final File file) sync* {
  final lines = file.readAsLinesSync();
  for (var i = 0; i < lines.length; i++) {
    final match = _importPattern.firstMatch(lines[i]);
    if (match == null) {
      continue;
    }
    final shows = (match.group(3) ?? '')
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toSet();
    yield _ImportLine(i + 1, match.group(1)!, shows);
  }
}
