import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:lastanswer/data_agents/subscriptions/grok_secure_storage.dart';
import 'package:lastanswer/data_agents/config/provider_configuration.dart';
import 'package:xsoulspace_inference_xai/xsoulspace_inference_xai.dart';

/// Safe account projection. Tokens stay in the protected store.
final class GrokProfile {
  const GrokProfile({
    required this.subject,
    required this.signedIn,
    required this.planEnabled,
    this.email,
    this.model,
  });

  final String subject;
  final String? email;
  final bool signedIn;
  final bool planEnabled;
  final String? model;
}

/// One keychain value for every Grok account on this device.
final class GrokCredentials implements GrokCredentialStore {
  GrokCredentials({SecureValueStore? secureValues})
    : _secureValues = secureValues ?? grokSecureValueStore();

  static const storageKey = 'lastanswer.grok.accounts.v1';
  final SecureValueStore _secureValues;
  Future<void> _tail = Future<void>.value();

  Future<T> _protected<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on MissingPluginException {
      throw const GrokAuthException('credential_store_unavailable');
    } on PlatformException {
      throw const GrokAuthException('credential_store_failed');
    }
  }

  Future<Map<String, dynamic>> _snapshot() async {
    final value = await _protected(() => _secureValues.read(storageKey));
    if (value == null) return {'accounts': <String, dynamic>{}};
    try {
      final json = jsonDecode(value);
      if (json is! Map<String, dynamic> || json['accounts'] is! Map) {
        throw const FormatException();
      }
      return json;
    } on GrokAuthException {
      rethrow;
    } on Object {
      throw const GrokAuthException('credential_store_invalid');
    }
  }

  Future<T> _transaction<T>(Future<T> Function(Map<String, dynamic>) mutate) {
    final result = Completer<T>();
    _tail = _tail.then((_) async {
      try {
        final snapshot = await _snapshot();
        final value = await mutate(snapshot);
        await _protected(
          () => _secureValues.write(storageKey, jsonEncode(snapshot)),
        );
        result.complete(value);
      } on Object catch (error, stack) {
        result.completeError(error, stack);
      }
    });
    return result.future;
  }

  @override
  Future<GrokAccount?> read(String subject) async {
    await _tail;
    final account = (await _snapshot())['accounts'];
    final record = account is Map ? account[subject] : null;
    final credentials = record is Map ? record['credentials'] : null;
    if (credentials is! Map) return null;
    return GrokAccount.fromStorageJson(credentials.cast<String, dynamic>());
  }

  @override
  Future<void> write(GrokAccount account) => _transaction((snapshot) async {
    final accounts = Map<String, dynamic>.from(snapshot['accounts'] as Map);
    final previous = accounts[account.subject];
    if (previous is Map &&
        previous['credentials'] is Map &&
        (previous['credentials'] as Map)['subject'] != account.subject) {
      throw const GrokAuthException('account_mismatch');
    }
    accounts[account.subject] = {
      if (previous is Map) ...previous.cast<String, dynamic>(),
      'email': account.email,
      'credentials': account.toStorageJson(),
    };
    snapshot['accounts'] = accounts;
  });

  @override
  Future<void> removeTokens(String subject) => _transaction((snapshot) async {
    final accounts = Map<String, dynamic>.from(snapshot['accounts'] as Map);
    final existing = accounts[subject];
    if (existing is Map) {
      accounts[subject] = Map<String, dynamic>.from(existing)
        ..remove('credentials');
    }
    snapshot['accounts'] = accounts;
    if (snapshot['active_subject'] == subject) {
      snapshot.remove('active_subject');
    }
  });

  Future<void> selectAccount(String subject) => _transaction((snapshot) async {
    final record = (snapshot['accounts'] as Map)[subject];
    if (record is! Map || record['credentials'] == null) {
      throw const GrokAuthException('sign_in_required');
    }
    snapshot['active_subject'] = subject;
  });

  Future<void> selectModel(String subject, String model) =>
      _transaction((snapshot) async {
        if (model.isEmpty) throw const GrokAuthException('model_required');
        final accounts = Map<String, dynamic>.from(snapshot['accounts'] as Map);
        final record = accounts[subject];
        if (record is! Map || record['credentials'] == null) {
          throw const GrokAuthException('sign_in_required');
        }
        accounts[subject] = {...record.cast<String, dynamic>(), 'model': model};
        snapshot['accounts'] = accounts;
      });

  Future<String?> activeSubject() async {
    await _tail;
    final value = (await _snapshot())['active_subject'];
    return value is String && value.isNotEmpty ? value : null;
  }

  Future<List<GrokProfile>> profiles() async {
    await _tail;
    final accounts = (await _snapshot())['accounts'];
    if (accounts is! Map) return const [];
    final profiles = <GrokProfile>[];
    for (final entry in accounts.entries) {
      final record = entry.value;
      if (record is! Map || entry.key is! String) continue;
      final credentials = record['credentials'];
      GrokAccount? account;
      if (credentials is Map) {
        account = GrokAccount.fromStorageJson(
          credentials.cast<String, dynamic>(),
        );
      }
      profiles.add(
        GrokProfile(
          subject: entry.key as String,
          email: account?.email ?? record['email'] as String?,
          signedIn: account != null,
          planEnabled: account?.planEnabled ?? false,
          model: record['model'] as String?,
        ),
      );
    }
    profiles.sort((a, b) => a.subject.compareTo(b.subject));
    return profiles;
  }
}
