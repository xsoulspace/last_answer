import 'dart:async';

import 'package:lastanswer/bootstrap.dart';
import 'package:mcp_toolkit/mcp_toolkit.dart';

/// The dev entrypoint: the store-neutral noop binding (ADR 0037).
/// Store deliveries boot from `lib/entrypoints/main_store_<x>.dart`.
void main() {
  runZonedGuarded(() {
    unawaited(bootstrap());
  }, MCPToolkitBinding.instance.handleZoneError);
}
