import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/settings/features/supervisor_agent_client.dart';

void main() {
  group('HarnessWorldAgentClient', () {
    test('the delegation receipt is an admission, not a completion', () async {
      final calls = <String>[];
      final client = HarnessWorldAgentClient(
        call: (tool, args) async {
          calls.add('$tool:${args['op']}');
          return {
            'ok': true,
            'taskId': 'delegation:actor:req-1',
            'admissionBeatId': 'task-delegation:actor:req-1',
            'state': 'queued',
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
      expect(admission.taskId, 'delegation:actor:req-1');
      expect(admission.admissionBeatId, 'task-delegation:actor:req-1');
      expect(calls, ['agent_participation:task_delegate']);
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
            'task_delegate_receipt_incomplete',
          ),
        ),
      );
    });

    test("the world's refusal code is carried verbatim", () async {
      final client = HarnessWorldAgentClient(
        call: (tool, args) async => {
          'ok': false,
          'bounce': 'task_delegation_not_authorized',
        },
      );
      await expectLater(
        client.admit(task: 'x', requestId: 'req-1'),
        throwsA(
          isA<SupervisorAgentRefusal>().having(
            (r) => r.code,
            'code',
            'task_delegation_not_authorized',
          ),
        ),
      );
    });

    test('a verb outside the seat catalog is refused by name', () async {
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
              .having((r) => r.detail, 'detail', 'agent_participation'),
        ),
      );
      expect(called, isFalse);
    });

    test('the durable state is read page by page and joined', () async {
      final state = jsonEncode({
        'state': 'loop_settled',
        'goalAcceptance': {
          'status': 'verified',
          'goalCompletionVerified': true,
        },
      });
      final reads = <Map<String, Object?>>[];
      final client = HarnessWorldAgentClient(
        pageLimit: 8,
        call: (tool, args) async {
          if (tool == 'agent_participation') {
            return {
              'ok': true,
              'taskId': 'delegation:actor:req-1',
              'admissionBeatId': 'beat-1',
              'state': 'queued',
            };
          }
          reads.add(args);
          final offset = args['offset']! as int;
          final end = (offset + 8).clamp(0, state.length);
          final truncated = end < state.length;
          return {
            'ok': true,
            'beatId': 'beat-1',
            'field': 'tool_output',
            'offsetUnit': 'utf16_code_units',
            'offset': offset,
            'totalLength': state.length,
            'text': state.substring(offset, end),
            'truncated': truncated,
            if (truncated) 'nextOffset': end,
          };
        },
      );

      final admission = await client.admit(task: 'x', requestId: 'req-1');
      final outcome = await client.outcome(admission: admission);

      expect(reads.length, greaterThan(1));
      expect(reads.first['op'], 'read');
      expect(reads.first['field'], 'tool_output');
      expect(outcome.terminal, isTrue);
      expect(outcome.succeeded, isTrue);
      expect(outcome.state, 'loop_settled');
    });

    test('a settled-but-unverified delegation is not a success', () async {
      final client = HarnessWorldAgentClient(
        call: (tool, args) async {
          if (tool == 'agent_participation') {
            return {
              'ok': true,
              'taskId': 'delegation:actor:req-1',
              'admissionBeatId': 'beat-1',
              'state': 'queued',
            };
          }
          final state = jsonEncode({
            'state': 'loop_settled',
            'goalAcceptance': {'status': 'failed'},
            'failureClass': 'check_failed',
            'failureDetail': 'the check did not pass',
          });
          return {
            'ok': true,
            'beatId': 'beat-1',
            'field': 'tool_output',
            'offsetUnit': 'utf16_code_units',
            'offset': 0,
            'totalLength': state.length,
            'text': state,
            'truncated': false,
          };
        },
      );

      final admission = await client.admit(task: 'x', requestId: 'req-1');
      final outcome = await client.outcome(admission: admission);

      expect(outcome.terminal, isTrue);
      expect(outcome.succeeded, isFalse);
      expect(outcome.failure, contains('check_failed'));
    });

    test('a cancelled delegation is terminal and not a success', () async {
      final client = HarnessWorldAgentClient(
        call: (tool, args) async {
          if (tool == 'agent_participation') {
            return {
              'ok': true,
              'taskId': 'delegation:actor:req-1',
              'admissionBeatId': 'beat-1',
              'state': 'queued',
            };
          }
          final state = jsonEncode({'state': 'cancelled'});
          return {
            'ok': true,
            'beatId': 'beat-1',
            'field': 'tool_output',
            'offsetUnit': 'utf16_code_units',
            'offset': 0,
            'totalLength': state.length,
            'text': state,
            'truncated': false,
          };
        },
      );

      final admission = await client.admit(task: 'x', requestId: 'req-1');
      final outcome = await client.outcome(admission: admission);

      expect(outcome.terminal, isTrue);
      expect(outcome.cancelled, isTrue);
      expect(outcome.succeeded, isFalse);
    });

    test('an unreadable delegation state is refused, never assumed', () async {
      final client = HarnessWorldAgentClient(
        call: (tool, args) async {
          if (tool == 'agent_participation') {
            return {
              'ok': true,
              'taskId': 'delegation:actor:req-1',
              'admissionBeatId': 'beat-1',
              'state': 'queued',
            };
          }
          return {'ok': false, 'bounce': 'thread_not_visible'};
        },
      );

      final admission = await client.admit(task: 'x', requestId: 'req-1');
      await expectLater(
        client.outcome(admission: admission),
        throwsA(
          isA<SupervisorAgentRefusal>().having(
            (r) => r.code,
            'code',
            'thread_not_visible',
          ),
        ),
      );
    });

    test('a read that answers another field is refused, not assumed', () async {
      final client = HarnessWorldAgentClient(
        call: (tool, args) async {
          if (tool == 'agent_participation') {
            return {
              'ok': true,
              'taskId': 'delegation:actor:req-1',
              'admissionBeatId': 'beat-1',
              'state': 'queued',
            };
          }
          return {
            'ok': true,
            'beatId': 'beat-1',
            'field': 'text',
            'offsetUnit': 'utf16_code_units',
            'offset': 0,
            'totalLength': 2,
            'text': '{}',
            'truncated': false,
          };
        },
      );

      final admission = await client.admit(task: 'x', requestId: 'req-1');
      await expectLater(
        client.outcome(admission: admission),
        throwsA(
          isA<SupervisorAgentRefusal>().having(
            (r) => r.code,
            'code',
            'delegation_state_field_mismatch',
          ),
        ),
      );
    });

    test('a read in another offset unit is refused, not assumed', () async {
      final client = HarnessWorldAgentClient(
        call: (tool, args) async {
          if (tool == 'agent_participation') {
            return {
              'ok': true,
              'taskId': 'delegation:actor:req-1',
              'admissionBeatId': 'beat-1',
              'state': 'queued',
            };
          }
          return {
            'ok': true,
            'beatId': 'beat-1',
            'field': 'tool_output',
            'offsetUnit': 'utf8_bytes',
            'offset': 0,
            'totalLength': 2,
            'text': '{}',
            'truncated': false,
          };
        },
      );

      final admission = await client.admit(task: 'x', requestId: 'req-1');
      await expectLater(
        client.outcome(admission: admission),
        throwsA(
          isA<SupervisorAgentRefusal>().having(
            (r) => r.code,
            'code',
            'delegation_state_offset_unit',
          ),
        ),
      );
    });

    test('the read page never exceeds the world page ceiling', () async {
      final limits = <int>[];
      final client = HarnessWorldAgentClient(
        pageLimit: 999999,
        call: (tool, args) async {
          if (tool == 'agent_participation') {
            return {
              'ok': true,
              'taskId': 'delegation:actor:req-1',
              'admissionBeatId': 'beat-1',
              'state': 'queued',
            };
          }
          limits.add(args['limit']! as int);
          return {
            'ok': true,
            'beatId': 'beat-1',
            'field': 'tool_output',
            'offsetUnit': 'utf16_code_units',
            'offset': 0,
            'totalLength': 2,
            'text': '{}',
            'truncated': false,
          };
        },
      );

      final admission = await client.admit(task: 'x', requestId: 'req-1');
      await client.outcome(admission: admission);

      expect(limits, [64000]);
    });

    test('a cancellation is a world call, and a refusal is data', () async {
      final ops = <String>[];
      final client = HarnessWorldAgentClient(
        call: (tool, args) async {
          ops.add('${args['op']}');
          if (args['op'] == 'task_cancel') {
            return {'ok': false, 'bounce': 'task_not_cancellable'};
          }
          return {
            'ok': true,
            'taskId': 'delegation:actor:req-1',
            'admissionBeatId': 'beat-1',
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
      expect(ops, ['task_delegate', 'task_cancel']);
    });
  });
}
