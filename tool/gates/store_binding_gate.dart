// Store-binding gate — the ADR 0037 kernel-isolation law, enforced.
//
// The purchase backend packages may be imported ONLY by the binding
// files under lib/store/bindings/. Each per-store entrypoint imports
// exactly ONE binding, so only that backend compiles into the build's
// AOT kernel. A backend import anywhere else ships every backend in
// every kernel — the whole point of the per-store entrypoints dies.
//
// Run from the repo root: `fvm dart tool/gates/store_binding_gate.dart`
// Exit code 0 = green; 1 = violations printed one per line (file:line).
import 'dart:io';

/// Backend package prefixes that must stay inside lib/store/bindings/.
/// When a new store backend joins (e.g. HMS IAP), add its import prefix
/// here — the gate is the mechanical half of the law.
const _backendPackagePrefixes = [
  'package:xsoulspace_monetization_rustore/',
  'package:xsoulspace_monetization_google_apple/',
];

const _bindingsDir = 'lib/store/bindings';

void main() {
  final violations = <String>[];
  for (final file in _dartFiles(Directory('lib'))) {
    final rel = file.path.replaceAll(r'\', '/');
    if (rel.startsWith('$_bindingsDir/')) continue;
    final lines = File(file.path).readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (!line.startsWith('import ')) continue;
      for (final backend in _backendPackagePrefixes) {
        if (line.contains(backend)) {
          violations.add(
            '${file.path}:${i + 1}: backend import ($backend) outside '
            '$_bindingsDir (ADR 0037 kernel isolation — import the '
            'binding, not the backend)',
          );
        }
      }
    }
  }

  if (violations.isEmpty) {
    stdout.writeln(
      'store-binding gate: OK (backends imported only under $_bindingsDir)',
    );
    exit(0);
  }
  violations.forEach(stdout.writeln);
  exit(1);
}

/// Recursive .dart walk, stable order.
List<File> _dartFiles(Directory dir) {
  if (!dir.existsSync()) return const [];
  final entities = dir.listSync(recursive: true)
    ..sort((a, b) => a.path.compareTo(b.path));
  return [
    for (final e in entities)
      if (e is File && e.path.endsWith('.dart') && !e.path.endsWith('.g.dart'))
        e,
  ];
}
