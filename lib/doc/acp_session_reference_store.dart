import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:lastanswer/agent_config/agent_config_persistence.dart';
import 'package:lastanswer/agent_config/agent_config_persistence_prefs.dart'
    if (dart.library.io) 'package:lastanswer/agent_config/agent_config_persistence_io.dart'
    show createPlatformAgentConfigPersistence;
import 'package:xsoulspace_agentic_host/embedded_agent_mcp.dart'
    show
        EmbeddedAgentSessionLease,
        EmbeddedAgentSessionScope,
        EmbeddedAgentSessionTransition;
import 'package:xsoulspace_inference_acp/xsoulspace_inference_acp.dart';

/// Device-local remote-session cursors using the existing persistence adapter.
/// No transcript, credential, world history or mutation authority is stored.
final class AcpSessionReferenceStore {
  AcpSessionReferenceStore({AgentConfigPersistence? persistence})
    : persistence =
          persistence ??
          createPlatformAgentConfigPersistence(
            documentName: 'agent_sessions.json',
          );

  static final instance = AcpSessionReferenceStore();
  final AgentConfigPersistence persistence;
  Future<void> _tail = Future.value();

  static String _key(AcpSessionBinding binding) => sha256
      .convert(
        utf8.encode(
          jsonEncode([binding.conversationKey, binding.workingDirectory]),
        ),
      )
      .toString();

  Future<_CursorDocument> _readDocument() async {
    final raw = await persistence.read();
    if (raw == null) return _CursorDocument({}, {});
    try {
      if (utf8.encode(raw).length > 1024 * 1024) {
        throw const FormatException('oversized session cursor document');
      }
      final value = jsonDecode(raw);
      if (value is! Map || value['format'] != 1 || value['sessions'] is! Map) {
        throw const FormatException('session cursor document invalid');
      }
      final rows = Map<String, Object?>.from(value['sessions'] as Map);
      for (final row in rows.values) {
        AcpSessionReference.fromJson(Map<String, Object?>.from(row! as Map));
      }
      final rawPending = value.containsKey('pendingTransitions')
          ? value['pendingTransitions']
          : <String, Object?>{};
      if (rawPending is! Map || rows.length > 512 || rawPending.length > 512) {
        throw const FormatException('session transition document invalid');
      }
      final pending = <String, _PendingTransition>{};
      for (final entry in rawPending.entries) {
        final transition = _PendingTransition.fromJson(
          Map<String, Object?>.from(entry.value as Map),
        );
        if (entry.key is! String ||
            _key(transition.previous.binding) != entry.key ||
            !_rotation(transition.previous, transition.nextBinding)) {
          throw const FormatException('session transition scope invalid');
        }
        final row = rows[entry.key];
        if (row == null ||
            !_sameReference(
              AcpSessionReference.fromJson(
                Map<String, Object?>.from(row as Map),
              ),
              transition.previous,
            )) {
          throw const FormatException('session transition cursor invalid');
        }
        pending[entry.key as String] = transition;
      }
      return _CursorDocument(rows, pending);
    } on Object {
      throw const AcpSessionPersistenceRefusal('acp_session_store_invalid');
    }
  }

  Future<AcpSessionReference?> read(AcpSessionBinding binding) async {
    await _tail;
    final document = await _readDocument();
    final value = document.rows[_key(binding)];
    if (value == null) return null;
    // Return the saved identity even when changed. The transport refuses the
    // mismatch, instead of treating another descriptor/provider as a new chat.
    return AcpSessionReference.fromJson(
      Map<String, Object?>.from(value as Map),
    );
  }

  Future<T> _serial<T>(Future<T> Function() operation) {
    final next = _tail.then((_) => operation());
    // A failed write keeps the persisted pending transition for recovery.
    _tail = next.then<void>((_) {}, onError: (Object _) {});
    return next;
  }

  Future<void> _write(_CursorDocument document) => persistence.write(
    jsonEncode({
      'format': 1,
      'sessions': document.rows,
      if (document.pending.isNotEmpty)
        'pendingTransitions': {
          for (final entry in document.pending.entries)
            entry.key: entry.value.toJson(),
        },
    }),
  );

  Future<void> save(AcpSessionReference reference) => _serial(() async {
    final document = await _readDocument();
    final key = _key(reference.binding);
    if (document.pending.containsKey(key)) {
      throw const AcpSessionPersistenceRefusal(
        'acp_session_transition_pending',
      );
    }
    final old = document.rows[key];
    if (old != null) {
      final previous = AcpSessionReference.fromJson(
        Map<String, Object?>.from(old as Map),
      );
      if (!_sameReference(previous, reference)) {
        throw const AcpSessionPersistenceRefusal(
          'acp_session_reference_conflict',
        );
      }
    }
    document.rows[key] = reference.toJson();
    if (document.rows.length > 512) {
      throw const AcpSessionPersistenceRefusal('acp_session_store_limit');
    }
    await _write(document);
  });

