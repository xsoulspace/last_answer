// ignore_for_file: avoid_annotating_with_dynamic

import 'package:flutter/foundation.dart';
import 'package:life_hooks/life_hooks.dart';

enum AnalyticEvents {
  usedInAndroid,
  usedInIOS,
  usedInWeb,
}

abstract interface class AnalyticsService extends AnalyticsServicePlugin {
  void upsertPlugin<T extends AnalyticsServicePlugin>(final T plugin);
}

abstract interface class AnalyticsServicePlugin
    implements Loadable, Disposable {
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

  Future<void> onDelayedLoad();

  /// noop implementation
  void dynamicLog(
    final dynamic value, {
    final String message = '',
    final StackTrace? stackTrace,
    // ignore: no-empty-block
  }) {}
  void dynamicWarningLog(
    final dynamic value, {
    final String message = '',
    final StackTrace? stackTrace,
  }) {}

  /// noop implementation
  void dynamicInfoLog(
    final dynamic value, {
    final String message = '',
    final StackTrace? stackTrace,
    // ignore: no-empty-block
  }) {}

  /// noop implementation
  void dynamicErrorLog(
    final dynamic value, {
    final String message = '',
    final StackTrace? stackTrace,
// ignore: no-empty-block
  }) {}
}
