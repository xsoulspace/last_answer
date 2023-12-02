// ignore_for_file: avoid_annotating_with_dynamic

import 'package:firebase_analytics_web/firebase_analytics_web.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:flutter/material.dart';

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
  Future<void> onLoad() async {}
  @override
  Future<void> onDelayedLoad() async {
    await FirebaseCoreWeb().initializeApp(
      options: firebaseOptions,
    );
  }
}

class FirebaseAnalyticsPlugin extends AnalyticsServicePlugin {
  FirebaseAnalyticsWeb analytics = FirebaseAnalyticsWeb();
  bool _isEnabled = false;
  bool _shouldRecordErrors = false;

  @override
  Future<void> onLoad() async {}
  @override
  Future<void> onDelayedLoad() async {
    _isEnabled = kTestingAnalytics || await analytics.isSupported();
    if (_isEnabled) {
      /// Logs the standard `app_open` event.
      ///
      /// See: https://firebase.google.com/docs/reference/android/com/google/firebase/analytics/FirebaseAnalytics.Event.html#APP_OPEN
      await analytics.logEvent(name: 'app_open');
      _shouldRecordErrors = true;
    }
  }

  @override
  Future<void> recordError(
    final dynamic exception,
    final StackTrace? stack, {
    final dynamic reason,
    final Iterable<DiagnosticsNode> information = const [],
    final bool fatal = false,
    final bool? printDetails,
  }) async {
    if (!_isEnabled && !_shouldRecordErrors) return;
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
    if (!_isEnabled && !_shouldRecordErrors) return;
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
  Future<void> logAnalyticEvent(final AnalyticEvents event) async {
    if (!_isEnabled) return;
    await analytics.logEvent(name: event.name);
  }
}

class FirebaseCrashlyticsPlugin extends AnalyticsServicePlugin {
  @override
  Future<void> logAnalyticEvent(final AnalyticEvents event) async {}

  @override
  Future<void> onDelayedLoad() async {}

  @override
  Future<void> onLoad() async {}

  @override
  Future<void> recordError(
    final dynamic exception,
    final StackTrace? stack, {
    final dynamic reason,
    final Iterable<DiagnosticsNode> information = const [],
    final bool fatal = false,
    final bool? printDetails,
  }) async {}

  @override
  Future<void> recordFlutterError(
    final FlutterErrorDetails flutterErrorDetails, {
    final bool fatal = false,
  }) async {}
}
