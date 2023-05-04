// ignore_for_file: avoid_annotating_with_dynamic

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../interfaces/interfaces.dart';
import '../utils/utils.dart';

class AnalyticsServiceImpl extends AnalyticsService {
  AnalyticsServiceImpl({
    required this.plugins,
  });
  final logsNotifier = ValueNotifier<List<String>>([]);
  final List<AnalyticsService> plugins;
  final logger =
      Logger(filter: kDebugMode ? DevelopmentFilter() : ProductionFilter());

  @override
  void dispose() {
    logsNotifier.dispose();
  }

  @override
  Future<void> logAnalyticEvent(final AnalyticEvents event) async {
    for (final plugin in plugins) {
      await plugin.logAnalyticEvent(event);
    }
  }

  List<String> get logs => logsNotifier.value;
  @override
  void log(final String value) {
    if (!kDebugMode) return;
    if (logs.length == 15) {
      logs.removeLast();
    }
    logs.insert(0, value);
  }

  @override
  void dynamicLog(final dynamic value) {
    logger.d(value);
    log(value.toString());
  }

  @override
  void dynamicInfoLog(final dynamic value) {
    logger.i(value);
    log(value.toString());
  }

  @override
  void dynamicErrorLog(final dynamic value) {
    logger.e(value);
    log(value.toString());
  }

  void clearLogs() {
    logs.clear();
  }

  @override
  // ignore: long-parameter-list
  Future<void> recordError(
    final dynamic exception,
    final StackTrace? stack, {
    final dynamic reason,
    final Iterable<DiagnosticsNode> information = const [],
    final bool fatal = false,
    bool? printDetails,
  }) async {
    // Use the debug flag if printDetails is not provided
    printDetails ??= kDebugMode;
    final errorDetailsStr = convertErrorDetailsToString(
      exception,
      stack,
      reason: reason,
      information: information,
      fatal: fatal,
      printDetails: printDetails,
    );
    // ignore: avoid_print
    if (printDetails) print(errorDetailsStr);

    log(errorDetailsStr);
    for (final plugin in plugins) {
      await plugin.recordError(
        exception,
        stack,
        reason: reason,
        information: information,
        fatal: fatal,
        printDetails: printDetails,
      );
    }
  }

  /// Use [fatal] to indicate whether the error is a fatal or not.
  @override
  Future<void> recordFlutterError(
    final FlutterErrorDetails flutterErrorDetails, {
    final bool fatal = false,
  }) async {
    FlutterError.presentError(flutterErrorDetails);
    for (final plugin in plugins) {
      await plugin.recordFlutterError(flutterErrorDetails, fatal: fatal);
    }
    // ignore: newline-before-return
    return recordError(
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
  Future<void> onLoad() async {
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (final errorDetails) async {
      await recordFlutterError(errorDetails);
      // Forward to original handler.
      originalOnError?.call(errorDetails);
    };
    for (final plugin in plugins) {
      await plugin.onLoad();
    }
  }

  @override
  Future<void> onDelayedLoad() async {
    for (final plugin in plugins) {
      await plugin.onDelayedLoad();
    }
  }
}
