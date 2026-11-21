import 'package:xsoulspace_foundation/xsoulspace_foundation.dart';

/// The contract an initializer implements so the composition root can
/// load and dispose it uniformly (moved from packages/shared_models
/// foundation, ADR 0038).
abstract interface class StateInitializer implements Loadable, Disposable {}
