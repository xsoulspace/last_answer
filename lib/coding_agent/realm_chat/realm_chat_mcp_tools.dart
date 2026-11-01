// Agent-driven debug intents over the world chat (ADR 0024): the same
// surface keys are the UI contract; these verbs drive the REAL
// RealmChatService so conversations can be exercised and verified
// without pointer simulation. Debug/profile only (mounted in main()).
import 'dart:async';
import 'dart:convert';

import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:mcp_toolkit/mcp_toolkit.dart';

/// The app's live world-chat service, registered by the shell on attach.
/// Static-by-contract (the debug seam, like AgentDocSurface.debugState).
RealmChatService? get _service {
  final instances = RealmChatService.debugInstances;
  return instances.isEmpty ? null : instances.first;
}

Map<String, Object?> _fail(final String error, final String hint) =>
    <String, Object?>{'ok': false, 'error': error, 'hint': hint};

Map<String, Object?> _ok(final Map<String, Object?> data) =>
    <String, Object?>{'ok': true, ...data};

/// The debug world-chat family, mounted next to the other entries in
/// main() (naming matches the other families: `<lane>McpEntries()`).
Set<AgentCallEntry> realmChatMcpEntries() => RealmChatMcpEntries.entries();

final class RealmChatMcpEntries {
  RealmChatMcpEntries._();
  static Set<AgentCallEntry> entries() => {
        _state(),
        _createActor(),
        _openDm(),
        _createChannel(),
        _say(),
      };
}

AgentCallEntry _entry(
  final String name,
  final String description,
  final Map<String, dynamic> schema,
  final Future<Map<String, Object?>> Function(Map<String, Object?> args) run,
) => mcpToolkitTool(
      handler: (final parameters) async {
        try {
          final result = await run(parameters);
          return MCPCallResult(
            message: result['ok'] == true
                ? '$name ok.'
                : '$name refused: ${result['error'] ?? 'unknown'}',
            parameters: result,
          );
        } on Object catch (error) {
          return MCPCallResult(
            message: '$name failed: $error',
            parameters: _fail('exception', '$error'),
          );
        }
      },
      definition: MCPToolDefinition(
        name: name,
        description: description,
        inputSchema: ObjectSchema.fromMap(schema),
      ),
    );

AgentCallEntry _state() => _entry(
      'realm_chat_state',
      'World-chat projection: threads, beats of the active thread, '
      'channels, actors, bot statuses, actor narration. Read-only '
      'verification verb.',
      const <String, dynamic>{
        'type': 'object',
        'properties': <String, dynamic>{},
      },
      (final args) async {
        final service = _service;
        if (service == null) {
          return _fail('no_service', 'open a chat surface first');
        }
        await service.ensureReady();
        return _ok(<String, Object?>{
          'human': service.humanActorId,
          'instanceDebug': <String, Object?>{
            'liveInstances': RealmChatService.debugInstances.length,
            'thisHash': service.hashCode,
            'allHashes': [
              for (final instance in RealmChatService.debugInstances)
                instance.hashCode,
            ],
          },
          'ready': service.isReady,
          'error': service.error,
          'actors': [
            for (final actor in service.roster?.all ?? const <ActorProfile>[])
              <String, Object?>{
                'actorId': actor.actorId,
                'kind': actor.kind.name,
                'brain': actor.brainRef,
                'name': actor.displayName,
              },
          ],
          'botStatuses': service.bots?.statuses ?? const <String, String>{},
          'narration': <String, Object?>{
            for (final entry in service.botNarration.entries)
              entry.key: <String, Object?>{
                'state': entry.value.state.name,
                'detail': entry.value.detail,
                'since': entry.value.since.toIso8601String(),
              },
          },
          'dispatcherCursor': service.bots?.debugCursor ?? const <String, int>{},
          'dispatcherWakes': service.bots?.debugWakes ?? -1,
          'dispatcherDispatches': service.bots?.debugDispatches ?? -1,
          'channels': [
            for (final channel in service.channels)
              <String, Object?>{
                'channelId': channel.channelId,
                'name': channel.name,
                'threadId': channel.threadId,
                'members': channel.memberIds,
              },
          ],
          'threads': service.threads,
          'activeThreadId': service.activeThreadId,
          'beats': service.beats,
          'previews': service.beatPreviews(),
        });
      },
    );

