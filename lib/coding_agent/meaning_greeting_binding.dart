import 'package:lastanswer/coding_agent/meaning_greeting_binding_stub.dart'
    if (dart.library.io) 'package:lastanswer/coding_agent/meaning_greeting_binding_io.dart'
    as platform;
import 'package:xsoulspace_agentic_harness/xsoulspace_agentic_harness.dart';
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';

export 'package:lastanswer/coding_agent/meaning_greeting_binding_stub.dart'
    if (dart.library.io) 'package:lastanswer/coding_agent/meaning_greeting_binding_io.dart'
    show MeaningGreetingNativeComposition;

/// Explicit fixture binding; never guesses a UI/source mapping.
/// Component tests may supply their actual native execution composition;
/// ordinary product calls omit it and require the bundled product runtime.
List<ToolDef> Function(HostToolExtensionContext)? meaningGreetingTools(
  String workspace, {
  platform.MeaningGreetingNativeComposition? nativeComposition,
}) => workspace.isEmpty
    ? null
    : platform.meaningGreetingTools(
        workspace,
        nativeComposition: nativeComposition,
      );
