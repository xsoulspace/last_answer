import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/meaning_experiment_controller.dart';

void main() {
  test('missing compact preview contract refuses without dispatch', () async {
    final calls = <String>[];
    final controller = MeaningExperimentController(
      invoke: (action, arguments) async {
        calls.add(action);
        return {'ok': true, 'operation': 'incomplete display metadata'};
      },
    );
    addTearDown(controller.dispose);
    final result = await controller.action('preview');
    expect(result['error'], 'meaning_preview_contract_unavailable');
    expect(calls, ['ground']);
    expect(controller.proposalId, isNull);
    expect(controller.rollbackAvailable, isFalse);
  });

  test(
    'product authors operands and leaves binding metadata with native host',
    () async {
      final controller = MeaningExperimentController(
        invoke: (action, arguments) async {
          if (action == 'ground') {
            return {
              'ok': true,
              'preview_request': {
                'action': 'preview',
                'groundingId': 'native-reference',
                'opChain': const [],
              },
            // Display fields cannot become an alternative source of
            // authority.
              'operation': 'altered display', 'binding': 'altered display',
              'reads': 'altered display', 'correspondence': 'altered display',
            };
          }
          expect(action, 'preview');
          expect(arguments.keys.toSet(), {'groundingId', 'opChain'});
          expect(arguments['groundingId'], 'native-reference');
          expect(arguments['opChain'], [
            {'label': 'load_return'},
            {'label': 'literal', 'b': ' — updated'},
            {'label': 'concat'},
            {'label': 'return'},
          ]);
          return {'ok': false, 'error': 'synthetic_native_stop'};
        },
      );
      addTearDown(controller.dispose);
      final result = await controller.action('preview');
      expect(result['error'], 'synthetic_native_stop');
      expect(controller.proposalId, isNull);
      expect(controller.rollbackAvailable, isFalse);
    },
  );
}