AgentCallEntry _createActor() => _entry(
      'realm_chat_create_actor',
      'Mint an actor identity (the shared human/actor-spawn mechanism): '
      'roster profile + world registration + bot listener when the brain '
      'is runnable. brain: `local:qwen` | `local:lfm` | `openrouter:<model>`.',
      const <String, dynamic>{
        'type': 'object',
        'properties': <String, dynamic>{
          'name': <String, dynamic>{'type': 'string'},
          'brain': <String, dynamic>{'type': 'string'},
          'role': <String, dynamic>{'type': 'string'},
        },
        'required': <String>['name', 'brain'],
      },
      (final args) async {
        final service = _service;
        if (service == null) {
          return _fail('no_service', 'open a chat surface first');
        }
        final name = (args['name'] as String? ?? '').trim();
        final brain = (args['brain'] as String? ?? '').trim();
        if (name.isEmpty || brain.isEmpty) {
          return _fail('missing_parameters', 'name and brain are required');
        }
        await service.ensureReady();
        final profile = await service.createActor(
          displayName: name,
          kind: ActorKind.model,
          brainRef: brain,
          role: args['role'] as String? ?? '',
        );
        if (profile == null) return _fail('world_unavailable', 'not ready');
        return _ok(<String, Object?>{
          'actorId': profile.actorId,
          'brain': profile.brainRef,
        });
      },
    );

AgentCallEntry _openDm() => _entry(
      'realm_chat_open_dm',
      'Open (or reuse) the DM thread with an actor and select it.',
      const <String, dynamic>{
        'type': 'object',
        'properties': <String, dynamic>{
          'actorId': <String, dynamic>{'type': 'string'},
        },
        'required': <String>['actorId'],
      },
      (final args) async {
        final service = _service;
        if (service == null) {
          return _fail('no_service', 'open a chat surface first');
        }
        final actorId = (args['actorId'] as String? ?? '').trim();
        if (actorId.isEmpty) return _fail('missing_parameters', 'actorId');
        await service.ensureReady();
        await service.openDm(actorId);
        return _ok(<String, Object?>{'activeThreadId': service.activeThreadId});
      },
    );

AgentCallEntry _createChannel() => _entry(
      'realm_chat_create_channel',
      'Create a named channel with the given member actor ids and select '
      'its thread. members: comma-separated actor ids.',
      const <String, dynamic>{
        'type': 'object',
        'properties': <String, dynamic>{
          'name': <String, dynamic>{'type': 'string'},
          'members': <String, dynamic>{'type': 'string'},
        },
        'required': <String>['name'],
      },
      (final args) async {
        final service = _service;
        if (service == null) {
          return _fail('no_service', 'open a chat surface first');
        }
        final name = (args['name'] as String? ?? '').trim();
        if (name.isEmpty) return _fail('missing_parameters', 'name');
        final members = (args['members'] as String? ?? '')
            .split(',')
            .map((final m) => m.trim())
            .where((final m) => m.isNotEmpty)
            .toList();
        await service.ensureReady();
        final channel = await service.createChannel(name, memberIds: members);
        if (channel == null) {
          return _fail(service.error ?? 'channel_refused', 'see error');
        }
        return _ok(<String, Object?>{
          'channelId': channel.channelId,
          'threadId': channel.threadId,
        });
      },
    );

AgentCallEntry _say() => _entry(
      'realm_chat_say',
      'Say one beat as the human in the active thread, addressed to the '
      'other participants.',
      const <String, dynamic>{
        'type': 'object',
        'properties': <String, dynamic>{
          'text': <String, dynamic>{'type': 'string'},
          'threadId': <String, dynamic>{'type': 'string'},
        },
        'required': <String>['text'],
      },
      (final args) async {
        final service = _service;
        if (service == null) {
          return _fail('no_service', 'open a chat surface first');
        }
        final text = (args['text'] as String? ?? '').trim();
        if (text.isEmpty) return _fail('missing_parameters', 'text');
        await service.ensureReady();
        final threadId = (args['threadId'] as String? ?? '').trim();
        if (threadId.isNotEmpty &&
            threadId != service.activeThreadId) {
          service.selectThread(threadId);
        }
        await service.say(text);
        return _ok(<String, Object?>{
          'activeThreadId': service.activeThreadId,
          'beats': service.beats.length,
        });
      },
    );

/// Compact JSON for logs.
String encodeJson(final Object? value) => jsonEncode(value);
