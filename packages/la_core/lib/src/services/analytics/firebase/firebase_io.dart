import 'dart:isolate';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:universal_io/io.dart';

import '../../../utils/utils.dart';
import '../interfaces/interfaces.dart';
import '../utils/utils.dart';
import 'firebase_initializer.dart';

class FirebaseInitializerImpl implements FirebaseInitializer {
  FirebaseInitializerImpl({
    required this.firebaseOptions,
  });
  @override
  final FirebaseOptions? firebaseOptions;
  @override
  Future<void> onLoad() async {
    if (firebaseOptions == null) return;
    await Firebase.initializeApp(
      options: firebaseOptions,
    );
  }

  @override
  Future<void> onDelayedLoad() async {
    return;
  }
}

class FirebaseAnalyticsPlugin extends AnalyticsService {
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  bool _isEnabled = false;
  bool _shouldRecordErrors = false;
  @override
  Future<void> onLoad() async {
    _isEnabled = kTestingAnalytics ||
        (!Platform.isLinux && await analytics.isSupported());
    if (_isEnabled) {
      _shouldRecordErrors = kTestingAnalytics || kDebugMode;
      await analytics.logAppOpen();
    }
  }

  @override
  Future<void> recordError(
    final exception,
    final StackTrace? stack, {
    final reason,
    final Iterable<DiagnosticsNode> information = const [],
    final bool fatal = false,
    final bool? printDetails,
  }) async {
    if (!_isEnabled || !_shouldRecordErrors) return;
    final errorDetailsStr = convertErrorDetailsToString(
      exception,
      stack,
      reason: reason,
      information: information,
      fatal: fatal,
      printDetails: printDetails,
    );
    await analytics.logEvent(
      name: 'flutter_error',
      parameters: {'details': errorDetailsStr},
    );
  }

  @override
  Future<void> recordFlutterError(
    final FlutterErrorDetails flutterErrorDetails, {
    final bool fatal = false,
  }) async {
    if (!_isEnabled || !_shouldRecordErrors) return;
    await recordError(
      flutterErrorDetails.exceptionAsString(),
      flutterErrorDetails.stack,
      reason: flutterErrorDetails.context,
      information: flutterErrorDetails.informationCollector == null
          ? []
          : flutterErrorDetails.informationCollector!(),
      printDetails: false,
      fatal: fatal,
    );
  }

  @override
  Future<void> onDelayedLoad() async {
    return;
  }

  @override
  Future<void> logAnalyticEvent(final AnalyticEvents event) async {
    if (!_isEnabled) return;
    await analytics.logEvent(name: event.name);
  }

  @override
  void dispose() {}
}

class FirebaseCrashlyticsPlugin extends AnalyticsService {
  FirebaseCrashlytics crashlitics = FirebaseCrashlytics.instance;
  bool isEnabled = false;
  @override
  Future<void> onLoad() async {
    // Force enable crashlytics collection enabled if we're testing it.
    // Else only enable it in non-debug builds.
    isEnabled = kTestingCrashlytics || DeviceRuntimeType.isMobile;

    if (isEnabled) {
      // You could additionally extend this to allow users to opt-in.
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(isEnabled);
      Isolate.current.addErrorListener(
        RawReceivePort((final pair) async {
          final List<dynamic> errorAndStacktrace = pair;
          await FirebaseCrashlytics.instance.recordError(
            errorAndStacktrace.first,
            errorAndStacktrace.last,
            fatal: true,
          );
        }).sendPort,
      );
      // Pass all uncaught asynchronous errors that aren't handled by the
      // Flutter framework to Crashlytics
      PlatformDispatcher.instance.onError = (final error, final stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);

        return true;
      };
    }
  }

  @override
  Future<void> onDelayedLoad() async {}

  @override
  Future<void> recordError(
    final exception,
    final StackTrace? stack, {
    final reason,
    final Iterable<DiagnosticsNode> information = const [],
    final bool fatal = false,
    final bool? printDetails,
  }) async {
    if (!isEnabled) return;
    await FirebaseCrashlytics.instance.recordError(
      exception,
      stack,
      fatal: fatal,
      information: information,
      printDetails: printDetails,
      reason: reason,
    );
  }

  @override
  Future<void> recordFlutterError(
    final FlutterErrorDetails flutterErrorDetails, {
    final bool fatal = false,
  }) async {
    if (!isEnabled) return;
    await FirebaseCrashlytics.instance.recordFlutterError(
      flutterErrorDetails,
      fatal: fatal,
    );
  }

  @override
  Future<void> logAnalyticEvent(final AnalyticEvents event) async {}

  static Future<void> testAsyncErrorOnInit() async {
    Future<void>.delayed(const Duration(seconds: 2), () {
      final List<int> list = <int>[];
      // ignore: avoid_print
      print(list[100]);
    });
  }

  @override
  void dispose() {}
}
