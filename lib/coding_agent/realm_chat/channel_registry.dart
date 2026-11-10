/// ADR 0024 — the channel registry: LA-owned named threads.
///
/// A **channel** is a named group space (Discord-style: one space,
/// several actors of different kinds). It maps onto the substrate with
/// no second protocol: the durable thread carries the conversation, and
/// one record in the LA-owned `channels` collection of the SAME realm
/// control store (ADR 0107) carries the name and membership. A channel
/// exists before anyone speaks — the record is written when the channel
/// is opened, not on the first beat.
///
/// The registry is a dumb durable store over [RealmControlStore]; policy
/// (empty/duplicate-name refusal, selection, projections) lives in
/// [RealmChatService].
library;

import 'dart:math';

import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';

/// One registered channel: name, thread, membership.
final class ChannelInfo {
  const ChannelInfo({
    required this.channelId,
    required this.name,
    required this.threadId,
    required this.memberIds,
    required this.createdAt,
    this.archived = false,
  });

  factory ChannelInfo.fromRecord(final Map<String, Object?> record) =>
      ChannelInfo(
        channelId: record['channelId']! as String,
        name: record['name']! as String,
        threadId: record['threadId']! as String,
        memberIds: (record['memberIds']! as List).cast<String>(),
        createdAt: record['createdAt']! as String,
        // Tolerant decode: rows written before the field existed carry
        // no `archived` key, and a non-bool value is not a truth — both
        // read as the live default.
        archived: record['archived'] == true,
      );

  /// `channel-` + 12 hex chars (Random.secure) — the same minting style
  /// as `DurableConversation` thread ids.
  final String channelId;

  /// The user-facing name, unique per realm by service-level policy.
  final String name;

  /// The durable thread the channel's beats live in.
  final String threadId;

  /// Registered members (trimmed, deduped, sorted) — the opener included.
  /// A thread's participants can grow past this when speakers auto-join.
  final List<String> memberIds;

  /// ISO-8601 UTC instant; `list()` orders by it, oldest first.
  final String createdAt;

  /// Whether the channel was closed (archived). LAW: archiving never
  /// destroys anything — the row and its durable thread survive (the
  /// journal is authority); the channel just leaves the live lists.
  final bool archived;

  Map<String, Object?> toRecord() => <String, Object?>{
    'channelId': channelId,
    'name': name,
    'threadId': threadId,
    'memberIds': List<String>.of(memberIds),
    'createdAt': createdAt,
    'archived': archived,
  };

  @override
  String toString() =>
      'ChannelInfo($channelId, #$name, $threadId, members: $memberIds)';
}

/// The LA-owned `channels` collection inside the realm's one control
/// store — the same store the threads live in, never a side table
/// (ADR 0024 store law).
final class ChannelRegistry {
  ChannelRegistry({required this._store});

  final RealmControlStore _store;

  static const _collection = 'channels';

  /// Registers one channel over an already-opened thread.
  Future<ChannelInfo> create({
    required final String name,
    required final String threadId,
    required final List<String> memberIds,
  }) async {
    final record = <String, Object?>{
      'channelId': 'channel-${_mintId()}',
      'name': name.trim(),
      'threadId': threadId,
      'memberIds': <String>{
        for (final id in memberIds)
          if (id.trim().isNotEmpty) id.trim(),
      }.toList()
        ..sort(),
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'archived': false,
    };
    await _store.transact(
      (final tx) => tx.put(_collection, record['channelId']! as String, record),
    );
    return ChannelInfo.fromRecord(record);
  }

  /// All registered channels, oldest first. Archived rows are EXCLUDED
  /// by default (the live list); `includeArchived: true` reads the full
  /// history — a channel that was ever registered, closed or not.
  Future<List<ChannelInfo>> list({final bool includeArchived = false}) async {
    final records = await _store.scan(_collection);
    final channels = [
      for (final record in records.values) ChannelInfo.fromRecord(record),
    ]..sort((final a, final b) => a.createdAt.compareTo(b.createdAt));
    return includeArchived
        ? channels
        : [
            for (final channel in channels)
              if (!channel.archived) channel,
          ];
  }

  /// Rewrites one channel's name (stored trimmed), preserving every
  /// other field verbatim. Null on an unknown [channelId]. The registry
  /// is dumb: empty/duplicate-name policy lives in `RealmChatService`.
  Future<ChannelInfo?> rename({
    required final String channelId,
    required final String name,
  }) async {
    final record = await _store.read(_collection, channelId);
    if (record == null) return null;
    final next = <String, Object?>{...record, 'name': name.trim()};
    await _store.transact(
      (final tx) => tx.put(_collection, channelId, next),
    );
    return ChannelInfo.fromRecord(next);
  }

  /// Marks one channel archived — the row and its durable thread
  /// survive (the journal is authority; closing never destroys
  /// anything), the channel just leaves the live [list]. False on an
  /// unknown [channelId].
  Future<bool> archive({required final String channelId}) async {
    final record = await _store.read(_collection, channelId);
    if (record == null) return false;
    final next = <String, Object?>{...record, 'archived': true};
    await _store.transact(
      (final tx) => tx.put(_collection, channelId, next),
    );
    return true;
  }

  /// One-device-one-human migration: every member id matching the
  /// per-launch human shape (`human-<process timestamp>`) becomes
  /// [stableActorId]. Returns the healed channel count; a no-op once
  /// every channel names the stable id.
  Future<int> healHumanIdentity({required String stableActorId}) async {
    final stale = RegExp(r'^human-\d+$');
    var healed = 0;
    for (final channel in await list()) {
      final members = channel.memberIds;
      final hasStale = members.any(
        (id) => id != stableActorId && stale.hasMatch(id),
      );
      if (!hasStale) continue;
      final next = <String>{
        for (final id in members) stale.hasMatch(id) ? stableActorId : id,
      }.toList()
        ..sort();
      final record = channel.toRecord()..['memberIds'] = next;
      await _store.transact(
        (final tx) => tx.put(_collection, channel.channelId, record),
      );
      healed++;
    }
    return healed;
  }

  /// The LIVE channel registered over [threadId], null when no live
  /// channel carries it (a DM, an unregistered group, or a channel that
  /// was archived).
  Future<ChannelInfo?> byThreadId(final String threadId) async {
    for (final channel in await list()) {
      if (channel.threadId == threadId) return channel;
    }
    return null;
  }

  Future<ChannelInfo?> byId(final String channelId) async {
    final record = await _store.read(_collection, channelId);
    return record == null ? null : ChannelInfo.fromRecord(record);
  }
}

/// 12 hex chars from [Random.secure] — byte-identical in shape to the
/// harness's `DurableConversation._mintId`, so one id vocabulary spans
/// threads and channels.
String _mintId() {
  final random = Random.secure();
  return List<String>.generate(
    12,
    (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
}