  static bool _sameReference(AcpSessionReference a, AcpSessionReference b) =>
      a.binding.matches(b.binding) && a.sessionId == b.sessionId;

  static bool _rotation(AcpSessionReference previous, AcpSessionBinding next) =>
      previous.binding.conversationKey == next.conversationKey &&
      previous.binding.workingDirectory == next.workingDirectory &&
      previous.binding.providerIdentity == next.providerIdentity &&
      previous.binding.descriptorRevision != next.descriptorRevision;

  static bool _matchesPending(
    _PendingTransition? pending,
    AcpSessionReference previous,
    AcpSessionBinding next,
  ) =>
      pending != null &&
      _sameReference(pending.previous, previous) &&
      pending.nextBinding.matches(next);

  AcpSessionRebindPort _durableRebind(
    AcpSessionRebindPort native,
  ) => AcpSessionRebindPort(
    stage: (previous, next) => _serial(() async {
      if (!_rotation(previous, next)) return null;
      final document = await _readDocument();
      final key = _key(previous.binding);
      final row = document.rows[key];
      final pending = document.pending[key];
      final acknowledged = AcpSessionReference(
        binding: next,
        sessionId: previous.sessionId,
      );
      if (row == null) return null;
      final current = AcpSessionReference.fromJson(
        Map<String, Object?>.from(row as Map),
      );
      if (!_sameReference(current, previous) &&
          !(_sameReference(current, acknowledged) && pending == null)) {
        return null;
      }
      if (pending != null && !_matchesPending(pending, previous, next)) {
        return null;
      }
      // Native policy issues the ticket. JSON never supplies one.
      final ticket = await native.stage(previous, next);
      if (ticket == null || !await native.authorize(ticket, previous, next)) {
        return null;
      }
      final fresh = await _readDocument();
      final freshRow = fresh.rows[key];
      if (freshRow == null) return null;
      final latest = AcpSessionReference.fromJson(
        Map<String, Object?>.from(freshRow as Map),
      );
      final alreadyCommitted =
          _sameReference(latest, acknowledged) &&
          !fresh.pending.containsKey(key);
      if ((!_sameReference(latest, previous) && !alreadyCommitted) ||
          (fresh.pending[key] != null &&
              !_matchesPending(fresh.pending[key], previous, next)) ||
          !await native.authorize(ticket, previous, next)) {
        return null;
      }
      if (!alreadyCommitted && fresh.pending[key] == null) {
        fresh.pending[key] = _PendingTransition(previous, next);
        await _write(fresh);
      }
      if (!await native.authorize(ticket, previous, next)) return null;
      return ticket;
    }),
    authorize: (ticket, previous, next) async {
      if (!_rotation(previous, next) ||
          !await native.authorize(ticket, previous, next)) {
        return false;
      }
      await _tail;
      final document = await _readDocument();
      final key = _key(previous.binding);
      final row = document.rows[key];
      final acknowledged = AcpSessionReference(
        binding: next,
        sessionId: previous.sessionId,
      );
      final committed =
          row != null &&
          _sameReference(
            AcpSessionReference.fromJson(Map<String, Object?>.from(row as Map)),
            acknowledged,
          ) &&
          !document.pending.containsKey(key);
      return (_matchesPending(document.pending[key], previous, next) ||
              committed) &&
          await native.authorize(ticket, previous, next);
    },
    commit: (ticket, previous, acknowledged) => _serial(() async {
      if (!_rotation(previous, acknowledged.binding) ||
          previous.sessionId != acknowledged.sessionId) {
        return false;
      }
      final document = await _readDocument();
      final key = _key(previous.binding);
      final row = document.rows[key];
      if (row == null) return false;
      final current = AcpSessionReference.fromJson(
        Map<String, Object?>.from(row as Map),
      );
      final alreadyCommitted =
          _sameReference(current, acknowledged) &&
          !document.pending.containsKey(key);
      if (!alreadyCommitted &&
          (!_sameReference(current, previous) ||
              !_matchesPending(
                document.pending[key],
                previous,
                acknowledged.binding,
              ))) {
        return false;
      }
      if (!await native.authorize(ticket, previous, acknowledged.binding) ||
          !await native.commit(ticket, previous, acknowledged)) {
        return false;
      }
      // Re-read after native awaits: never overwrite an intervening cursor.
      final fresh = await _readDocument();
      final freshRow = fresh.rows[key];
      if (freshRow == null ||
          !await native.authorize(ticket, previous, acknowledged.binding)) {
        return false;
      }
      final latest = AcpSessionReference.fromJson(
        Map<String, Object?>.from(freshRow as Map),
      );
      if (_sameReference(latest, acknowledged) &&
          !fresh.pending.containsKey(key)) {
        return true;
      }
      if (!_sameReference(latest, previous) ||
          !_matchesPending(
            fresh.pending[key],
            previous,
            acknowledged.binding,
          )) {
        return false;
      }
      fresh.rows[key] = acknowledged.toJson();
      fresh.pending.remove(key);
      await _write(fresh);
      return true;
    }),
  );

