/// Web stub for the supervised world adapter: the ecsai daemon and the
/// realm scheduler are OS processes, so start/stop/registry-read have no
/// meaning where `dart:io` does not exist. The answers are NAMED
/// (`unsupported: true`) — never a fake success — so a caller that
/// reaches here on web sees the capability gap, not a silent lie.
///
/// Every signature MIRRORS the io variant exactly (the
/// conditional-import law: both variants answer the same call shape);
/// the pure argv helpers are shared through `supervised_world_commands`
/// (no platform dependency), so the web surface exports them too.
library;

import 'package:lastanswer/coding_agent/supervised_world_commands.dart';
import 'package:meta/meta.dart' show visibleForTesting;

export 'package:lastanswer/coding_agent/supervised_world_commands.dart';

/// Unsupported on web: the supervised daemon needs `dart:io`. The
/// signature MIRRORS the io variant exactly (the conditional-import
/// law: both variants answer the same call shape).
Future<Map<String, Object?>> startSupervisedEcsaiDaemon({
  required String daemonExecutablePath,
  String? workspaceHint,
  String? logPath,
  Duration readinessBudget = const Duration(seconds: 30),
}) async => const {
  'ok': false,
  'unsupported': true,
  'reason': 'supervised daemon start requires dart:io (mobile/desktop)',
};

/// Unsupported on web: the supervised scheduler needs `dart:io`.
Future<Map<String, Object?>> startSupervisedEcsaiScheduler({
  String? harnessRoot,
  String? schedulerPath,
  String? dartExecutable,
  String? workspaceHint,
  String? logPath,
  int maxActors = kDefaultSchedulerMaxActors,
  String schedulerId = kDefaultSchedulerId,
  Duration readinessBudget = const Duration(seconds: 30),
  Duration settleWindow = kSchedulerSettleWindow,
  @visibleForTesting String? debugWorkspace,
  @visibleForTesting Object? debugRegistry,
}) async => const {
  'ok': false,
  'unsupported': true,
  'component': ecsaiSchedulerComponentId,
  'reason': 'supervised scheduler start requires dart:io (mobile/desktop)',
};

/// Unsupported on web: the combined world converge needs `dart:io`.
Future<Map<String, Object?>> startSupervisedWorld({
  required String daemonExecutablePath,
  String? harnessRoot,
  String? schedulerPath,
  String? dartExecutable,
  String? workspaceHint,
  String? daemonLogPath,
  String? schedulerLogPath,
  int maxActors = kDefaultSchedulerMaxActors,
  String schedulerId = kDefaultSchedulerId,
  Duration readinessBudget = const Duration(seconds: 30),
  Duration schedulerSettleWindow = kSchedulerSettleWindow,
  @visibleForTesting String? debugWorkspace,
  @visibleForTesting Object? debugRegistry,
}) async => const {
  'ok': false,
  'unsupported': true,
  'components': supervisedWorldComponentIds,
  'reason': 'supervised world converge requires dart:io (mobile/desktop)',
};

/// Unsupported on web: the supervised daemon needs `dart:io`.
Future<Map<String, Object?>> stopSupervisedEcsaiDaemon({
  required String workspace,
  Duration grace = const Duration(seconds: 10),
}) async => const {
  'ok': false,
  'unsupported': true,
  'reason': 'supervised daemon stop requires dart:io (mobile/desktop)',
};

/// Unsupported on web: the supervised scheduler needs `dart:io`.
Future<Map<String, Object?>> stopSupervisedEcsaiScheduler({
  required String workspace,
  Duration grace = const Duration(seconds: 10),
  @visibleForTesting Object? debugRegistry,
}) async => const {
  'ok': false,
  'unsupported': true,
  'component': ecsaiSchedulerComponentId,
  'reason': 'supervised scheduler stop requires dart:io (mobile/desktop)',
};

/// Unsupported on web: the combined world stop needs `dart:io`.
Future<Map<String, Object?>> stopSupervisedWorld({
  required String workspace,
  Duration grace = const Duration(seconds: 10),
  @visibleForTesting Object? debugRegistry,
}) async => const {
  'ok': false,
  'unsupported': true,
  'stopOrder': supervisedWorldStopOrder,
  'reason': 'supervised world stop requires dart:io (mobile/desktop)',
};

/// Unsupported on web: the oka supervisor registry is file-backed
/// (`dart:io`). The honest web answer is `present: false, live: false` —
/// a scheduler this surface cannot see is reported unseen, never live.
Map<String, Object?> readSupervisedScheduler({
  required String workspace,
  Object? debugRegistry,
}) => const {
  'component': ecsaiSchedulerComponentId,
  'present': false,
  'live': false,
  'unsupported': true,
  'reason': 'supervised scheduler registry read requires dart:io',
};

/// Unsupported on web: there is no process runtime to discover. Null is
/// the honest answer — callers refuse by name.
Future<String?> resolveSchedulerDartExecutable() async => null;
