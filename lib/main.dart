import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:lastanswer/bootstrap.dart';
import 'package:lastanswer/mcp/doc_mcp_tools.dart';
import 'package:lastanswer/mcp/storage_mcp_tools.dart';
import 'package:mcp_toolkit/mcp_toolkit.dart';

void main() {
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();
    final binding = MCPToolkitBinding.instance
      ..initialize()
      ..initializeFlutterToolkit();
    assert(() {
      // Agent-driven storage tools (debug/profile only).
      unawaited(
        binding.addEntries(
          entries: {...storageMcpEntries(), ...docMcpEntries()},
        ),
      );
      return true;
    }());
    unawaited(bootstrap());
  }, MCPToolkitBinding.instance.handleZoneError);
}