  /// Maps transport cursors to an already issued native lease. The scope
  /// projection below grants nothing; only the publisher-owned lease decides.
  AcpSessionPersistence bindNativeLease(
    EmbeddedAgentSessionLease lease, {
    String? agentStateIdentity,
    String? continuityIdentity,
    EmbeddedAgentSessionTransition? transition,
  }) => bind(
    authorize: (binding, previous) => lease.authorize(
      _nativeScope(binding),
      previousScope: previous == null ? null : _nativeScope(previous.binding),
      previousSessionId: previous?.sessionId,
    ),
    acknowledge: (acknowledged) async {
      if (!lease.scope.matches(_nativeScope(acknowledged.binding))) {
        throw const AcpSessionPersistenceRefusal(
          'acp_session_acknowledgement_scope_mismatch',
        );
      }
      if (agentStateIdentity == null ||
          agentStateIdentity.trim().isEmpty ||
          continuityIdentity == null ||
          continuityIdentity.trim().isEmpty) {
        throw const AcpSessionPersistenceRefusal(
          'acp_session_acknowledgement_authority_missing',
        );
      }
      await lease.recordRemoteAcknowledgement(
        sessionId: acknowledged.sessionId,
        agentStateIdentity: agentStateIdentity,
        continuityIdentity: continuityIdentity,
      );
    },
    rebind: transition == null
        ? null
        : AcpSessionRebindPort(
            stage: (previous, next) async =>
                await transition.authorize(
                  previousScope: _nativeScope(previous.binding),
                  nextScope: _nativeScope(next),
                  sessionId: previous.sessionId,
                )
                ? transition
                : null,
            authorize: (ticket, previous, next) async =>
                identical(ticket, transition) &&
                await transition.authorize(
                  previousScope: _nativeScope(previous.binding),
                  nextScope: _nativeScope(next),
                  sessionId: previous.sessionId,
                ),
            commit: (ticket, previous, acknowledged) async =>
                identical(ticket, transition) &&
                await transition.authorize(
                  previousScope: _nativeScope(previous.binding),
                  nextScope: _nativeScope(acknowledged.binding),
                  sessionId: previous.sessionId,
                ) &&
                await transition.acknowledge(sessionId: acknowledged.sessionId),
          ),
  );

  static EmbeddedAgentSessionScope _nativeScope(AcpSessionBinding binding) =>
      EmbeddedAgentSessionScope(
        conversationKey: binding.conversationKey,
        workingDirectory: binding.workingDirectory,
        providerIdentity: binding.providerIdentity,
        descriptorRevision: binding.descriptorRevision,
      );

  AcpSessionPersistence bind({
    required Future<bool> Function(AcpSessionBinding, AcpSessionReference?)
    authorize,
    AcpSessionRebindPort? rebind,
    Future<void> Function(AcpSessionReference)? acknowledge,
  }) => AcpSessionPersistence(
    read: read,
    save: save,
    authorize: authorize,
    rebind: rebind == null ? null : _durableRebind(rebind),
    acknowledge: acknowledge,
  );
}

final class _CursorDocument {
  _CursorDocument(this.rows, this.pending);
  final Map<String, Object?> rows;
  final Map<String, _PendingTransition> pending;
}

final class _PendingTransition {
  _PendingTransition(this.previous, this.nextBinding);
  factory _PendingTransition.fromJson(Map<String, Object?> value) {
    if (value.length != 2 ||
        value['previous'] is! Map ||
        value['nextBinding'] is! Map) {
      throw const FormatException('session transition invalid');
    }
    return _PendingTransition(
      AcpSessionReference.fromJson(
        Map<String, Object?>.from(value['previous']! as Map),
      ),
      AcpSessionBinding.fromJson(
        Map<String, Object?>.from(value['nextBinding']! as Map),
      ),
    );
  }
  final AcpSessionReference previous;
  final AcpSessionBinding nextBinding;
  Map<String, Object?> toJson() => {
    'previous': previous.toJson(),
    'nextBinding': nextBinding.toJson(),
  };
}
