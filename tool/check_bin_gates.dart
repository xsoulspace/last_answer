/// ADR 0034 bin purity gate: every file under `bin/` runs as plain Dart —
/// it must never import `package:lastanswer/...` or any Flutter library.
/// Run from the repo root: `just bin-gates`.
library;

import 'dart:io';

const _bannedPrefixes = [
  'package:lastanswer/',
  'package:flutter/',
];

void main() {
  final violations = <String>[];
  for (final file in _dartFiles(Directory('bin'))) {
    final lines = file.readAsLinesSync();
    for (final (no, line) in lines.indexed) {
      final trimmed = line.trim();
      final isBanned = _bannedPrefixes.any(trimmed.startsWith);
      if (isBanned) {
        violations.add(
          '${file.path}:$no: bin/ must stay pure Dart — found "$trimmed"',
        );
      }
    }
  }
  if (violations.isNotEmpty) {
    for (final v in violations) {
      stderr.writeln(v);
    }
    stderr.writeln(
      'bin gates: FAILED (${violations.length} violation(s); ADR 0034: '
      'bin/ imports headless_core and pure deps only)',
    );
    exit(1);
  }
  stdout.writeln('bin gates: OK (bin/ stays Flutter-free and app-free)');
}

Iterable<File> _dartFiles(final Directory dir) sync* {
  if (!dir.existsSync()) return;
  for (final entry in dir.listSync(recursive: true)) {
    if (entry is File && entry.path.endsWith('.dart')) yield entry;
  }
}
