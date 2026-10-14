/// Development composition of the existing document tools and harness owner.
library;

import 'dart:convert';
import 'dart:io';
import 'package:headless_core/headless_core.dart';
import 'package:lastanswer/workbench/workbench_harness_tools.dart';
import 'package:xsoulspace_agentic_afm/xsoulspace_agentic_afm.dart';
import 'package:xsoulspace_agentic_harness/xsoulspace_agentic_harness.dart';
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';
import 'package:xsoulspace_inference_core/xsoulspace_inference_core.dart';

Future<void> main(List<String> args) async {
  if (args.length != 1) throw ArgumentError('OUTPUT_DIRECTORY (new trial)');
  final output = Directory(args.single).absolute;
  if (output.existsSync()) throw StateError('trial_directory_already_exists');
  output.createSync(recursive: true);
  final workspace = Directory('${output.path}/workspace')..createSync();
  final config = Directory('${workspace.path}/.xsoulspace')..createSync();
  File('${config.path}/config.json').writeAsStringSync(
    jsonEncode({
      'max_inference_starts_qwen': '4',
      'max_tool_rounds_qwen': '4',
      'max_goal_attempts_qwen': '1',
    }),
  );
  const original = 'Shipment is scheduled for 19 October 2026.';
  const expected = 'Shipment is scheduled for 20 October 2026.';
  final repo = InMemoryDocumentRepository();
  await repo.save(
    DocumentNode(
      id: const NodeId('shipping'),
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
      blocks: const [
        Block(
          id: NodeId('shared'),
          type: BlockType.paragraph,
          content: original,
        ),
        Block(
          id: NodeId('private'),
          type: BlockType.paragraph,
          content: 'Unshared fixture sentinel',
        ),
      ],
    ),
  );
  final owner = WorkbenchOwner(repo);
  final native = qwenTextBinding(
    thinking: false,
    generationOptions: const GenerationOptions(maxTokens: 384, thinking: false),
  );
  final traces = <Map<String, Object?>>[];
  final receipt = <String, Object?>{
    'schema': 'harness_first.document_development.v1',
    'model': native.binding.defaultModel,
    'thinking': false,
    'maxInferenceStarts': 4,
    'maxOutputTokens': 384,
    'uiRequired': false,
    'actorAdoptionToolInstalled': false,
    'canonicalAcceptanceClaimed': false,
    'actorToolNames': sharedWorkbenchToolNames
        .map((name) => name.value)
        .toList(),
  };
  HarnessAcpBackend? backend;
  HarnessEmbed? embed;
  var passed = false;
  var closed = false;
  try {
    await native.load();
    if (!native.isAvailable) throw StateError('local_qwen_unavailable');
    backend = HarnessAcpBackend(
      backend: 'qwen',
      actorToolNames: sharedWorkbenchToolNames,
      model: native.binding.defaultModel,
      bindings: {'qwen': native.binding},
      causalTrace: CausalTraceSink((trace) => traces.add(trace.toJson())),
      extraToolsWithContext: (context) => workbenchHarnessTools(
        owner,
        const SharedWorkbenchScope(
          project: 'shipping',
          block: 'shared',
          content: original,
        ),
        context,
      ),
    );
    embed = await HarnessEmbed.start(backend: backend);
    final session = await embed.newSession(workspace.path);
    final wall = Stopwatch()..start();
    final hostText = StringBuffer();
    final hostEvents = <Map<String, Object?>>[];
    int? firstProposalMs;
    final stop = await embed.delegateTask(
      session,
      '[read-only] Stage a document rewrite using workbench_propose_rewrite. '
      'The shared paragraph is "$original". '
      'Correct only the date to 20 October 2026. '
      'Use the exact text "$expected" and a brief reason. '
      'Never adopt a proposal or edit workspace files. '
      'Stop after the proposal is staged.',
      onText: hostText.write,
      onHostUpdate: (update) {
        hostEvents.add(update.toJson());
        if (update is CodingTextUpdate &&
            update.phase == CodingTextPhase.settled) {
          hostText.write(update.text);
        }
        if (update is CodingObservationUpdate &&
            update.kind == CodingObservationKind.toolResult &&
            update.label == 'workbench_propose_rewrite') {
          firstProposalMs ??= wall.elapsedMilliseconds;
        }
      },
    );
    receipt['hostEvents'] = hostEvents;
    receipt['firstProposalMs'] = firstProposalMs;
    receipt['hostText'] = hostText.toString();
    final data = await owner.state('shipping');
    final proposals = (data['proposals'] as Map).entries.toList();
    final unchanged =
        (await owner.read(
          'shipping',
        )).blockById(const NodeId('shared'))!.content ==
        original;
    receipt.addAll({
      'elapsedMs': wall.elapsedMilliseconds,
      'stop': stop.name,
      'proposalCount': proposals.length,
      'sourceUnchangedBeforeReview': unchanged,
      'decisionTrace': traces,
    });
    if (proposals.length != 1 || !unchanged) {
      throw StateError('document_proposal_missing_or_ambiguous');
    }
    final id = proposals.single.key as String;
    final proposal = proposals.single.value as Map;
    final after = DocumentNode.fromJson(
      Map<String, dynamic>.from(proposal['after'] as Map),
    );
    if (after.blockById(const NodeId('shared'))!.content != expected ||
        after.blockById(const NodeId('private'))!.content !=
            'Unshared fixture sentinel') {
      throw StateError('document_candidate_wrong');
    }
    // Operator-owned fixture review, separate from actor authority
    // and UI consent.
    await owner.adopt('shipping', id);
    receipt['operatorAdopted'] =
        (await owner.read(
          'shipping',
        )).blockById(const NodeId('shared'))!.content ==
        expected;
    await owner.undo('shipping', id);
    receipt['operatorUndoRestored'] =
        (await owner.read(
          'shipping',
        )).blockById(const NodeId('shared'))!.content ==
        original;
    passed =
        receipt['operatorAdopted'] == true &&
        receipt['operatorUndoRestored'] == true;
  } on Object catch (error) {
    receipt['failure'] = '$error';
  } finally {
    try {
      await backend?.closeForShutdown();
      await embed?.stop();
      closed = true;
    } on Object catch (error) {
      receipt['shutdownFailure'] = '$error';
    }
    if (closed) native.dispose();
    receipt['physicallyClosed'] = closed;
    receipt['passed'] = passed && closed;
    File('${output.path}/receipt.json').writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(receipt)}\n',
    );
    stdout.writeln(jsonEncode(receipt));
    if (!passed || !closed) exitCode = 1;
  }
}
