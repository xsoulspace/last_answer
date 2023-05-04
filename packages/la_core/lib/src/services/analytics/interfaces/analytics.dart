// ignore_for_file: avoid_annotating_with_dynamic

import 'package:flutter/foundation.dart';
import 'package:life_hooks/life_hooks.dart';

enum AnalyticEvents {
  usedInAndroid,
  usedInIOS,
  usedInWeb,
}

abstract class AnalyticsService implements Loadable, Disposable {
  Future<void> logAnalyticEvent(final AnalyticEvents event);
  // ignore: long-parameter-list
  Future<void> recordError(
    final dynamic exception,
    final StackTrace? stack, {
    final dynamic reason,
    final Iterable<DiagnosticsNode> information = const [],
    final bool fatal = false,
    final bool? printDetails,
  });
  Future<void> recordFlutterError(
    final FlutterErrorDetails flutterErrorDetails, {
    final bool fatal = false,
  });
  void log(final String value) {}
  void dynamicLog(final dynamic value) {}
  void dynamicInfoLog(final dynamic value) {}
  void dynamicErrorLog(final dynamic value) {}
  @override
  Future<void> onLoad();
  Future<void> onDelayedLoad();
}
