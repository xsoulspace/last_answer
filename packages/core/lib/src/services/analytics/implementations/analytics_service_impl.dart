// ignore_for_file: avoid_annotating_with_dynamic

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../interfaces/interfaces.dart';
import '../utils/utils.dart';

@immutable
class AnalyticsServiceImpl extends AnalyticsService {
  AnalyticsServiceImpl({
    final Map<Type, AnalyticsServicePlugin>? plugins,
    this.isTerminalUseAnsiEscapeSequences = false,
  }) : plugins = plugins ?? {};

  /// Please note that all IDEs (VSCode, XCode, Android Studio, IntelliJ)
  /// do not support ANSI escape sequences in their terminal outputs.
  /// These escape sequences are used to color output.
  /// If using such an IDE do not configure colored output
  ///
  /// https://pub.dev/packages/logger#colors
  final bool isTerminalUseAnsiEscapeSequences;

  final logsNotifier = ValueNotifier<List<String>>([]);
  final Map<Type, AnalyticsServicePlugin> plugins;

  late final logger = Logger(
    filter: kDebugMode ? DevelopmentFilter() : ProductionFilter(),
    printer: PrettyPrinter(
      printTime: true,
      colors: isTerminalUseAnsiEscapeSequences,
    ),
  );

  @override
  void upsertPlugin<T extends AnalyticsServicePlugin>(final T plugin) {
    plugins[T] = plugin;
  }

  @override
  void dispose() {
    logsNotifier.dispose();

    super.dispose();
  }

  @override
  Future<void> logAnalyticEvent(final AnalyticEvents event) async {
    for (final plugin in plugins.values) {
      await plugin.logAnalyticEvent(event);
    }
  }

  List<String> get logs => logsNotifier.value;
  void logString(final String value) {
    if (!kDebugMode) return;
    if (logs.length == 15) {
      logs.removeLast();
    }
    logs.insert(0, value);
  }

  @override
  void dynamicLog(
    final dynamic value, {
    final String message = '',
    final StackTrace? stackTrace,
  }) {
    logger.d(message, error: value, stackTrace: stackTrace);
    logString('$message $value $stackTrace');
  }

  @override
  void dynamicInfoLog(
    final dynamic value, {
    final String message = '',
    final StackTrace? stackTrace,
  }) {
    logger.i(message, error: value, stackTrace: stackTrace);
    logString('$message $value $stackTrace');
  }

  @override
  void dynamicWarningLog(
    final dynamic value, {
    final String message = '',
    final StackTrace? stackTrace,
  }) {
    logger.w(message, error: value, stackTrace: stackTrace);
    logString('$message $value $stackTrace');
  }

  @override
  void dynamicErrorLog(
    final dynamic value, {
    final String message = '',
    final StackTrace? stackTrace,
  }) {
    logger.e(message, error: value, stackTrace: stackTrace);
    logString('$message $value $stackTrace');
  }

  void clearLogs() {
    logs.clear();
  }

  @override
  void reportIntededException([final dynamic value]) {
    dynamicWarningLog(value);
    for (final plugin in plugins.values) {
      plugin.reportIntededException(value);
    }
  }

  @override
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
    if (printDetails) debugPrint(errorDetailsStr);

    logString(errorDetailsStr);
    for (final plugin in plugins.values) {
      plugin
          .recordError(
            exception,
            stack,
            reason: reason,
            information: information,
            fatal: fatal,
            printDetails: printDetails,
          )
          .ignore();
    }
  }

  /// Use [fatal] to indicate whether the error is a fatal or not.
  @override
  Future<void> recordFlutterError(
    final FlutterErrorDetails flutterErrorDetails, {
    final bool fatal = false,
  }) async {
    FlutterError.presentError(flutterErrorDetails);
    for (final plugin in plugins.values) {
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
    FlutterError.onError = (final errorDetails) {
      unawaited(recordFlutterError(errorDetails));
      // Forward to original handler.
      originalOnError?.call(errorDetails);
    };

    for (final plugin in plugins.values) {
      await plugin.onLoad();
    }
  }

  @override
  Future<void> onDelayedLoad() async {
    for (final plugin in plugins.values) {
      await plugin.onDelayedLoad();
    }
  }
}
