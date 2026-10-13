import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/meaning_experiment_controller.dart';

void main() {
  test(
    'synthetic unknown effect automatically reads native status without replay',
    () async {
      var calls = 0;
      final controller =
          MeaningExperimentController(
              invoke: (action, _) async {
                calls++;
                if (action == 'apply') {
                  return {
                    'ok': false,
                    'error': 'native_effect_outcome_unknown',
                    'proposalId': 'p',
                    'runId': 'r',
                  };
                }
                if (action == 'status') {
                  return {
                    'ok': true,
                    'issued_previews': [
                      {
                        'proposal': {'proposalId': 'p'},
                        'invoked': true,
                      },
                    ],
                    'native_runs': [
                      {
                        'runId': 'r',
                        'proposalId': 'p',
                        'known_in_session': true,
                        'status': 'applied',
                      },
                    ],
                  };
                }
                return {
                  'ok': true,
                  'action': action,
                  'observation': 'baseline',
                };
              },
            )
            ..proposalId = 'p'
            ..currentObservation = 'baseline';
      addTearDown(controller.dispose);
      expect(
        (await controller.action('apply'))['error'],
        'native_effect_outcome_unknown',
      );
      expect(controller.runId, 'r');
      expect(controller.currentObservation, isNull);
      expect(controller.currentObservationUnknown, true);
      expect(controller.rollbackAvailable, true);
      expect(calls, 2);
      expect(
        controller.receipts.first['error'],
        'native_effect_outcome_unknown',
      );
      expect(controller.receipts.last['action'], 'status');
      expect(controller.refusal, 'native_effect_outcome_unknown');
      expect(
        (await controller.action('apply'))['error'],
        'proposal_already_invoked',
      );
      expect(
        (await controller.action('preview'))['error'],
        'meaning_native_run_open',
      );
      expect(calls, 2);
      await controller.action('rollback');
      expect(controller.currentObservation, 'baseline');
      expect(controller.currentObservationUnknown, false);
      expect(controller.rollbackAvailable, false);
    },
  );

  test('restored unknown journal never restores proposal authority', () async {
    final controller =
        MeaningExperimentController(
            invoke: (_, _) async => {
              'ok': true,
              'issued_previews': [],
              'native_runs': [
                {'runId': 'r', 'known_in_session': false, 'status': 'applied'},
              ],
            },
          )
          ..proposalId = 'old'
          ..runId = 'r'
          ..rollbackAvailable = true
          ..preview = {'historical': true};
    addTearDown(controller.dispose);
    await controller.action('status');
    expect(controller.proposalId, isNull);
    expect(controller.runId, isNull);
    expect(controller.rollbackAvailable, false);
    expect(controller.refusal, 'meaning_preview_lost');
    expect(controller.preview, {'historical': true});
    expect(
      (await controller.action('apply'))['error'],
      'meaning_preview_required',
    );
    expect(
      (await controller.action('rollback'))['error'],
      'meaning_run_required',
    );
  });

  test(
    'synthetic rollback unknown stays unknown after journal-only status',
    () async {
      final pending = Completer<Map<String, Object?>>();
      final controller =
          MeaningExperimentController(
              invoke: (action, _) async {
                if (action == 'rollback') return pending.future;
                return {
                  'ok': true,
                  'issued_previews': [
                    {
                      'proposal': {'proposalId': 'p'},
                      'invoked': true,
                    },
                  ],
                  'native_runs': [
                    {
                      'runId': 'r',
                      'proposalId': 'p',
                      'known_in_session': true,
                      'status': 'rolledBack',
                    },
                  ],
                };
              },
            )
            ..proposalId = 'p'
            ..runId = 'r'
            ..rollbackAvailable = true
            ..currentObservation = 'applied candidate'
            ..applied = {'observation': 'applied candidate'};
      addTearDown(controller.dispose);
      final rollback = controller.action('rollback');
      expect(controller.currentObservation, isNull);
      expect(controller.toJson()['currentObservationUnknown'], true);
      expect(controller.rollbackAvailable, false);
      // Shape verified independently in native post-inverse observer failure.
      pending.complete({
        'ok': false,
        'error': 'native_effect_outcome_unknown',
        'action': 'rollback',
        'proposalId': 'p',
        'runId': 'r',
        'native_status': 'rolledBack',
        'effect_replay_available': false,
        'detail': 'observer unavailable after inverse',
      });
      await rollback;
      expect(controller.currentObservation, isNull);
      expect(controller.toJson()['currentObservationUnknown'], true);
      expect(controller.rollbackAvailable, false);
      expect(controller.applied!['observation'], 'applied candidate');
    },
  );

  test('synthetic unknown finalize disables recovery until status', () async {
    final controller =
        MeaningExperimentController(
            invoke: (_, _) async => {
              'ok': false,
              'error': 'native_effect_outcome_unknown',
              'action': 'finalize',
              'proposalId': 'p',
              'runId': 'r',
              'native_status': 'pruned',
              'effect_replay_available': false,
            },
          )
          ..proposalId = 'p'
          ..runId = 'r'
          ..rollbackAvailable = true
          ..currentObservation = 'candidate';
    addTearDown(controller.dispose);
    await controller.action('finalize');
    expect(controller.rollbackAvailable, false);
    expect(controller.currentObservation, 'candidate');
    expect(controller.currentObservationUnknown, false);
    expect(
      (await controller.action('preview'))['error'],
      'meaning_status_required',
    );
  });

  test(
    'synthetic missing reconciliation retries only status before Undo',
    () async {
      final calls = <String>[];
      var statusCalls = 0;
      final controller =
          MeaningExperimentController(
              invoke: (action, _) async {
                calls.add(action);
                if (action == 'apply') {
                  throw StateError('post-effect transport lost');
                }
                if (action == 'status') {
                  statusCalls++;
                  if (statusCalls < 3) {
                    throw StateError('status transport lost');
                  }
                  return {
                    'ok': true,
                    'issued_previews': [
                      {
                        'proposal': {'proposalId': 'p'},
                        'invoked': true,
                      },
                    ],
                    'receipts': [
                      {'action': 'apply', 'proposalId': 'p', 'runId': 'r'},
                    ],
                    'native_runs': [
                      {
                        'proposalId': 'p',
                        'runId': 'r',
                        'known_in_session': true,
                        'status': 'applied',
                      },
                    ],
                  };
                }
                expect(action, 'rollback');
                return {'ok': true, 'observation': 'fresh baseline'};
              },
            )
            ..proposalId = 'p'
            ..currentObservation = 'prior baseline';
      addTearDown(controller.dispose);
      final failed = await controller.action('apply');
      expect(failed['error'], 'meaning_operation_unavailable');
      expect(calls, ['apply', 'status']);
      expect(controller.receipts.first, failed);
      expect(
        controller.receipts.last['error'],
        'meaning_reconciliation_unavailable',
      );
      expect(controller.currentObservationUnknown, true);
      expect(controller.currentObservation, isNull);
      expect(
        (await controller.action('preview'))['error'],
        'meaning_status_required',
      );
      expect(calls, ['apply', 'status', 'status']);
      expect(controller.currentObservation, isNull);
      expect((await controller.action('rollback'))['ok'], true);
      expect(calls, ['apply', 'status', 'status', 'status', 'rollback']);
      expect(controller.currentObservation, 'fresh baseline');
      expect(controller.currentObservationUnknown, false);
      expect(
        (await controller.action('finalize'))['error'],
        'meaning_recovery_unavailable',
      );
      expect(calls, ['apply', 'status', 'status', 'status', 'rollback']);
    },
  );

  test(
    'synthetic rejection internally reconciles before next user Preview',
    () async {
      final calls = <String>[];
      final controller =
          MeaningExperimentController(
              invoke: (action, _) async {
                calls.add(action);
                if (action == 'apply') {
                  return {'ok': false, 'error': 'native_consent_denied'};
                }
                if (action == 'status') {
                  return {
                    'ok': true,
                    'issued_previews': [
                      {
                        'proposal': {'proposalId': 'p'},
                        'invoked': true,
                      },
                    ],
                    'native_runs': [
                      {
                        'runId': 'r',
                        'known_in_session': true,
                        'status': 'rolledBack',
                      },
                    ],
                  };
                }
                expect(action, 'ground');
                return {'ok': false, 'error': 'synthetic_ground_stop'};
              },
            )
            ..proposalId = 'p'
            ..currentObservation = 'baseline';
      addTearDown(controller.dispose);
      final failed = await controller.action('apply');
      expect(failed['error'], 'native_consent_denied');
      expect(controller.refusal, 'native_consent_denied');
      expect(controller.receipts.first, failed);
      expect(controller.receipts.last['action'], 'status');
      expect(controller.currentObservationUnknown, true);
      expect(controller.currentObservation, isNull);
      expect(calls, ['apply', 'status']);
      expect(
        (await controller.action('preview'))['error'],
        'synthetic_ground_stop',
      );
      expect(calls, ['apply', 'status', 'ground']);
    },
  );

  test(
    'disposing a pending display does not replay or emit after disposal',
    () async {
      final pending = Completer<Map<String, Object?>>();
      var calls = 0;
      final controller = MeaningExperimentController(
        invoke: (_, _) {
          calls++;
          return pending.future;
        },
      );
      final operation = controller.action('status');
      controller.dispose();
      pending.complete({'ok': false, 'error': 'meaning_session_unavailable'});
      expect((await operation)['error'], 'meaning_session_unavailable');
      expect(calls, 1);
      expect(
        (await controller.action('status'))['error'],
        'meaning_session_unavailable',
      );
      expect(calls, 1);
    },
  );
}
