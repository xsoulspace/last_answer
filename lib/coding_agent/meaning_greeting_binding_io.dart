import 'dart:convert';
import 'dart:io';

import 'package:lastanswer/coding_agent/product_dart_runtime.dart';
import 'package:universal_storage_live_apply/universal_storage_live_apply.dart';
import 'package:xsoulspace_agentic_harness/xsoulspace_agentic_harness.dart';
import 'package:xsoulspace_agentic_host/meaning_span_preview.dart';
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';
import 'package:xsoulspace_meaning_core/xsoulspace_meaning_core.dart';

/// Explicit native composition for component tests and embedding roots.
/// Both paths are required so observer and verifier use the same declared
/// execution environment. Omitting it retains the product's bundled runtime.
final class MeaningGreetingNativeComposition {
  const MeaningGreetingNativeComposition({
    required this.processRunner,
    required this.observe,
  });

  final SpanProcessRunner processRunner;
  final Future<Object?> Function(Directory workspace) observe;
}

List<ToolDef> Function(HostToolExtensionContext) meaningGreetingTools(
  String workspace, {
  MeaningGreetingNativeComposition? nativeComposition,
}) {
  if (!(Platform.isMacOS || Platform.isLinux || Platform.isWindows)) {
    return (_) => const [];
  }
  final instances = <World, Map<String, MeaningSpanToolExtension>>{};
  return (context) {
    final selected = Directory(workspace).resolveSymbolicLinksSync();
    if (context.workspace.resolveSymbolicLinksSync() != selected) {
      return const [];
    }
    final tasks = instances[context.world] ??= {};
    var extension = tasks[context.taskId];
    if (extension == null || !extension.context.isCurrent) {
      extension = tasks[context.taskId] = MeaningSpanToolExtension(
        context: context,
        resolveBinding: (world) {
          final index = world.getResource<MeaningIndex>();
          final matches = index.byId.entries.where((entry) {
            final node = meaningComponentOf<MeaningNode>(world, entry.value);
            final props = meaningComponentOf<MeaningProps>(world, entry.value);
            return node?.kind == 'symbol' &&
                node?.label == 'greeting' &&
                props?.props['file'] == 'lib/greeting.dart';
          }).toList();
          if (matches.length != 1) {
            throw const MeaningPreviewRefusal(
              'meaning_fixture_binding_missing',
            );
          }
          return MeaningSpanBinding(
            symbolId: matches.single.key,
            sourceFile: 'lib/greeting.dart',
            runtimeSubject: MeaningRef(
              namespace: 'meaning_greeting',
              id: 'runtime/greeting-output',
            ),
          );
        },
        store: LiveApplyJournalStore(storePath: '$selected.meaning-recovery'),
        observe:
            nativeComposition?.observe ??
            (directory) async {
              final result = await ProductDartRuntime.run('dart', [
                'run',
                'tool/observe.dart',
              ], directory.path);
              if (result.exitCode != 0) {
                throw MeaningPreviewRefusal(
                  'meaning_observer_failed',
                  '${result.stderr}',
                );
              }
              return jsonDecode((result.stdout as String).trim());
            },
        processRunner:
            nativeComposition?.processRunner ?? ProductDartRuntime.run,
        readPaths: const [
          'lib/greeting.dart',
          'test/greeting_test.dart',
          'pubspec.yaml',
          'pubspec.lock',
          'tool/observe.dart',
          'oracle.json',
        ],
      );
    }
    return extension.tools;
  };
}
