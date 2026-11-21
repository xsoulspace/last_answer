import 'dart:async';

import 'package:lastanswer/bootstrap.dart';
import 'package:lastanswer/store/bindings/noop.dart';
import 'package:mcp_toolkit/mcp_toolkit.dart';

/// The dev entrypoint: the store-neutral noop binding (ADR 0037),
/// passed explicitly — bootstrap has no default binding, so a forgotten
/// one is an analyze error, never a silent no-purchase release build.
/// Store deliveries boot from `lib/entrypoints/main_store_<x>.dart`.
void main() {
  runZonedGuarded(() {
    unawaited(bootstrap(storeBinding: noopStoreBinding));
  }, MCPToolkitBinding.instance.handleZoneError);
}
