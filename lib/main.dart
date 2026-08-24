import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:lastanswer/bootstrap.dart';
import 'package:mcp_toolkit/mcp_toolkit.dart';

void main() {
  runZonedGuarded(
    () {
      WidgetsFlutterBinding.ensureInitialized();
      MCPToolkitBinding.instance
        ..initialize()
        ..initializeFlutterToolkit();
      unawaited(bootstrap());
    },
    MCPToolkitBinding.instance.handleZoneError,
  );
}
