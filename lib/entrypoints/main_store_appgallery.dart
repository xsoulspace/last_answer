import 'dart:async';

import 'package:lastanswer/bootstrap.dart';
import 'package:lastanswer/store/bindings/appgallery.dart';
import 'package:mcp_toolkit/mcp_toolkit.dart';

/// The AppGallery-delivery entrypoint (`oka run app-appgallery`).
///
/// Kernel-isolation law (ADR 0037): this file imports exactly ONE store
/// binding — the AppGallery identity (no purchase backend yet) — and
/// oka bakes `OKA_STORE=appgallery` into this build, which the boot
/// verifies against the binding.
void main() {
  runZonedGuarded(() {
    unawaited(bootstrap(storeBinding: const AppGalleryBinding()));
  }, MCPToolkitBinding.instance.handleZoneError);
}
