import 'dart:convert';
import 'dart:io';

import 'package:dart_acp_toolkit/dart_acp_toolkit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/harness_host.dart';
import 'package:lastanswer/coding_agent/product_workspace_tooling.dart';
import 'package:xsoulspace_agentic_harness/xsoulspace_agentic_harness.dart';
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';

void main() {
  test('ordinary product read reconstructs omitted source beyond64K', () async {
    final root = await Directory.systemTemp.createTemp('receipt_native_');
    final workspace = await Directory('${root.path}/project').create();
    File('${workspace.path}/main.dart').writeAsStringSync('void main() {}');
    final source = '// ${'é😀' * 30000}\nvoid large() {}\n';
    File('${workspace.path}/large.dart').writeAsStringSync(source);
    final tooling = ProductWorkspaceTooling(supportDirectory: () async => root);
    final binding = await tooling.prepare(workspace.path);
    final host = HarnessHost(
      config: HarnessHostConfig(
        meaningProfile: true,
        extraToolsWithContext: binding.tools,
      ),
    );
    addTearDown(() async {
      await host.stop();
      await root.delete(recursive: true);
    });
    await host.start();
    final session = await host.newSession(workspace.path);
    final read = await host.conventionalAction(session, 'read', {
      'paths': ['large.dart'],
    });
    expect(read['ok'], true, reason: '${read['error']}: ${read['detail']}');
    expect((read['files']! as Map)['large.dart'], source);
    final receipt = read['receipt']! as Map;
    expect(receipt['outputOmitted'], true);
    expect(receipt['outputBytes'], greaterThan(65536));
    expect(File('${workspace.path}/large.dart').readAsStringSync(), source);
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('native HarnessAgentTools pages authenticate the result '
      'and deny private reads', () async {
    final root = await Directory.systemTemp.createTemp('receipt_context_');
    final backend = HarnessAcpBackend(scripted: true)
      ..attachMoveProposer((_) async => fail('inference was requested'));
    final doc = await backend.createSession(
      AcpSessionNewRequest(cwd: root.path),
    );
    addTearDown(() async {
      await backend.disposeSession(doc);
      await root.delete(recursive: true);
    });
    final tools = HarnessAgentTools(backend: backend);
    for (final actor in ['owner', 'other']) {
      expect(
        (await tools.context({
          'op': 'join',
          'docId': doc,
          'actor': actor,
          'thread': '$actor-thread',
          'task': 'Read exact result',
        }))['ok'],
        true,
      );
    }
    final append = await tools.context({
      'op': 'append',
      'docId': doc,
      'actor': 'owner',
      'thread': 'owner-thread',
      'requestId': 'result',
      'text': 'indexed display',
    });
    expect(append['ok'], true);
    final beat = append['beat']! as String;
    final output = jsonEncode({'ok': true, 'value': 'é😀' * 40000});
    await backend.withWorldContext(
      doc,
      mutation: true,
      operation: (world) {
        final entity = resolveContextBeat(world, beat)!;
        world.upsertComponent(
          entity,
          ToolResultContent(name: 'read', output: output),
        );
        final owner = world
            .query<Actor>()
            .firstWhere((row) => row.$2.agentId == const AgentId('owner'))
            .$1
            .entity;
        world
          ..upsertComponent(entity, PrivateToActor(owner))
          ..flush();
      },
    );
    final receipt = <String, Object?>{
      'ok': true,
      'outputOmitted': true,
      'resultBeat': beat,
      'outputBytes': utf8.encode(output).length,
    };
    Future<Map<String, Object?>> readAs(String actor) => readHarnessToolReceipt(
      receipt: receipt,
      toolName: 'read',
      readContext: (page) =>
          tools.context({'docId': doc, 'actor': actor, ...page}),
    );
    final denied = await readAs('other');
    expect(denied['ok'], false);
    // Host preflight preserves its named visibility bounce before engine read.
    expect(denied['bounce'], 'beat_not_visible');
    expect(denied.containsKey('text'), false);
    final read = await readAs('owner');
    expect(read['ok'], true, reason: '${read['error']}: ${read['detail']}');
    expect(read['value'], 'é😀' * 40000);
  }, timeout: const Timeout(Duration(minutes: 2)));

  test(
    'pages join split surrogates before byte check and JSON decoding',
    () async {
      const header = '{"ok":true,"value":"';
      final value = '${'x' * (32767 - header.length)}😀${'é' * 40000}';
      final output = jsonEncode({'ok': true, 'value': value});
      expect(output.codeUnitAt(32767), 0xd83d);
      final read = await readHarnessToolReceipt(
        receipt: receiptFor(output),
        toolName: 'read',
        readContext: (args) async => pageFor(output, args['offset']! as int),
      );
      expect(read['value'], value);
    },
  );

  for (final failure in <String, void Function(Map<String, Object?>)>{
    'result_beat_mismatch': (p) => p['beatId'] = 'another',
    'tool_name_mismatch': (p) => p['toolName'] = 'another',
    'field_mismatch': (p) => p['field'] = 'text',
    'offset_unit_mismatch': (p) => p['offsetUnit'] = 'bytes',
    'offset_mismatch': (p) => p['offset'] = 1,
    'next_offset_invalid': (p) => p['nextOffset'] = 0,
    'terminal_incomplete': (p) => p['truncated'] = false,
  }.entries) {
    test('rejects ${failure.key} without requesting another page', () async {
      final output = jsonEncode({'ok': true, 'value': 'x' * 70000});
      var calls = 0;
      final read = await readHarnessToolReceipt(
        receipt: receiptFor(output),
        toolName: 'read',
        readContext: (args) async {
          calls++;
          final page = pageFor(output, args['offset']! as int);
          failure.value(page);
          return page;
        },
      );
      expect(read['error'], 'meaning_receipt_page_invalid');
      expect(read['detail'], failure.key);
      expect(calls, 1);
    });
  }

  test(
    'rejects changed total, corrupt byte count and invalid complete JSON',
    () async {
      final output = jsonEncode({'ok': true, 'value': 'x' * 70000});
      final changed = await readHarnessToolReceipt(
        receipt: receiptFor(output),
        toolName: 'read',
        readContext: (args) async {
          final page = pageFor(output, args['offset']! as int);
          if (args['offset'] != 0) page['totalLength'] = output.length + 1;
          return page;
        },
      );
      expect(changed['detail'], 'total_length_changed');
      final corrupt = await readHarnessToolReceipt(
        receipt: {...receiptFor(output), 'outputBytes': 1},
        toolName: 'read',
        readContext: (args) async => pageFor(output, args['offset']! as int),
      );
      expect(corrupt['detail'], 'output_bytes_mismatch');
      final invalid = await readHarnessToolReceipt(
        receipt: receiptFor('not JSON'),
        toolName: 'read',
        readContext: (args) async =>
            pageFor('not JSON', args['offset']! as int),
      );
      expect(invalid['detail'], 'json_invalid');
    },
  );

  test('inline receipt stays inline and never requests pages', () async {
    final read = await readHarnessToolReceipt(
      receipt: {'ok': true, 'output': '{"ok":true,"value":"inline"}'},
      toolName: 'read',
      readContext: (_) async => fail('unexpected page'),
    );
    expect(read['value'], 'inline');
  });
}

Map<String, Object?> receiptFor(String output) => {
  'ok': true,
  'outputOmitted': true,
  'resultBeat': 'exact-result',
  'outputBytes': utf8.encode(output).length,
};

Map<String, Object?> pageFor(String output, int offset) {
  final end = (offset + 32768).clamp(0, output.length);
  return {
    'ok': true,
    'beatId': 'exact-result',
    'field': 'tool_output',
    'toolName': 'read',
    'offsetUnit': 'utf16_code_units',
    'offset': offset,
    'totalLength': output.length,
    'text': output.substring(offset, end),
    'truncated': end < output.length,
    if (end < output.length) 'nextOffset': end,
  };
}
