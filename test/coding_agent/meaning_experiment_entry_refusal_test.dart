import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/meaning_experiment_entry.dart';

void main() {
  test(
    'entry refusals localize distinct build, device and retry conditions',
    () {
      final primaryMessages = <String>[];
      for (final language in ['en', 'it', 'ru']) {
        final build = meaningExperimentRefusalLabel(
          language,
          'meaning_runtime_bundle_missing',
        );
        final device = meaningExperimentRefusalLabel(
          language,
          'meaning_runtime_platform_unsupported',
        );
        final retry = meaningExperimentRefusalLabel(
          language,
          'meaning_experiment_preparation_failed',
        );
        expect({build, device, retry}, hasLength(3));
        for (final message in [build, device, retry]) {
          expect(message, isNot(contains('meaning_')));
          expect(message, isNot(contains('dart')));
          expect(message, isNot(contains('PATH')));
        }
        primaryMessages.addAll([build, device, retry]);
        expect(
          meaningExperimentRefusalLabel(language, 'future_unknown_refusal'),
          retry,
        );
      }
      expect(primaryMessages.toSet(), hasLength(9));
      expect(
        meaningExperimentRefusalLabel('unsupported_locale', null),
        'Could not prepare the experiment. Try again.',
      );
    },
  );
}
