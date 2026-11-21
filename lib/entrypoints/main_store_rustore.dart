import 'dart:async';

import 'package:lastanswer/bootstrap.dart';
import 'package:lastanswer/store/bindings/rustore.dart';
import 'package:mcp_toolkit/mcp_toolkit.dart';

/// The RuStore-delivery entrypoint (`oka run app-rustore`).
///
/// Kernel-isolation law (ADR 0037): this file imports exactly ONE store
/// binding, so only the rustore purchase backend compiles into this
/// build's AOT kernel — never the google/apple one.
void main() {
  runZonedGuarded(() {
    unawaited(bootstrap(storeBinding: const RuStoreBinding()));
  }, MCPToolkitBinding.instance.handleZoneError);
}
