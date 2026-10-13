import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:lastanswer/coding_agent/chatgpt_secure_storage.dart';
import 'package:lastanswer/coding_agent/provider_configuration.dart';
import 'package:xsoulspace_inference_openai/chatgpt_auth.dart';

/// Safe account projection. No tokens or authorization URLs enter document
/// state, mesh sync, provider configuration documents or UI projections.
final class ChatGptProfile {
  const ChatGptProfile({
    required this.clientId,
    required this.subject,
    required this.signedIn,
    required this.planEnabled,
    this.recoveryRequired = false,
    this.cleanupUnconfirmed = false,
    this.email,
    this.model,
  });
  final String clientId;
  final String subject;
  final String? email;
  final bool signedIn;
  final bool planEnabled;
  final bool recoveryRequired;
  final bool cleanupUnconfirmed;
  final String? model;
}

/// Device-local protected credential transaction. One keychain value replaces
/// registrations, identity mappings and selected account atomically. One shared
/// instance is composed with one auth owner to serialize rotating refreshes.
final class ChatGptCredentials implements RecoverableChatGptCredentialStore {
  ChatGptCredentials({SecureValueStore? secureValues})
    : _secureValues = secureValues ?? chatGptSecureValueStore();

  static const storageKey = 'lastanswer.chatgpt.registrations.v1';
  final SecureValueStore _secureValues;
  Future<void> _tail = Future.value();

  Future<T> _protected<T>(String operation, Future<T> Function() action) async {
    try {
      return await action();
    } on MissingPluginException {
      throw const ChatGptAuthException('credential_store_unavailable');
    } on PlatformException catch (error) {
      final status =
          error.code == 'Unexpected security result code' &&
              error.details is int
          ? error.details as int
          : null;
      throw ChatGptAuthException(
        'credential_store_${operation}_failed'
        '${status != null && status.abs() < 100000000 ? '_$status' : ''}',
      );
    }
  }

  Future<Map<String, dynamic>> _snapshot() async {
    final value = await _protected(
      'read',
      () => _secureValues.read(storageKey),
    );
    if (value == null) {
      return {'registrations': <String, dynamic>{}};
    }
    try {
      final json = jsonDecode(value);
      if (json is! Map<String, dynamic> ||
          json['registrations'] is! Map<String, dynamic>) {
        throw const FormatException();
      }
      return json;
    } on Object {
      // Do not erase an unreadable credential store or expose its contents.
      throw const ChatGptAuthException('credential_store_invalid');
    }
  }

  Future<T> _transaction<T>(Future<T> Function(Map<String, dynamic>) mutate) {
    final result = Completer<T>();
    _tail = _tail.then((_) async {
      try {
        final snapshot = await _snapshot();
        final value = await mutate(snapshot);
        await _protected(
          'write',
          () => _secureValues.write(storageKey, jsonEncode(snapshot)),
        );
        result.complete(value);
      } on Object catch (error, stack) {
        result.completeError(error, stack);
      }
    });
    return result.future;
  }

  Future<String> ensureHostId() => _transaction((snapshot) async {
    final stored = snapshot['host_id'];
    if (stored is String && stored.isNotEmpty) return stored;
    final id = ChatGptAuth.createHostId();
    snapshot['host_id'] = id;
    return id;
  });

  @override
  Future<ChatGptAccount?> read(String clientId) async {
    await _tail;
    final snapshot = await _snapshot();
    if (_pending(snapshot, clientId)) {
      throw const ChatGptAuthException('credential_recovery_required');
    }
    return _account(snapshot, clientId);
  }

  bool _pending(Map<String, dynamic> snapshot, String clientId) =>
      (snapshot['pending_mutations'] as Map?)?.containsKey(clientId) ?? false;

  bool _cleanupUnconfirmed(Map<String, dynamic> snapshot, String clientId) =>
      (snapshot['unconfirmed_cleanup'] as Map?)?.containsKey(clientId) ?? false;

  void _retainCleanupUncertainty(
    Map<String, dynamic> snapshot,
    String clientId,
  ) {
    final unsettled = Map<String, dynamic>.from(
      snapshot['unconfirmed_cleanup'] as Map? ?? const {},
    );
    unsettled[clientId] = true;
    snapshot['unconfirmed_cleanup'] = unsettled;
  }

  ChatGptAccount? _account(Map<String, dynamic> snapshot, String clientId) {
    final registration = (snapshot['registrations'] as Map)[clientId] as Map?;
    final credentials = registration?['credentials'];
    if (credentials == null) return null;
    try {
      final account = ChatGptAccount.fromStorageJson(
        (credentials as Map).cast<String, dynamic>(),
      );
      if (account.clientId != clientId ||
          account.hostId != snapshot['host_id'] ||
          account.subject != registration!['subject']) {
        throw const FormatException();
      }
      return account;
    } on Object {
      throw const ChatGptAuthException('credential_store_invalid');
    }
  }

  @override
  Future<ChatGptCredentialMutation> beginMutation(String clientId) =>
      _transaction((snapshot) async {
        final wasUnsettled = _pending(snapshot, clientId);
        if (wasUnsettled) _retainCleanupUncertainty(snapshot, clientId);
        final previous = _account(snapshot, clientId);
        final pending = Map<String, dynamic>.from(
          snapshot['pending_mutations'] as Map? ?? const {},
        );
        pending[clientId] = true;
        snapshot['pending_mutations'] = pending;
        (snapshot['cancelled_mutations'] as Map?)?.remove(clientId);
        return ChatGptCredentialMutation(
          previous: previous,
          wasUnsettled: wasUnsettled,
          hasUnconfirmedCleanup: _cleanupUnconfirmed(snapshot, clientId),
        );
      });

