import 'dart:async';

import 'package:lastanswer/bootstrap.dart';
import 'package:lastanswer/store/bindings/google_play.dart';
import 'package:mcp_toolkit/mcp_toolkit.dart';

/// The Google Play delivery entrypoint (`oka run app-google-play`).
///
/// Kernel-isolation law (ADR 0037): this file imports exactly ONE store
/// binding, so only the google/apple purchase backend compiles into this
/// build's AOT kernel — never the rustore one.
void main() {
  runZonedGuarded(() {
    unawaited(bootstrap(storeBinding: const GooglePlayBinding()));
  }, MCPToolkitBinding.instance.handleZoneError);
}
