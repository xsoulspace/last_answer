/// The monetization data concern: purchases + ads data sources,
/// repositories, notifiers, and the monetization wiring. See
/// DATA_MONETIZATION_KNOWLEDGE.md.
library;

export 'ads_notifier.dart';
export 'ads_repository.dart';
export 'data_sources/interfaces/ads.dart';
export 'data_sources/interfaces/purchases.dart';
export 'data_sources/local/ads.dart';
export 'data_sources/local/purchases.dart';
export 'data_sources/remote/purchases.dart';
export 'monetization.dart';
export 'purchases_notifier.dart';
export 'purchases_repository.dart';
