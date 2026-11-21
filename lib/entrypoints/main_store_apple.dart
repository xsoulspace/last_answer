import 'dart:async';

import 'package:lastanswer/bootstrap.dart';
import 'package:lastanswer/store/bindings/apple.dart';
import 'package:mcp_toolkit/mcp_toolkit.dart';

/// The Apple App Store delivery entrypoint — iOS and macOS deliveries
/// (`oka run app-apple-store`).
///
/// Kernel-isolation law (ADR 0037): this file imports exactly ONE store
/// binding, so only the google/apple purchase backend compiles into this
/// build's AOT kernel — never the rustore one.
void main() {
  runZonedGuarded(() {
    unawaited(bootstrap(storeBinding: const AppleBinding()));
  }, MCPToolkitBinding.instance.handleZoneError);
}
