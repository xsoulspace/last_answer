// ignore_for_file: avoid_annotating_with_dynamic
import 'package:flutter/foundation.dart';
import 'package:xsoulspace_foundation/xsoulspace_foundation.dart';

enum AnalyticEvents { usedInAndroid, usedInIOS, usedInWeb }

abstract class AnalyticsService extends AnalyticsServicePlugin {
  void upsertPlugin<T extends AnalyticsServicePlugin>(final T plugin);
}

abstract class AnalyticsServicePlugin implements Loadable, Disposable {
  void reportIntededException([final dynamic value]) {}
  Future<void> logAnalyticEvent(final AnalyticEvents event);
  Future<void> onDelayedLoad();
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

  @override
  Future<void> onLoad();

  /// noop implementation
  void dynamicLog(
    final dynamic value, {
    final String message = '',
    final StackTrace? stackTrace,
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
  }) {}

  /// noop implementation
  void dynamicErrorLog(
    final dynamic value, {
    final String message = '',
    final StackTrace? stackTrace,
  }) {}

  @override
  @mustCallSuper
  void dispose() {}
}
