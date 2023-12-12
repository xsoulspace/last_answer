import 'package:firebase_core/firebase_core.dart';
import 'package:shared_models/shared_models.dart';

import '../../../core.dart';

abstract class GlobalServicesInitializer implements Loadable {
  AnalyticsService get analyticsService;
}

class GlobalServicesInitializerMockImpl extends GlobalServicesInitializer {
  @override
  final AnalyticsService analyticsService = AnalyticsServiceImpl();

  @override
  Future<void> onLoad() async {}
}

class GlobalServicesInitializerImpl extends GlobalServicesInitializer {
  GlobalServicesInitializerImpl({
    this.firebaseOptions,
  });

  @override
  final AnalyticsService analyticsService = AnalyticsServiceImpl();

  final FirebaseOptions? firebaseOptions;
  FirebaseInitializer? _firebaseInitializer;

  FirebaseInitializer? get firebaseInitializer => _firebaseInitializer;

  @override
  Future<void> onLoad() async {
    final effectiveFirebaseOptions = firebaseOptions;
    if (effectiveFirebaseOptions != null) {
      Future<void> addAnalytics() async {
        _firebaseInitializer =
            FirebaseInitializerImpl(firebaseOptions: effectiveFirebaseOptions);
        await _firebaseInitializer?.onLoad();
        analyticsService
          ..upsertPlugin(FirebaseCrashlyticsPlugin())
          ..upsertPlugin(FirebaseAnalyticsPlugin());
        await firebaseInitializer?.onDelayedLoad();
      }

      await addAnalytics();
    }
    await analyticsService.onLoad();
  }
}
