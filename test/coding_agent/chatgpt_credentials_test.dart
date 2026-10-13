import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/chatgpt_credentials.dart';
import 'package:lastanswer/coding_agent/provider_configuration.dart';
import 'package:xsoulspace_inference_openai/chatgpt_auth.dart';

final class SecureMemory implements SecureValueStore {
  final values = <String, String>{};
  bool failNextWrite = false;
  PlatformException? platformWriteFailure;
  @override
  Future<String?> read(String key) async => values[key];
  @override
  Future<void> delete(String key) async {
    values.remove(key);
  }

  @override
  Future<void> write(String key, String value) async {
    if (platformWriteFailure case final failure?) throw failure;
    if (failNextWrite) {
      failNextWrite = false;
      throw StateError('storage unavailable');
    }
    values[key] = value;
  }
}

ChatGptAccount record(
  String host,
  String client, {
  String access = 'fixture-access',
}) => ChatGptAccount(
  clientId: client,
  hostId: host,
  subject: 'subject-$client',
  email: 'same@example.test',
  accessToken: access,
  refreshToken: 'fixture-refresh',
  idToken: 'fixture-id',
  expiresAt: DateTime.utc(2099),
  scopes: {'chatgpt.tokens.use.direct'},
);

void main() {
  test(
    'platform storage errors expose only operation and numeric OS status',
    () async {
      final secure = SecureMemory()
        ..platformWriteFailure = PlatformException(
          code: 'Unexpected security result code',
          message: 'fixture-sensitive-error-body',
          details: -34018,
        );
      final store = ChatGptCredentials(secureValues: secure);
      await expectLater(
        store.ensureHostId(),
        throwsA(
          isA<ChatGptAuthException>()
              .having(
                (e) => e.code,
                'code',
                'credential_store_write_failed_-34018',
              )
              .having(
                (e) => e.toString(),
                'redaction',
                isNot(contains('fixture-sensitive')),
              ),
        ),
      );
    },
  );

  test(
    'acknowledged cancellation prevents durable commit across restart',
    () async {
      final secure = SecureMemory();
      final store = ChatGptCredentials(secureValues: secure);
      final host = await store.ensureHostId();
      await store.write(record(host, 'one'));
      await store.beginMutation('one');
      await store.write(
        record(host, 'one', access: 'not-authorized-to-commit'),
      );
      await store.cancelMutation('one');
      await expectLater(
        store.finishMutation('one'),
        throwsA(
          isA<ChatGptAuthException>().having(
            (e) => e.code,
            'code',
            'credential_mutation_cancelled',
          ),
        ),
      );
      final restarted = ChatGptCredentials(secureValues: secure);
      await expectLater(
        restarted.read('one'),
        throwsA(
          isA<ChatGptAuthException>().having(
            (e) => e.code,
            'code',
            'credential_recovery_required',
          ),
        ),
      );
      await restarted.write(record(host, 'one'));
      await restarted.finishMutation('one', rollback: true);
      expect((await restarted.read('one'))!.accessToken, 'fixture-access');
    },
  );

  test(
    'unknown remote cleanup survives local signout and new store objects',
    () async {
      final secure = SecureMemory();
      final store = ChatGptCredentials(secureValues: secure);
      final host = await store.ensureHostId();
      await store.write(record(host, 'one'));
      await store.beginMutation('one');
      await store.removeTokens('one');
      await store.finishMutation('one', cleanupConfirmed: false);
      final restarted = ChatGptCredentials(secureValues: secure);
      expect(await restarted.hasUnconfirmedCleanup(), true);
      expect((await restarted.profiles()).single.cleanupUnconfirmed, true);
      expect(await restarted.read('one'), null);
      final next = await restarted.beginMutation('one');
      expect(next.wasUnsettled, false);
      expect(next.hasUnconfirmedCleanup, true);
      await restarted.finishMutation('one');
      expect(await restarted.hasUnconfirmedCleanup(), true);
      // A new successful authorization is not evidence about older sessions.
      await restarted.write(
        record(host, 'one', access: 'new-authorized-access'),
      );
      expect(
        (await restarted.read('one'))!.accessToken,
        'new-authorized-access',
      );
      expect(await restarted.hasUnconfirmedCleanup(), true);
    },
  );

  test(
    'interrupted publication remains fenced across a new store/auth owner',
    () async {
      final secure = SecureMemory();
      final store = ChatGptCredentials(secureValues: secure);
      final host = await store.ensureHostId();
      await store.write(record(host, 'one'));
      await store.selectAccount('one');
      final mutation = await store.beginMutation('one');
      expect(mutation.wasUnsettled, false);
      await store.write(record(host, 'one', access: 'uncommitted-access'));
      final restarted = ChatGptCredentials(secureValues: secure);
      final auth = ChatGptAuth(store: restarted);
      addTearDown(auth.close);
      await expectLater(
        auth.accountForInference('one'),
        throwsA(
          isA<ChatGptAuthException>().having(
            (e) => e.code,
            'code',
            'credential_recovery_required',
          ),
        ),
      );
      expect((await restarted.profiles()).single.recoveryRequired, true);
      expect((await restarted.profiles()).single.signedIn, false);
      expect((await restarted.registration('one'))!.idTokenHint, null);
      final recovery = await restarted.beginMutation('one');
      expect(recovery.wasUnsettled, true);
      expect(recovery.previous!.accessToken, 'uncommitted-access');
      await restarted.removeTokens('one');
      await restarted.finishMutation('one');
      expect(await restarted.read('one'), null);
      expect((await restarted.profiles()).single.recoveryRequired, false);
    },
  );

  test(
    'failed fence persistence prevents remote mutation from starting',
    () async {
      final secure = SecureMemory();
      final store = ChatGptCredentials(secureValues: secure);
      final host = await store.ensureHostId();
      await store.write(record(host, 'one'));
      secure.failNextWrite = true;
      await expectLater(store.beginMutation('one'), throwsStateError);
      expect((await store.read('one'))!.accessToken, 'fixture-access');
    },
  );

  test(
    'host persists and same-email registrations remain independent',
    () async {
      final secure = SecureMemory();
      final store = ChatGptCredentials(secureValues: secure);
      final host = await store.ensureHostId();
      expect(await store.ensureHostId(), host);
      await store.write(record(host, 'one'));
      await store.write(record(host, 'two'));
      await store.selectAccount('one');
      await store.selectModel('one', 'chosen');
      await store.write(record(host, 'two', access: 'rotated'));
      expect(await store.activeClientId(), 'one');
      final profiles = await store.profiles();
      expect(profiles.map((p) => p.clientId), ['one', 'two']);
      expect(profiles.first.model, 'chosen');
      expect((await store.read('two'))!.accessToken, 'rotated');
    },
  );

  test(
    'signout retains identity and removes only selected credentials',
    () async {
      final secure = SecureMemory();
      final store = ChatGptCredentials(secureValues: secure);
      final host = await store.ensureHostId();
      await store.write(record(host, 'one'));
      await store.write(record(host, 'two'));
      await store.selectAccount('one');
      await store.removeTokens('one');
      expect(await store.read('one'), isNull);
      expect(await store.read('two'), isNotNull);
      expect(await store.activeClientId(), isNull);
      final profiles = await store.profiles();
      expect(profiles.first.signedIn, false);
      expect(profiles.first.subject, 'subject-one');
      expect(await store.ensureHostId(), host);
      await expectLater(
        store.selectAccount('one'),
        throwsA(isA<ChatGptAuthException>()),
      );
    },
  );

  test(
    'failed publication preserves old state and the mutation lane',
    () async {
      final secure = SecureMemory();
      final store = ChatGptCredentials(secureValues: secure);
      final host = await store.ensureHostId();
      await store.write(record(host, 'one'));
      secure.failNextWrite = true;
      await expectLater(
        store.write(record(host, 'one', access: 'not-published')),
        throwsStateError,
      );
      expect((await store.read('one'))!.accessToken, 'fixture-access');
      await store.selectModel('one', 'next');
      expect((await store.profiles()).single.model, 'next');
    },
  );

  test(
    'foreign host and corrupted storage refuse without erasing evidence',
    () async {
      final secure = SecureMemory();
      final store = ChatGptCredentials(secureValues: secure);
      await store.ensureHostId();
      await expectLater(
        store.write(record('other-host', 'one')),
        throwsA(isA<ChatGptAuthException>()),
      );
      secure.values[ChatGptCredentials.storageKey] = '{corrupt';
      await expectLater(
        store.ensureHostId(),
        throwsA(isA<ChatGptAuthException>()),
      );
      expect(secure.values[ChatGptCredentials.storageKey], '{corrupt');
    },
  );
}
