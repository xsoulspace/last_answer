import 'package:xsoulspace_agentic_harness/xsoulspace_agentic_harness.dart';

/// Transient observation of one CLI operation's session activity. This counts
/// settled successes and requests cancellation. It does not limit starts.
final class CompletionTriggeredCutoff {
  CompletionTriggeredCutoff({required this.maximum, required this.cancel}) {
    if (maximum < 1) {
      throw const FormatException('positive_max_completed_inferences_required');
    }
  }

  final int maximum;
  final void Function() cancel;
  final _completed = <String>{};
  bool triggered = false;
  int get completed => _completed.length;

  void observe(CausalTraceRecord record) {
    if (record.stage != 'inference_settled' ||
        record.outcome != 'completed' ||
        record.decisionId == null) {
      return;
    }
    if (!_completed.add('${record.actorEntity}:${record.decisionId}')) return;
    if (!triggered && completed >= maximum) {
      triggered = true;
      cancel();
    }
  }

  Map<String, Object?> toJson() => {
    'kind': 'completion_triggered_cancellation',
    'scope': 'session_operation',
    'maximum': maximum,
    'completed': completed,
    'triggered': triggered,
    'strictInferenceStartBudget': false,
  };
}
