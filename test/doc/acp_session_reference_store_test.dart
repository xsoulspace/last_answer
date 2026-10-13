import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/agent_config/agent_config_persistence.dart';
import 'package:lastanswer/agent_config/agent_config_persistence_io.dart';
import 'package:lastanswer/doc/acp_session_reference_store.dart';
import 'package:xsoulspace_inference_acp/xsoulspace_inference_acp.dart';

final class _Memory implements AgentConfigPersistence {
  String? value;
  bool failWrite = false;
  bool failAfterWrite = false;
  int writes = 0;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String contents) async {
    if (failWrite) throw StateError('simulated atomic write failure');
    writes++;
    value = contents;
    if (failAfterWrite) {
      failAfterWrite = false;
      throw StateError('simulated lost write response');
    }
  }
}

AcpSessionBinding scope(String conversation, {String provider = 'provider'}) =>
    AcpSessionBinding(
      conversationKey: conversation,
      workingDirectory: '/candidate',
      providerIdentity: provider,
      descriptorRevision: 'native-descriptors',
    );

AcpSessionBinding nextScope({
  String conversation = 'one',
  String cwd = '/candidate',
  String provider = 'provider',
  String revision = 'native-descriptors-2',
}) => AcpSessionBinding(
  conversationKey: conversation,
  workingDirectory: cwd,
  providerIdentity: provider,
  descriptorRevision: revision,
);

final class _NativePolicy {
  final Object ticket = Object();
  bool enabled = true;
  bool commitAllowed = true;
  bool throwCommit = false;
  int stages = 0;
  int commits = 0;
  Future<void> Function()? onCommit;

  AcpSessionRebindPort get port => AcpSessionRebindPort(
    stage: (_, _) async {
      stages++;
      return enabled ? ticket : null;
    },
    authorize: (issued, _, _) async => enabled && identical(issued, ticket),
    commit: (issued, _, _) async {
      commits++;
      if (throwCommit) throw StateError('native refusal');
      await onCommit?.call();
      return enabled && commitAllowed && identical(issued, ticket);
    },
  );
}

AcpSessionPersistence adapter(
  AcpSessionReferenceStore store,
  _NativePolicy owner,
) => store.bind(authorize: (_, _) async => false, rebind: owner.port);

