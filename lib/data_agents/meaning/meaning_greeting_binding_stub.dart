import 'package:xsoulspace_agentic_harness/xsoulspace_agentic_harness.dart';
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';

/// Non-native targets retain no executable observer or verifier capability.
final class MeaningGreetingNativeComposition {
  const MeaningGreetingNativeComposition({
    required this.processRunner,
    required this.observe,
  });

  final Object processRunner;
  final Object observe;
}

List<ToolDef> Function(HostToolExtensionContext)? meaningGreetingTools(
  String workspace, {
  MeaningGreetingNativeComposition? nativeComposition,
}) =>
    (_) => const [];
