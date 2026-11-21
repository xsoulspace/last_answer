import 'dart:async';

import 'package:lastanswer/bootstrap.dart';
import 'package:lastanswer/store/bindings/snap.dart';
import 'package:mcp_toolkit/mcp_toolkit.dart';

/// The Snap Store delivery entrypoint (`oka run app-snap`).
///
/// Kernel-isolation law (ADR 0037): this file imports exactly ONE store
/// binding — the snap identity (no purchase backend) — and oka bakes
/// `OKA_STORE=snapstore` into this build, which the boot verifies
/// against the binding.
void main() {
  runZonedGuarded(() {
    unawaited(bootstrap(storeBinding: const SnapBinding()));
  }, MCPToolkitBinding.instance.handleZoneError);
}
