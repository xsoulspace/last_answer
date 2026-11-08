/// 4c — the LOCAL crash lane (privacy-first, zero new dependencies):
/// crashes are captured to the app-support directory as bounded JSON
/// reports — never uploaded anywhere. The project's privacy law is
/// local-first; Firebase crashlytics stays commented out until the
/// owner decides (plan v5 4c named the choice: "crashlytics re-enable
/// OR crashhunter" — this is the crashhunter-shaped local lane).
/// Analytics: deferred by the plan's own allowance ("≤4 events or
/// deferred") — a crash file is not an analytics event.
///
/// The capture law: capturing a crash must NEVER crash (every write is
/// guarded), the store is bounded ([maxReports], oldest pruned), and
/// the stack is capped (a report is a diagnostic, not a memory dump).
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// One captured crash: the durable facts, nothing invented.
final class CrashReport {
  const CrashReport({
    required this.at,
    required this.error,
    required this.stack,
    required this.platform,
  });

  factory CrashReport.fromJson(final Map<String, Object?> json) => CrashReport(
    at: '${json['at'] ?? ''}',
    error: '${json['error'] ?? ''}',
    stack: '${json['stack'] ?? ''}',
    platform: '${json['platform'] ?? ''}',
  );

  final String at;
  final String error;
  final String stack;
  final String platform;

  Map<String, Object?> toJson() => <String, Object?>{
    'at': at,
    'error': error,
    'stack': stack,
    'platform': platform,
  };
}

/// The crash store + the zone/error handlers that feed it.
abstract final class CrashReports {
  /// The store's bound: the newest [maxReports] survive, the oldest
  /// are pruned on every write (a crash loop never fills the disk).
  static const int maxReports = 20;

  /// The stack's bound (characters) — a diagnostic, not a dump.
  static const int maxStackChars = 8000;

  /// Test seam: where the store lives (default: the app-support dir).
  static Future<Directory> Function()? debugDirectoryOverride;

  static Future<Directory> _store() async {
    final base =
        await (debugDirectoryOverride ?? getApplicationSupportDirectory)();
    final dir = Directory('${base.path}${Platform.pathSeparator}crash_reports');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  /// Captures one crash. Never throws — a failing capture is a lost
  /// report, never a second crash.
  static Future<void> capture(
    final Object error,
    final StackTrace stack,
  ) async {
    try {
      final dir = await _store();
      var stackText = '$stack';
      if (stackText.length > maxStackChars) {
        stackText = stackText.substring(0, maxStackChars);
      }
      final report = CrashReport(
        at: DateTime.now().toUtc().toIso8601String(),
        error: '$error',
        stack: stackText,
        platform: Platform.operatingSystem,
      );
      final name =
          'crash-${DateTime.now().microsecondsSinceEpoch}-${identityHashCode(report)}.json';
      await File(
        '${dir.path}${Platform.pathSeparator}$name',
      ).writeAsString(jsonEncode(report.toJson()));
      await _prune(dir);
    } on Object {
      // The capture law: swallow — diagnostics never take the app down.
    }
  }

  static Future<void> _prune(final Directory dir) async {
    final files =
        dir
            .listSync()
            .whereType<File>()
            .where((final file) => file.path.endsWith('.json'))
            .toList()
          ..sort((final a, final b) => b.path.compareTo(a.path));
    for (final file in files.skip(maxReports)) {
      try {
        file.deleteSync();
      } on Object {
        // pruning is best-effort
      }
    }
  }

  /// The stored reports, newest first (a settings/export surface's
  /// read lane; absent store = empty list, never a throw).
  static Future<List<CrashReport>> list() async {
    try {
      final dir = await _store();
      final files =
          dir
              .listSync()
              .whereType<File>()
              .where((final file) => file.path.endsWith('.json'))
              .toList()
            ..sort((final a, final b) => b.path.compareTo(a.path));
      return [
        for (final file in files)
          CrashReport.fromJson(
            jsonDecode(file.readAsStringSync()) as Map<String, Object?>,
          ),
      ];
    } on Object {
      return const <CrashReport>[];
    }
  }

  /// Empties the store (the human's right to erase their diagnostics).
  static Future<void> clear() async {
    try {
      final dir = await _store();
      for (final file in dir.listSync().whereType<File>()) {
        file.deleteSync();
      }
    } on Object {
      // best-effort
    }
  }

  /// Wires the framework error sinks: FlutterError (framework/build
  /// errors) and the platform dispatcher (async window errors). The
  /// zone guard rides [guard]. Idempotent-ish: reinstalling replaces
  /// the handlers, it never stacks them.
  static void install() {
    FlutterError.onError = (final details) {
      FlutterError.presentError(details);
      unawaited(
        capture(details.exception, details.stack ?? StackTrace.current),
      );
    };
    PlatformDispatcher.instance.onError = (final error, final stack) {
      unawaited(capture(error, stack));
      return true;
    };
  }

  /// Runs [body] in the guarded zone: every uncaught async error
  /// becomes one stored report.
  static void guard(final FutureOr<void> Function() body) {
    unawaited(
      runZonedGuarded(
        () async => body(),
        (final error, final stack) => unawaited(capture(error, stack)),
      ),
    );
  }
}
