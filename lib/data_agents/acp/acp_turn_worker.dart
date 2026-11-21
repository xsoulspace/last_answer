/// The actor host's handle on one ACP session.
///
/// The host fans addressed beats here the same way it fans them to a
/// text brain. The worker does not mint an actor and does not own a room.
abstract interface class AcpTurnWorker {
  String get actorId;

  /// The ACP provider's model id (`grok`, `codex`, a saved server key).
  String get agentId;

  bool get isRunning;

  Future<void> handleBeat(Map<String, Object?> beat);

  Future<void> stop();
}
