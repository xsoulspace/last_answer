// ignore_for_file: avoid_annotating_with_dynamic

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../interfaces/interfaces.dart';
import 'firebase_initializer.dart';

class FirebaseInitializerImpl implements FirebaseInitializer {
  FirebaseInitializerImpl({
    this.firebaseOptions,
  });
  @override
  final FirebaseOptions? firebaseOptions;

  @override
  Future<void> onLoad() async {}

  @override
  Future<void> onDelayedLoad() async {
    return;
  }
}

class FirebaseAnalyticsPlugin extends AnalyticsServicePlugin {
  bool isSupported = false;
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

  @override
  Future<void> onDelayedLoad() async {}

  @override
  Future<void> logAnalyticEvent(final AnalyticEvents event) async {}
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
