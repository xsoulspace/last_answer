import 'package:firebase_core/firebase_core.dart';
import 'package:life_hooks/life_hooks.dart';

import '../services/services.dart';

abstract interface class GlobalInitializer implements Loadable {
  AnalyticsService get analyticsService;
}

class GlobalInitializerImpl extends GlobalInitializer {
  GlobalInitializerImpl({
    this.firebaseOptions,
  });
  @override
  late final AnalyticsService analyticsService;
  final FirebaseOptions? firebaseOptions;
  @override
  Future<void> onLoad() async {
    final effectiveFirebaseOptions = firebaseOptions;
    final plugins = <Type, AnalyticsServicePlugin>{};
    if (effectiveFirebaseOptions != null) {
      await FirebaseInitializerImpl(firebaseOptions: effectiveFirebaseOptions)
          .onLoad();
      plugins.addAll({
        FirebaseAnalyticsPlugin: FirebaseAnalyticsPlugin(),
        FirebaseCrashlyticsPlugin: FirebaseCrashlyticsPlugin(),
      });
    }
    analyticsService = AnalyticsServiceImpl(plugins: plugins);
    await analyticsService.onLoad();
  }
}