  @override
  Future<void> cancelMutation(String clientId) =>
      _transaction((snapshot) async {
        final pending = Map<String, dynamic>.from(
          snapshot['pending_mutations'] as Map? ?? const {},
        );
        pending[clientId] = true;
        snapshot['pending_mutations'] = pending;
        final cancelled = Map<String, dynamic>.from(
          snapshot['cancelled_mutations'] as Map? ?? const {},
        );
        cancelled[clientId] = true;
        snapshot['cancelled_mutations'] = cancelled;
      });

  @override
  Future<void> finishMutation(
    String clientId, {
    bool cleanupConfirmed = true,
    bool rollback = false,
  }) => _transaction((snapshot) async {
    if (!rollback &&
        ((snapshot['cancelled_mutations'] as Map?)?.containsKey(clientId) ??
            false)) {
      throw const ChatGptAuthException('credential_mutation_cancelled');
    }
    if (!cleanupConfirmed) _retainCleanupUncertainty(snapshot, clientId);
    (snapshot['pending_mutations'] as Map?)?.remove(clientId);
    (snapshot['cancelled_mutations'] as Map?)?.remove(clientId);
  });

  @override
  Future<void> write(ChatGptAccount account) => _transaction((snapshot) async {
    final hostId = snapshot['host_id'];
    if (hostId != account.hostId) {
      throw const ChatGptAuthException('credential_host_mismatch');
    }
    final registrations = snapshot['registrations'] as Map<String, dynamic>;
    final old = registrations[account.clientId] as Map?;
    if (old != null && old['subject'] != account.subject) {
      throw const ChatGptAuthException('account_mismatch');
    }
    registrations[account.clientId] = {
      ...?old,
      'subject': account.subject,
      'email': account.email,
      'credentials': account.toStorageJson(),
    };
  });

  @override
  Future<void> removeTokens(String clientId) => _transaction((snapshot) async {
    final registrations = snapshot['registrations'] as Map<String, dynamic>;
    final existing = registrations[clientId] as Map?;
    if (existing != null) {
      registrations[clientId] = Map<String, dynamic>.from(existing)
        ..remove('credentials');
    }
    if (snapshot['active_client_id'] == clientId) {
      snapshot.remove('active_client_id');
    }
  });

  Future<void> selectAccount(String clientId) => _transaction((snapshot) async {
    final registration = (snapshot['registrations'] as Map)[clientId] as Map?;
    if (registration?['credentials'] == null || _pending(snapshot, clientId)) {
      throw const ChatGptAuthException('sign_in_required');
    }
    snapshot['active_client_id'] = clientId;
  });

  Future<void> selectModel(String clientId, String model) => _transaction((
    snapshot,
  ) async {
    if (model.isEmpty) throw const ChatGptAuthException('model_required');
    final registrations = snapshot['registrations'] as Map<String, dynamic>;
    final registration = registrations[clientId] as Map?;
    if (registration?['credentials'] == null || _pending(snapshot, clientId)) {
      throw const ChatGptAuthException('sign_in_required');
    }
    registrations[clientId] = {...registration!, 'model': model};
  });

  Future<String?> activeClientId() async {
    await _tail;
    return (await _snapshot())['active_client_id'] as String?;
  }

  Future<bool> hasUnconfirmedCleanup() async {
    await _tail;
    return ((await _snapshot())['unconfirmed_cleanup'] as Map?)?.isNotEmpty ??
        false;
  }

  /// Reauthorization retains the issued mapping after sign-out, while cleared
  /// ID-token hints cannot be reconstructed from synced or document state.
  Future<ChatGptRegistration?> registration(String clientId) async {
    await _tail;
    final snapshot = await _snapshot();
    final value = (snapshot['registrations'] as Map)[clientId] as Map?;
    if (value == null) return null;
    final credentials = value['credentials'] as Map?;
    return ChatGptRegistration(
      clientId: clientId,
      hostId: snapshot['host_id'] as String,
      subject: value['subject'] as String,
      email: value['email'] as String?,
      idTokenHint: _pending(snapshot, clientId)
          ? null
          : credentials?['id_token'] as String?,
    );
  }

  Future<List<ChatGptProfile>> profiles() async {
    await _tail;
    final snapshot = await _snapshot();
    final registrations = snapshot['registrations'] as Map<String, dynamic>;
    return registrations.entries
        .map((entry) {
          final value = entry.value as Map;
          final credential = value['credentials'] as Map?;
          final scopes = credential?['scopes'] as List? ?? const [];
          return ChatGptProfile(
            clientId: entry.key,
            subject: value['subject'] as String,
            email: value['email'] as String?,
            signedIn: credential != null && !_pending(snapshot, entry.key),
            planEnabled:
                scopes.contains('chatgpt.tokens.use.direct') &&
                !_pending(snapshot, entry.key),
            recoveryRequired: _pending(snapshot, entry.key),
            cleanupUnconfirmed: _cleanupUnconfirmed(snapshot, entry.key),
            model: value['model'] as String?,
          );
        })
        .toList(growable: false);
  }
}
