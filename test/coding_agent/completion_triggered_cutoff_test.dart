import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/completion_triggered_cutoff.dart';
import 'package:xsoulspace_agentic_harness/xsoulspace_agentic_harness.dart';

CausalTraceRecord settled(String? decision, {String outcome = 'completed'}) =>
    CausalTraceRecord(
      stage: 'inference_settled',
      actorId: 'actor',
      actorEntity: 'entity',
      decisionId: decision,
      outcome: outcome,
    );

void main() {
  test(
    'completion cutoff cancels synchronously once after dedup successes',
    () {
      var cancellations = 0;
      final cutoff =
          CompletionTriggeredCutoff(
              maximum: 2,
              cancel: () {
                cancellations++;
              },
            )
            ..observe(settled('first'))
            ..observe(settled('first'))
            ..observe(settled('failed', outcome: 'cancelled'))
            ..observe(settled(null));
      expect(cutoff.completed, 1);
      expect(cancellations, 0);
      cutoff.observe(settled('second'));
      expect(cancellations, 1, reason: 'cancel runs before observe returns');
      expect(cutoff.triggered, isTrue);
      cutoff.observe(settled('third'));
      expect(
        cutoff.completed,
        3,
        reason: 'late parallel completions remain visible',
      );
      expect(cancellations, 1);
      expect(cutoff.toJson()['scope'], 'session_operation');
      expect(cutoff.toJson()['strictInferenceStartBudget'], isFalse);
    },
  );

  test('each operation has a fresh counter and invalid limits refuse', () {
    expect(
      () => CompletionTriggeredCutoff(maximum: 0, cancel: () {}),
      throwsFormatException,
    );
    var cancellations = 0;
    CompletionTriggeredCutoff(
      maximum: 1,
      cancel: () {
        cancellations++;
      },
    ).observe(settled('same-id'));
    CompletionTriggeredCutoff(
      maximum: 1,
      cancel: () {
        cancellations++;
      },
    ).observe(settled('same-id'));
    expect(cancellations, 2);
  });
}
