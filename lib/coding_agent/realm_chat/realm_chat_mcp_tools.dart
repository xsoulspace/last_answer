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
        _spawnWork(),
        _projectAccess(),
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

AgentCallEntry _spawnWork() => _entry(
      'realm_chat_spawn_work',
      'Spawn (or reuse) the project-sealed work thread for a work order '
      '(ADR 0129): one thread per (parent room × project root), the '
      'order forwarded as ONE addressed human beat — the seal is the '
      "daemon actor's sandbox. Refuses honestly with the current grant "
      'list when the human lacks the project grant (realm_project_access '
      '{action: grant} fixes that).',
      const <String, dynamic>{
        'type': 'object',
        'properties': <String, dynamic>{
          'project': <String, dynamic>{
            'type': 'string',
            'description': 'The workspace root path to seal to.',
          },
          'text': <String, dynamic>{
            'type': 'string',
            'description': 'The work order; one beat in the work thread.',
          },
          'members': <String, dynamic>{
            'type': 'string',
            'description': 'Comma-separated actor ids the order addresses.',
          },
          'parentThreadId': <String, dynamic>{
            'type': 'string',
            'description': 'Parent room (default: the active thread).',
          },
          'topic': <String, dynamic>{
            'type': 'string',
            'description':
                'Work-thread name (default: the last path segment of '
                'the project root).',
          },
        },
        'required': <String>['project'],
      },
      (final args) async {
        final service = _service;
        if (service == null) {
          return _fail('no_service', 'open a chat surface first');
        }
        await service.ensureReady();
        final project = (args['project'] as String? ?? '').trim();
        if (project.isEmpty) {
          return _fail(
            'missing_parameters',
            'project (the workspace root path) is required',
          );
        }
        final parentArg = (args['parentThreadId'] as String? ?? '').trim();
        final parent =
            parentArg.isNotEmpty ? parentArg : service.activeThreadId;
        if (parent == null || parent.isEmpty) {
          return _fail(
            'no_parent_thread',
            'open a room first or pass parentThreadId',
          );
        }
        final members = (args['members'] as String? ?? '')
            .split(',')
            .map((final m) => m.trim())
            .where((final m) => m.isNotEmpty)
            .toList();
        final spawn = await service.spawnWorkThread(
          parentThreadId: parent,
          projectRoot: project,
          memberIds: members,
          orderText: args['text'] as String?,
          topic: args['topic'] as String?,
        );
        final link = spawn.workThread;
        if (link == null) {
          // The honest-refusal law: the named refusal and its evidence
          // (the current grants) ride the result — never an exception,
          // never a silent no-op.
          return <String, Object?>{
            'ok': false,
            'error': spawn.refusal ?? 'spawn_refused',
            'project': project,
            'grants': spawn.grants,
            'hint': spawn.refusal == 'project_not_granted'
                ? 'grant access first: realm_project_access '
                      '{action: grant, actor: <human>, project: <root>}'
                : spawn.message ?? 'see error',
          };
        }
        return _ok(<String, Object?>{
          'workThreadId': link.workThreadId,
          'reused': spawn.reused,
          'project': link.projectRoot,
          'parentThreadId': link.parentThreadId,
          'name': link.name,
          if (spawn.orderBeat != null) 'orderBeat': spawn.orderBeat,
          if (spawn.refusal != null) 'orderRefusal': spawn.refusal,
        });
      },
    );

AgentCallEntry _projectAccess() => _entry(
      'realm_project_access',
      'Project-access management (ADR 0121/0129): list the durable '
      "project grants of an actor, list the realm's pending access "
      'requests, record a request, or grant access (the in-process twin '
      'of `ecsai --grant` — the canonical host functions).',
      const <String, dynamic>{
        'type': 'object',
        'properties': <String, dynamic>{
          'action': <String, dynamic>{
            'type': 'string',
            'enum': <String>['list', 'pending', 'request', 'grant'],
          },
          'actor': <String, dynamic>{
            'type': 'string',
            'description': 'Actor id (default: the human).',
          },
          'project': <String, dynamic>{
            'type': 'string',
            'description':
                'Project root path (required for request and grant).',
          },
        },
        'required': <String>['action'],
      },
      (final args) async {
        final service = _service;
        if (service == null) {
          return _fail('no_service', 'open a chat surface first');
        }
        await service.ensureReady();
        if (service.world == null) {
          return _fail(
            'world_unavailable',
            'this platform has no filesystem world',
          );
        }
        final action = (args['action'] as String? ?? '').trim();
        final actorArg = (args['actor'] as String? ?? '').trim();
        final actor =
            actorArg.isNotEmpty ? actorArg : service.humanActorId ?? '';
        if (actor.isEmpty) {
          return _fail('missing_parameters', 'actor (no human identity yet)');
        }
        final project = (args['project'] as String? ?? '').trim();
        switch (action) {
          case 'list':
            return _ok(<String, Object?>{
              'actor': actor,
              'grants': await service.listGrants(actor),
            });
          case 'pending':
            return _ok(<String, Object?>{
              'requests': await service.pendingAccessRequests(),
            });
          case 'request':
            if (project.isEmpty) {
              return _fail('missing_parameters', 'project is required');
            }
            final requested = await service.requestAccess(actor, project);
            return <String, Object?>{'actor': actor, ...requested};
          case 'grant':
            if (project.isEmpty) {
              return _fail('missing_parameters', 'project is required');
            }
            final grant = await service.grantAccess(actor, project);
            return <String, Object?>{
              'ok': grant.granted,
              'actor': actor,
              'project': project,
              'message': grant.message,
              if (!grant.granted) 'error': 'grant_not_applied',
            };
        }
        return _fail(
          'unknown_action',
          'action must be one of list, pending, request, grant '
          "(got '$action')",
        );
      },
    );
