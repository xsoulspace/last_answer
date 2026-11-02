/// Web stub for the supervised daemon adapter: the ecsai daemon is an
/// OS process, so start/stop have no meaning where `dart:io` does not
/// exist. The answers are NAMED (`unsupported: true`) — never a fake
/// success — so a caller that reaches here on web sees the capability
/// gap, not a silent lie.
library;

/// Unsupported on web: the supervised daemon needs `dart:io`.
Future<Map<String, Object?>> startSupervisedEcsaiDaemon({
  required String workspace,
  required String daemonExecutablePath,
  String? logPath,
  Duration readinessBudget = const Duration(seconds: 30),
}) async => const {
  'ok': false,
  'unsupported': true,
  'reason': 'supervised daemon start requires dart:io (mobile/desktop)',
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
