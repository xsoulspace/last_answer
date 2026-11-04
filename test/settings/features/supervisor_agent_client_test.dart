import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/settings/features/supervisor_agent_client.dart';

void main() {
  group('HarnessWorldAgentClient', () {
    test('the creation receipt is an admission, not a completion', () async {
      final calls = <String>[];
      final client = HarnessWorldAgentClient(
        call: (tool, args) async {
          calls.add('$tool:${args['op']}');
          return {
            'ok': true,
            'durable': true,
            'taskId': 'task-1a2b3c4d5e6f7a8b9c0d',
            'requestId': 'req-1',
            'state': 'queued',
            'admissionBeatId': 'control:task:task-1a2b3c4d5e6f7a8b9c0d',
          };
        },
      );

      final admission = await client.admit(
        task: 'Summarize the day',
        requestId: 'req-1',
      );

      // The world said "queued" — the client reports exactly that and
      // claims nothing about completion.
      expect(admission.state, 'queued');
      expect(admission.taskId, 'task-1a2b3c4d5e6f7a8b9c0d');
      expect(
        admission.admissionBeatId,
        'control:task:task-1a2b3c4d5e6f7a8b9c0d',
      );
      expect(calls, ['task:create']);
    });

    test('admission carries the task text and purpose verbatim', () async {
      Object? sent;
      final client = HarnessWorldAgentClient(
        call: (tool, args) async {
          sent = args;
          return {
            'ok': true,
            'taskId': 'task-x',
            'admissionBeatId': 'control:task:task-x',
            'state': 'queued',
          };
        },
      );

      await client.admit(task: 'Do the thing', requestId: 'req-9');

      expect(sent, isA<Map>().having(
        (m) => m,
        'args',
        containsPair('task', 'Do the thing'),
      ));
    });

    test('an incomplete receipt is refused, never completed', () async {
      final client = HarnessWorldAgentClient(
        call: (tool, args) async => {'ok': true, 'state': 'queued'},
      );
      await expectLater(
        client.admit(task: 'x', requestId: 'req-1'),
        throwsA(
          isA<SupervisorAgentRefusal>().having(
            (r) => r.code,
            'code',
            'task_create_receipt_incomplete',
          ),
        ),
      );
    });

    test("the world's refusal code is carried verbatim", () async {
      final client = HarnessWorldAgentClient(
        call: (tool, args) async => {
          'ok': false,
          'bounce': 'delegation_verification_unbound',
        },
      );
      await expectLater(
        client.admit(task: 'x', requestId: 'req-1'),
        throwsA(
          isA<SupervisorAgentRefusal>().having(
            (r) => r.code,
            'code',
            'delegation_verification_unbound',
          ),
        ),
      );
    });

    test('a tool outside the seat catalog is refused by name', () async {
      var called = false;
      final client = HarnessWorldAgentClient(
        allowedTools: const {'agent_context'},
        call: (tool, args) async {
          called = true;
          return {'ok': true};
        },
      );
      await expectLater(
        client.admit(task: 'x', requestId: 'req-1'),
        throwsA(
          isA<SupervisorAgentRefusal>()
              .having((r) => r.code, 'code', 'seat_tool_unavailable')
              .having((r) => r.detail, 'detail', 'task'),
        ),
      );
      expect(called, isFalse);
    });

    test('an open task is not terminal', () async {
      final client = HarnessWorldAgentClient(
        call: (tool, args) async {
          if (args['op'] == 'create') {
            return {
              'ok': true,
              'taskId': 'task-x',
              'admissionBeatId': 'control:task:task-x',
              'state': 'queued',
            };
          }
          return {'ok': true, 'taskId': 'task-x', 'state': 'started'};
        },
      );

      final admission = await client.admit(task: 'x', requestId: 'req-1');
      final outcome = await client.outcome(admission: admission);

      expect(outcome.terminal, isFalse);
      expect(outcome.succeeded, isFalse);
      expect(outcome.state, 'started');
    });

    test('a settled, verified task is terminal success', () async {
      final client = HarnessWorldAgentClient(
        call: (tool, args) async {
          if (args['op'] == 'create') {
            return {
              'ok': true,
              'taskId': 'task-x',
              'admissionBeatId': 'control:task:task-x',
              'state': 'queued',
            };
          }
          return {
            'ok': true,
            'taskId': 'task-x',
            'state': 'succeeded',
            'terminal': {
              'state': 'succeeded',
              'model': 'openrouter_deepseek',
              'at': '2026-11-04T10:00:00.000Z',
              'result': {'summary': 'the analysis is written'},
              'resultHandle': 'control:result:task-x',
            },
          };
        },
      );

      final admission = await client.admit(task: 'x', requestId: 'req-1');
      final outcome = await client.outcome(admission: admission);

      expect(outcome.terminal, isTrue);
      expect(outcome.succeeded, isTrue);
      expect(outcome.cancelled, isFalse);
      expect(outcome.failure, isNull);
      expect(outcome.detail, 'the analysis is written');
    });

    test('a failed settlement carries the world reason, never success',
        () async {
      final client = HarnessWorldAgentClient(
        call: (tool, args) async {
          if (args['op'] == 'create') {
            return {
              'ok': true,
              'taskId': 'task-x',
              'admissionBeatId': 'control:task:task-x',
              'state': 'queued',
            };
          }
          return {
            'ok': true,
            'taskId': 'task-x',
            'state': 'failed',
            'terminal': {
              'state': 'failed',
              'reason': 'check_failed: the check did not pass',
              'resultHandle': 'control:result:task-x',
            },
          };
        },
      );

      final admission = await client.admit(task: 'x', requestId: 'req-1');
      final outcome = await client.outcome(admission: admission);

      expect(outcome.terminal, isTrue);
      expect(outcome.succeeded, isFalse);
      expect(outcome.failure, contains('check_failed'));
      expect(outcome.detail, contains('the check did not pass'));
    });

    test('a cancelled task is terminal and not a success', () async {
      final client = HarnessWorldAgentClient(
        call: (tool, args) async {
          if (args['op'] == 'create') {
            return {
              'ok': true,
              'taskId': 'task-x',
              'admissionBeatId': 'control:task:task-x',
              'state': 'queued',
            };
          }
          return {
            'ok': true,
            'taskId': 'task-x',
            'state': 'cancelled',
            'terminal': {
              'state': 'cancelled',
              'reason': 'requester_cancelled',
              'resultHandle': 'control:result:task-x',
            },
          };
        },
      );

      final admission = await client.admit(task: 'x', requestId: 'req-1');
      final outcome = await client.outcome(admission: admission);

      expect(outcome.terminal, isTrue);
      expect(outcome.cancelled, isTrue);
      expect(outcome.succeeded, isFalse);
    });

    test('an unknown settlement is terminal and never a success', () async {
      final client = HarnessWorldAgentClient(
        call: (tool, args) async {
          if (args['op'] == 'create') {
            return {
              'ok': true,
              'taskId': 'task-x',
              'admissionBeatId': 'control:task:task-x',
              'state': 'queued',
            };
          }
          return {'ok': true, 'taskId': 'task-x', 'state': 'unknown'};
        },
      );

      final admission = await client.admit(task: 'x', requestId: 'req-1');
      final outcome = await client.outcome(admission: admission);

      expect(outcome.terminal, isTrue);
      expect(outcome.succeeded, isFalse);
      expect(outcome.failure, 'outcome_unknown');
    });

    test('an unreadable task record is refused, never assumed', () async {
      final client = HarnessWorldAgentClient(
        call: (tool, args) async {
          if (args['op'] == 'create') {
            return {
              'ok': true,
              'taskId': 'task-x',
              'admissionBeatId': 'control:task:task-x',
              'state': 'queued',
            };
          }
          return {'ok': false, 'bounce': 'task_not_visible'};
        },
      );

      final admission = await client.admit(task: 'x', requestId: 'req-1');
      await expectLater(
        client.outcome(admission: admission),
        throwsA(
          isA<SupervisorAgentRefusal>().having(
            (r) => r.code,
            'code',
            'task_not_visible',
          ),
        ),
      );
    });

    test('a cancellation is a world call, and a refusal is data', () async {
      final ops = <String>[];
      final client = HarnessWorldAgentClient(
        call: (tool, args) async {
          ops.add('${args['op']}');
          if (args['op'] == 'cancel') {
            return {'ok': false, 'bounce': 'task_not_cancellable'};
          }
          return {
            'ok': true,
            'taskId': 'task-x',
            'admissionBeatId': 'control:task:task-x',
            'state': 'queued',
          };
        },
      );

      final admission = await client.admit(task: 'x', requestId: 'req-1');
      await expectLater(
        client.cancel(admission: admission, requestId: 'cancel-1'),
        throwsA(
          isA<SupervisorAgentRefusal>().having(
            (r) => r.code,
            'code',
            'task_not_cancellable',
          ),
        ),
      );
      expect(ops, ['create', 'cancel']);
    });

    test('a confirmed cancellation joins the settled record', () async {
      final ops = <String>[];
      final client = HarnessWorldAgentClient(
        call: (tool, args) async {
          ops.add('${args['op']}');
          switch (args['op']) {
            case 'cancel':
              return {
                'ok': true,
                'taskId': 'task-x',
                'state': 'cancelled',
                'cancelRequested': true,
              };
            case 'show':
              return {
                'ok': true,
                'taskId': 'task-x',
                'state': 'cancelled',
                'terminal': {
                  'state': 'cancelled',
                  'reason': 'requester_cancelled',
                  'resultHandle': 'control:result:task-x',
                },
              };
            default:
              return {
                'ok': true,
                'taskId': 'task-x',
                'admissionBeatId': 'control:task:task-x',
                'state': 'queued',
              };
          }
        },
      );

      final admission = await client.admit(task: 'x', requestId: 'req-1');
      final outcome = await client.cancel(
        admission: admission,
        requestId: 'cancel-1',
      );

      expect(ops, ['create', 'cancel', 'show']);
      expect(outcome.terminal, isTrue);
      expect(outcome.cancelled, isTrue);
    });
  });
}