void main() {
  test(
    'existing file adapter replaces cursor without altering settings',
    () async {
      final root = await Directory.systemTemp.createTemp('acp_cursor_');
      addTearDown(() => root.delete(recursive: true));
      final settings = File('${root.path}/agent_config.json')
        ..writeAsStringSync('{"settings":true}');
      final storage = FileAgentConfigPersistence(
        filePath: '${root.path}/agent_sessions.json',
        documentName: 'agent_sessions.json',
      );
      final store = AcpSessionReferenceStore(persistence: storage);
      final reference = AcpSessionReference(
        binding: scope('one'),
        sessionId: 'old',
      );
      await store.save(reference);
      await store.save(reference);
      final reopened = AcpSessionReferenceStore(persistence: storage);
      expect((await reopened.read(scope('one')))!.sessionId, 'old');
      expect(await settings.readAsString(), '{"settings":true}');
      expect(root.listSync().whereType<Directory>(), isEmpty);
    },
  );
  test(
    'reopen retains exact identity and concurrent saves preserve both',
    () async {
      final storage = _Memory();
      final store = AcpSessionReferenceStore(persistence: storage);
      await Future.wait([
        store.save(
          AcpSessionReference(binding: scope('one'), sessionId: 'remote-1'),
        ),
        store.save(
          AcpSessionReference(binding: scope('two'), sessionId: 'remote-2'),
        ),
      ]);
      final reopened = AcpSessionReferenceStore(persistence: storage);
      expect((await reopened.read(scope('one')))!.sessionId, 'remote-1');
      expect((await reopened.read(scope('two')))!.sessionId, 'remote-2');
      final changed = await reopened.read(scope('one', provider: 'changed'));
      expect(changed!.binding.providerIdentity, 'provider');
      expect(changed.binding.matches(scope('one', provider: 'changed')), false);
    },
  );
  test(
    'conflicting cursor refuses and preserves acknowledged session',
    () async {
      final store = AcpSessionReferenceStore(persistence: _Memory());
      await store.save(
        AcpSessionReference(binding: scope('one'), sessionId: 'old'),
      );
      await expectLater(
        store.save(
          AcpSessionReference(binding: scope('one'), sessionId: 'new'),
        ),
        throwsA(isA<AcpSessionPersistenceRefusal>()),
      );
      expect((await store.read(scope('one')))!.sessionId, 'old');
    },
  );
  test('corrupt document is a refusal, never an absent conversation', () async {
    final storage = _Memory()..value = '{broken';
    final store = AcpSessionReferenceStore(persistence: storage);
    await expectLater(
      store.read(scope('one')),
      throwsA(isA<AcpSessionPersistenceRefusal>()),
    );
    await expectLater(
      store.save(AcpSessionReference(binding: scope('one'), sessionId: 'new')),
      throwsA(isA<AcpSessionPersistenceRefusal>()),
    );
    expect(storage.value, '{broken');
  });
  test(
    'staged descriptor change blocks ordinary saves and preserves old row',
    () async {
      final memory = _Memory();
      final store = AcpSessionReferenceStore(persistence: memory);
      final old = AcpSessionReference(
        binding: scope('one'),
        sessionId: 'remote',
      );
      await store.save(old);
      final owner = _NativePolicy();
      final port = adapter(store, owner).rebind!;
      final ticket = await port.stage(old, nextScope());
      expect(identical(ticket, owner.ticket), true);
      final encoded = jsonDecode(memory.value!) as Map;
      final pending =
          (encoded['pendingTransitions'] as Map).values.single as Map;
      expect(pending.keys.toSet(), {'previous', 'nextBinding'});
      expect(memory.value, isNot(contains('ticket')));
      expect(
        (await store.read(nextScope()))!.binding.matches(old.binding),
        true,
      );
      for (final reference in [
        old,
        AcpSessionReference(binding: nextScope(), sessionId: 'remote'),
        AcpSessionReference(binding: scope('one'), sessionId: 'fork'),
      ]) {
        await expectLater(
          store.save(reference),
          throwsA(isA<AcpSessionPersistenceRefusal>()),
        );
      }
      final writes = memory.writes;
      expect(await port.stage(old, nextScope()), same(ticket));
      expect(memory.writes, writes);
      expect(await port.stage(old, nextScope(revision: 'competing')), isNull);
      await store.save(
        AcpSessionReference(binding: scope('two'), sessionId: 'other'),
      );
      expect((await store.read(scope('two')))!.sessionId, 'other');
    },
  );

  test(
    'only exact conversation cwd provider descriptor rotation can stage',
    () async {
      final store = AcpSessionReferenceStore(persistence: _Memory());
      final old = AcpSessionReference(
        binding: scope('one'),
        sessionId: 'remote',
      );
      await store.save(old);
      final owner = _NativePolicy();
      final port = adapter(store, owner).rebind!;
      for (final changed in [
        nextScope(conversation: 'other'),
        nextScope(cwd: '/other'),
        nextScope(provider: 'other'),
        scope('one'),
      ]) {
        expect(await port.stage(old, changed), isNull);
      }
      expect(owner.stages, 0);
      expect(
        await port.stage(
          AcpSessionReference(binding: old.binding, sessionId: 'foreign'),
          nextScope(),
        ),
        isNull,
      );
      expect(owner.stages, 0);
    },
  );

  test(
    'exact acknowledged session commits CAS and exact repeat is idempotent',
    () async {
      final memory = _Memory();
      final store = AcpSessionReferenceStore(persistence: memory);
      final old = AcpSessionReference(
        binding: scope('one'),
        sessionId: 'remote',
      );
      await store.save(old);
      final owner = _NativePolicy();
      final port = adapter(store, owner).rebind!;
      final ticket = (await port.stage(old, nextScope()))!;
      final ack = AcpSessionReference(
        binding: nextScope(),
        sessionId: 'remote',
      );
      expect(await port.commit(ticket, old, ack), true);
      expect(
        (await store.read(nextScope()))!.binding.matches(ack.binding),
        true,
      );
      expect(
        (jsonDecode(memory.value!) as Map).containsKey('pendingTransitions'),
        false,
      );
      final writes = memory.writes;
      expect(await port.commit(ticket, old, ack), true);
      expect(memory.writes, writes);
      owner.enabled = false;
      expect(await port.commit(ticket, old, ack), false);
      expect(await port.authorize(ticket, old, nextScope()), false);
    },
  );

  test(
    'wrong or denied ACK retains pending without advancing cursor',
    () async {
      final memory = _Memory();
      final store = AcpSessionReferenceStore(persistence: memory);
      final old = AcpSessionReference(
        binding: scope('one'),
        sessionId: 'remote',
      );
      await store.save(old);
      final owner = _NativePolicy();
      final port = adapter(store, owner).rebind!;
      final ticket = (await port.stage(old, nextScope()))!;
      final staged = memory.value;
      expect(
        await port.commit(
          ticket,
          old,
          AcpSessionReference(binding: nextScope(), sessionId: 'different'),
        ),
        false,
      );
      expect(owner.commits, 0);
      expect(
        await port.commit(
          Object(),
          old,
          AcpSessionReference(binding: nextScope(), sessionId: 'remote'),
        ),
        false,
      );
      owner.commitAllowed = false;
      expect(
        await port.commit(
          ticket,
          old,
          AcpSessionReference(binding: nextScope(), sessionId: 'remote'),
        ),
        false,
      );
      owner.throwCommit = true;
      await expectLater(
        port.commit(
          ticket,
          old,
          AcpSessionReference(binding: nextScope(), sessionId: 'remote'),
        ),
        throwsStateError,
      );
      expect(memory.value, staged);
      expect(
        (await store.read(nextScope()))!.binding.matches(old.binding),
        true,
      );
    },
  );

  test('crash after native ACK and failed cursor write '
      'retains recoverable pending', () async {
    final memory = _Memory();
    final store = AcpSessionReferenceStore(persistence: memory);
    final old = AcpSessionReference(binding: scope('one'), sessionId: 'remote');
    await store.save(old);
    final owner = _NativePolicy();
    final port = adapter(store, owner).rebind!;
    final ticket = (await port.stage(old, nextScope()))!;
    final ack = AcpSessionReference(binding: nextScope(), sessionId: 'remote');
    final staged = memory.value;
    memory.failWrite = true;
    await expectLater(port.commit(ticket, old, ack), throwsStateError);
    expect(owner.commits, 1);
    expect(memory.value, staged);
    memory.failWrite = false;
    final reopened = AcpSessionReferenceStore(persistence: memory);
    expect(reopened.bind(authorize: (_, _) async => false).rebind, isNull);
    await expectLater(
      reopened.save(ack),
      throwsA(isA<AcpSessionPersistenceRefusal>()),
    );
    final resumed = adapter(reopened, owner).rebind!;
    expect(await resumed.commit(ticket, old, ack), true);
    expect(
      (await reopened.read(nextScope()))!.binding.matches(nextScope()),
      true,
    );
  });

  test(
    'serialized pending neither authorizes nor restores revoked ticket',
    () async {
      final memory = _Memory();
      final store = AcpSessionReferenceStore(persistence: memory);
      final old = AcpSessionReference(
        binding: scope('one'),
        sessionId: 'remote',
      );
      await store.save(old);
      final owner = _NativePolicy();
      final port = adapter(store, owner).rebind!;
      final ticket = (await port.stage(old, nextScope()))!;
      owner.enabled = false;
      final reopened = AcpSessionReferenceStore(persistence: memory);
      final denied = adapter(reopened, owner).rebind!;
      expect(await denied.stage(old, nextScope()), isNull);
      expect(await denied.authorize(ticket, old, nextScope()), false);
      expect(
        await denied.commit(
          ticket,
          old,
          AcpSessionReference(binding: nextScope(), sessionId: 'remote'),
        ),
        false,
      );
      expect(
        (await reopened.read(nextScope()))!.binding.matches(old.binding),
        true,
      );
      final forged = jsonDecode(memory.value!) as Map;
      final row = (forged['pendingTransitions'] as Map).values.single as Map;
      row['ticket'] = {'grant': true};
      memory.value = jsonEncode(forged);
      await expectLater(
        reopened.read(nextScope()),
        throwsA(isA<AcpSessionPersistenceRefusal>()),
      );
    },
  );

  test(
    'intervening cursor change during native await is never overwritten',
    () async {
      final memory = _Memory();
      final store = AcpSessionReferenceStore(persistence: memory);
      final old = AcpSessionReference(
        binding: scope('one'),
        sessionId: 'remote',
      );
      await store.save(old);
      final owner = _NativePolicy();
      final port = adapter(store, owner).rebind!;
      final ticket = (await port.stage(old, nextScope()))!;
      final competing = AcpSessionReference(
        binding: nextScope(revision: 'other'),
        sessionId: 'remote',
      );
      owner.onCommit = () async {
        final document = jsonDecode(memory.value!) as Map;
        final rows = document['sessions'] as Map;
        rows[rows.keys.single] = competing.toJson();
        document.remove('pendingTransitions');
        memory.value = jsonEncode(document);
      };
      expect(
        await port.commit(
          ticket,
          old,
          AcpSessionReference(binding: nextScope(), sessionId: 'remote'),
        ),
        false,
      );
      expect(
        (await store.read(nextScope()))!.binding.matches(competing.binding),
        true,
      );
    },
  );

  test('existing atomic file document carries pending '
      'and exact commit across reopen', () async {
    final root = await Directory.systemTemp.createTemp('acp_transition_');
    addTearDown(() => root.delete(recursive: true));
    final file = File('${root.path}/agent_sessions.json');
    final storage = FileAgentConfigPersistence(
      filePath: file.path,
      documentName: 'agent_sessions.json',
    );
    final old = AcpSessionReference(binding: scope('one'), sessionId: 'remote');
    final store = AcpSessionReferenceStore(persistence: storage);
    await store.save(old);
    final owner = _NativePolicy();
    final ticket = (await adapter(
      store,
      owner,
    ).rebind!.stage(old, nextScope()))!;
    final reopened = AcpSessionReferenceStore(persistence: storage);
    expect(
      (await reopened.read(nextScope()))!.binding.matches(old.binding),
      true,
    );
    expect(
      await adapter(reopened, owner).rebind!.commit(
        ticket,
        old,
        AcpSessionReference(binding: nextScope(), sessionId: 'remote'),
      ),
      true,
    );
    expect(root.listSync().whereType<Directory>(), isEmpty);
    expect(
      (jsonDecode(await file.readAsString()) as Map).containsKey(
        'pendingTransitions',
      ),
      false,
    );
  });
  test(
    'successful atomic replace with lost response reconciles exact pair',
    () async {
      final memory = _Memory();
      final store = AcpSessionReferenceStore(persistence: memory);
      final old = AcpSessionReference(
        binding: scope('one'),
        sessionId: 'remote',
      );
      await store.save(old);
      final owner = _NativePolicy();
      final port = adapter(store, owner).rebind!;
      final ticket = (await port.stage(old, nextScope()))!;
      final ack = AcpSessionReference(
        binding: nextScope(),
        sessionId: 'remote',
      );
      memory.failAfterWrite = true;
      await expectLater(port.commit(ticket, old, ack), throwsStateError);
      expect(
        (await store.read(nextScope()))!.binding.matches(nextScope()),
        true,
      );
      final reopened = AcpSessionReferenceStore(persistence: memory);
      final retry = adapter(reopened, owner).rebind!;
      final writes = memory.writes;
      expect(await retry.stage(old, nextScope()), same(ticket));
      expect(await retry.authorize(ticket, old, nextScope()), true);
      expect(await retry.commit(ticket, old, ack), true);
      expect(memory.writes, writes);
      owner.enabled = false;
      expect(await retry.stage(old, nextScope()), isNull);
    },
  );
}
