import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/headless_product_cli.dart';
import 'package:xsoulspace_inference_core/xsoulspace_inference_core.dart';

void main() {
  test('diagnostic affinity is explicit and preserves native context', () {
    final base = {
      'model': 'gpt-6-luna',
      'reasoningEffort': 'low',
      'cloudConsent': true,
      'mode': 'baseline',
      'stableText': 'exact source',
      'volatileSuffix': 'B',
    };
    final plain = buildProjectionDiagnosticRequest(base);
    final keyed = buildProjectionDiagnosticRequest({
      ...base,
      'sessionSpec': {
        'id': 'diagnostic',
        'cache': {'group': 'fixed-group'},
      },
      'affinity': 'turn',
      'turnId': 'fixed-turn',
    });
    expect(
      keyed.metadata['openai_responses_input'],
      plain.metadata['openai_responses_input'],
    );
    expect(
      InferenceSessionContext.fromRequest(keyed)!.session.effectiveCacheGroup,
      'fixed-group',
    );
    expect(keyed.metadata['openai_session_options'], {
      'sessionAffinity': true,
      'turnAffinity': true,
    });
    expect(
      () => buildProjectionDiagnosticRequest({...base, 'affinity': 'turn'}),
      throwsFormatException,
    );
  });

  Map<String, dynamic> command(String mode) => {
    'model': 'gpt-6-luna',
    'reasoningEffort': 'low',
    'cloudConsent': true,
    'mode': mode,
    'stableText': ' exact source\n😀\n',
    'volatileSuffix': 'suffix B',
  };

  test('comparison adds metadata and preserves exact native input', () {
    final plain = buildProjectionDiagnosticRequest(command('baseline'));
    final comparison = buildProjectionDiagnosticRequest({
      ...command('baseline'),
      'comparisonResponseId': 'resp_test',
    });
    expect(
      comparison.metadata['openai_responses_input'],
      plain.metadata['openai_responses_input'],
    );
    expect(comparison.metadata[contextCacheComparisonMetadataKey], {
      'baselineResponseId': 'resp_test',
    });
  });

  test('both arms preserve exact text, roles and two native blocks', () {
    final baseline = buildProjectionDiagnosticRequest(command('baseline'));
    final explicit = buildProjectionDiagnosticRequest(command('explicit'));
    final expected = [
      {
        'type': 'message',
        'role': 'user',
        'content': [
          {'type': 'input_text', 'text': ' exact source\n😀\n'},
          {'type': 'input_text', 'text': 'suffix B'},
        ],
      },
    ];
    for (final request in [baseline, explicit]) {
      expect(request.metadata['openai_responses_input'], expected);
      expect(request.prompt, '');
      expect(request.systemPrompt, 'Reply exactly OK');
      expect(request.reasoningEffort, 'low');
      expect(request.messages, isEmpty);
      expect(request.outputSchema, isEmpty);
      expect(request.maxTokens, isNull);
      expect(request.temperature, isNull);
    }
    expect(
      baseline.metadata[contextCacheIntentMetadataKey],
      ContextCacheIntent().toJson(),
    );
    expect(
      explicit.metadata[contextCacheIntentMetadataKey],
      ContextCacheIntent(
        writeAfterSegmentIds: ['input[0].content[0]'],
        lookupAfterSegmentIds: ['input[0].content[0]'],
      ).toJson(),
    );
  });

  test('diagnostic refuses other model, effort, mode and missing consent', () {
    for (final entry in {
      'model': 'gpt-6-sol',
      'reasoningEffort': 'high',
      'mode': 'guess',
      'cloudConsent': false,
      'stableText': '',
      'volatileSuffix': null,
    }.entries) {
      expect(
        () => buildProjectionDiagnosticRequest({
          ...command('baseline'),
          entry.key: entry.value,
        }),
        throwsFormatException,
        reason: entry.key,
      );
    }
  });

  test(
    'prewarm writes stable message that appended suffix leaves identical',
    () {
      final warm = buildProjectionDiagnosticRequest({
        ...command('prewarm'),
        'volatileSuffix': '',
      });
      final appended = buildProjectionDiagnosticRequest(
        command('message_boundary'),
      );
      final warmItems = warm.metadata['openai_responses_input'] as List;
      final appendedItems = appended.metadata['openai_responses_input'] as List;
      expect(warmItems, hasLength(1));
      expect(appendedItems, hasLength(2));
      expect(warmItems.single, appendedItems.first);
      expect((warmItems.single as Map)['role'], 'user');
      expect((warmItems.single as Map)['content'], [
        {'type': 'input_text', 'text': ' exact source\n😀\n'},
      ]);
      expect((appendedItems.last as Map)['role'], 'user');
      expect((appendedItems.last as Map)['content'], [
        {'type': 'input_text', 'text': 'suffix B'},
      ]);
      for (final request in [warm, appended]) {
        expect(
          request.metadata[contextCacheIntentMetadataKey],
          ContextCacheIntent().toJson(),
        );
        expect(request.systemPrompt, 'Reply exactly OK');
        expect(request.reasoningEffort, 'low');
        expect(request.maxTokens, isNull);
      }
      expect(
        () => buildProjectionDiagnosticRequest(command('prewarm')),
        throwsFormatException,
      );
    },
  );
}
