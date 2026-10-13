import 'package:lastanswer/coding_agent/meaning_experiment_preparation_stub.dart'
    if (dart.library.io) 'package:lastanswer/coding_agent/meaning_experiment_preparation_io.dart'
    as platform;
import 'package:lastanswer/coding_agent/meaning_greeting_binding.dart';
import 'package:xsoulspace_agentic_harness/xsoulspace_agentic_harness.dart';
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';

/// Device-local setup metadata grants fixture binding, never effect authority.
final class MeaningExperimentPreparation {
  static final instance = MeaningExperimentPreparation();
  final _receipts = <String, Map<String, Object?>>{};
  final _tools = <String, List<ToolDef> Function(HostToolExtensionContext)>{};

  Future<Map<String, Object?>> prepare() async {
    final receipt = await platform.prepareMeaningExperiment();
    if (receipt['ok'] == true) _remember(receipt);
    return receipt;
  }

  Future<void> restoreFor(String workspace) async {
    if (workspace.isEmpty || _receipts.containsKey(workspace)) return;
    final receipt = await platform.restoreMeaningExperiment(workspace);
    if (receipt != null) _remember(receipt);
  }

  void _remember(Map<String, Object?> receipt) {
    final workspace = receipt['workspace']! as String;
    _receipts[workspace] = receipt;
    final tools = meaningGreetingTools(workspace);
    if (tools != null) _tools[workspace] = tools;
  }

  Map<String, Object?>? receiptFor(String workspace) => _receipts[workspace];
  List<ToolDef> Function(HostToolExtensionContext)? toolsFor(
    String workspace,
  ) => _tools[workspace];
}
