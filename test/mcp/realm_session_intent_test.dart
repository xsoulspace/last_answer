/// ADR 0145 — the `realm_chat_open_session` debug intent, pinned at the
/// handler level (the realm_work_intents_test.dart pattern): the REAL
/// entry over a hermetic [RealmChatService]. The result shape is the
/// contract wave 2b's smokes consume — `{ok, threadId, kind}` — and
/// the journal row is the oracle: declared kind, realm seal, trimmed
/// label, normalized members. The honest refusals name themselves.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/journal/actor_roster.dart';
import 'package:lastanswer/chat/realm_chat_mcp_tools.dart';
import 'package:lastanswer/journal/realm_chat_service.dart';
import 'package:lastanswer/journal/realm_world.dart';
import 'package:mcp_toolkit/mcp_toolkit.dart';

AgentCallEntry _entry(final String name) =>
    realmChatMcpEntries().firstWhere((final e) => e.name == name);

// The legacy mcpToolkitTool bridge wraps every MCPCallResult as
// AgentResult.success — the REAL ok flag is carried in data.
bool _okOf(final AgentResult result) => result.data['ok'] == true;

void main() {
  test('with no live service the intent refuses honestly', () async {
    expect(RealmChatService.debugInstances, isEmpty);
    final result = await _entry(
      'realm_chat_open_session',
    ).invokeDirect(const {'label': 'smoke'});
    expect(_okOf(result), isFalse);
    expect(result.data['error'], 'no_service');
    expect(result.message, contains('no_service'));
  });

  test('realm_chat_open_session opens the declared session, returns the '
      'thread id and selects it', () async {
    final temp = await Directory.systemTemp.createTemp('la_session_int_');
    final world = await RealmWorld.open(rootOverride: temp.path);
    if (world == null) {
      await temp.delete(recursive: true);
      fail('realm world unsupported on this platform');
    }
    final service = RealmChatService(
      debugWorldOverride: world,
      debugRosterOverride: ActorRoster(replicaId: 'tester'),
      debugStartBotDispatcher: false,
    );
    addTearDown(() async {
      service.dispose();
      await temp.delete(recursive: true);
    });
    await service.ensureReady();
    expect(service.isReady, isTrue, reason: service.error);
    final ada = (await service.createActor(
      displayName: 'Ada',
      kind: ActorKind.model,
      brainRef: '',
    ))!;

    final result = await _entry('realm_chat_open_session').invokeDirect({
      'label': '  smoke-run-42  ',
      'members': '${ada.actorId}, ghost-x',
    });
    expect(_okOf(result), isTrue, reason: result.message);
    final threadId = result.data['threadId']! as String;
    expect(threadId, isNotEmpty);
    expect(result.data['kind'], 'session');
    expect(service.activeThreadId, threadId);

    // The journal row is the oracle: DECLARED kind, realm seal, the
    // trimmed label, the human plus the invited members.
    final row = await world.store.read('threads', threadId);
    expect(row?['kind'], 'session');
    expect(row?['projectId'], isNull, reason: 'realm-sealed, no sandbox');
    expect(row?['topic'], 'smoke-run-42');
    final participants = (row?['participants'] as List? ?? const <Object?>[])
        .cast<String>();
    expect(participants, contains(service.humanActorId));
    expect(participants, contains(ada.actorId));
    expect(participants, contains('ghost-x'));
  });

  test('the empty label refuses at the intent (missing_parameters) '
      'before any thread opens', () async {
    final temp = await Directory.systemTemp.createTemp('la_session_int_e_');
    final world = await RealmWorld.open(rootOverride: temp.path);
    if (world == null) {
      await temp.delete(recursive: true);
      fail('realm world unsupported on this platform');
    }
    final service = RealmChatService(
      debugWorldOverride: world,
      debugRosterOverride: ActorRoster(replicaId: 'tester'),
      debugStartBotDispatcher: false,
    );
    addTearDown(() async {
      service.dispose();
      await temp.delete(recursive: true);
    });
    await service.ensureReady();
    final before = service.threads.length;

    final refused = await _entry(
      'realm_chat_open_session',
    ).invokeDirect(const {'label': '   '});
    expect(_okOf(refused), isFalse);
    expect(refused.data['error'], 'missing_parameters');
    expect(service.threads.length, before, reason: 'nothing opened');
  });
}
