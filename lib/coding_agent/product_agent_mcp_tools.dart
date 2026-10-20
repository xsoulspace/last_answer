import 'package:lastanswer/coding_agent/agent_doc_surface.dart';
import 'package:mcp_toolkit/mcp_toolkit.dart';
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';

/// Adapters only: account, consent, preparation and source effects stay with
/// their existing product/host owners. Every operation requires an exact doc.
Set<AgentCallEntry> productAgentMcpEntries() {
  final sessions = HarnessSessionTools(
    registry: HarnessSessionRegistry.instance,
    resolveDocAlias: (id) => id.startsWith('agent-') ? id : 'agent-$id',
  );
  Future<AgentResult> addressed(
    Map<String, Object?> args,
    Future<Map<String, Object?>> Function(AgentDocProductHandle) action,
  ) async {
    try {
      if (args['docId'] is! String || (args['docId']! as String).isEmpty) {
        return AgentResult.success(
          data: const {'ok': false, 'error': 'doc_id_required'},
        );
      }
      final handle = sessions.resolve(args);
      if (handle is! AgentDocProductHandle) {
        return AgentResult.success(
          data: const {'ok': false, 'error': 'document_owner_required'},
        );
      }
      return AgentResult.success(data: await action(handle));
    } on SessionResolutionException catch (error) {
      return AgentResult.success(
        data: HarnessSessionTools.resolutionError(error),
      );
    } on Object catch (error) {
      return AgentResult.success(data: {'ok': false, 'error': '$error'});
    }
  }

  return {
    AgentCallEntry.tool(
      namespace: 'lastanswer',
      name: 'agent_product_converse',
      description:
          'Ask the addressed product world a question while coding continues, '
          'through the existing sibling conversation actor. '
          'No edit authority is added.',
      inputSchema: const {
        'type': 'object',
        'additionalProperties': false,
        'properties': {
          'docId': {'type': 'string'},
          'text': {'type': 'string'},
        },
        'required': ['docId', 'text'],
      },
      handler: (args) => addressed(args, (doc) async {
        if (doc is! AgentDocAutonomyHandle) {
          return {'ok': false, 'error': 'autonomy_owner_required'};
        }
        return (doc as AgentDocAutonomyHandle).converseProduct(
          args['text']! as String,
        );
      }),
    ),
    AgentCallEntry.tool(
      namespace: 'lastanswer',
      name: 'agent_product_autonomy',
      description:
          'Start the addressed document task-board product with two-hour '
          'native authority to update its main.dart, inspect its live product, '
          'or revoke authority. Uses the same controls as the human interface. '
          'No training or semantic materialization.',
      inputSchema: const {
        'type': 'object',
        'additionalProperties': false,
        'properties': {
          'docId': {'type': 'string'},
          'action': {
            'type': 'string',
            'enum': ['start', 'status', 'revoke'],
          },
        },
        'required': ['docId', 'action'],
      },
      handler: (args) => addressed(args, (doc) async {
        if (doc is! AgentDocAutonomyHandle) {
          return {'ok': false, 'error': 'autonomy_owner_required'};
        }
        return (doc as AgentDocAutonomyHandle).autonomyAction(
          args['action']! as String,
        );
      }),
    ),
    AgentCallEntry.tool(
      namespace: 'lastanswer',
      name: 'agent_product_local_pair',
      description:
          'Configure Qwen, DeepSeek1017 or Luna generation resources for '
          'an autonomous product document. Optional Laya routing; native scope '
          'and explicit Luna consent remain required. No training.',
      inputSchema: const {
        'type': 'object',
        'additionalProperties': false,
        'properties': {
          'docId': {'type': 'string'},
          'action': {
            'type': 'string',
            'enum': ['configure', 'status'],
          },
          'snapshotDir': {'type': 'string'},
          'resource': {
            'type': 'string',
            'enum': ['qwen', 'deepseek', 'luna'],
          },
          'routeWithLaya': {'type': 'boolean'},
          'allowEscalation': {'type': 'boolean'},
          'grantConsent': {'type': 'boolean'},
        },
        'required': ['docId', 'action'],
      },
      handler: (args) => addressed(args, (doc) async {
        if (doc is! AgentDocAutonomyHandle) {
          return {'ok': false, 'error': 'autonomy_owner_required'};
        }
        return (doc as AgentDocAutonomyHandle).localPairAction(args);
      }),
    ),
    AgentCallEntry.tool(
      namespace: 'lastanswer',
      name: 'agent_doc_configure_native',
      description:
          'Configure the addressed document with an existing ChatGPT account model and workspace. grantConsent explicitly records transmission consent for that exact document/account/model/workspace. Reasoning effort is low.',
      inputSchema: const {
        'type': 'object',
        'additionalProperties': false,
        'properties': {
          'docId': {'type': 'string'},
          'workspace': {'type': 'string'},
          'model': {'type': 'string'},
          'check': {'type': 'string'},
          'grantConsent': {'type': 'boolean'},
        },
        'required': ['docId', 'workspace', 'model', 'grantConsent'],
      },
      handler: (args) => addressed(
        args,
        (doc) => doc.configureNative(
          workspace: args['workspace']! as String,
          model: args['model']! as String,
          grantConsent: args['grantConsent']! as bool,
          check: args['check'] as String?,
        ),
      ),
    ),
    AgentCallEntry.tool(
      namespace: 'lastanswer',
      name: 'agent_coding_change',
      description:
          'Read native source, author a conventional candidate, '
          'inspect status, '
          'apply or undo through the addressed product owner. Scoped native '
          'authority applies inside an explicitly delegated footprint; other '
          'changes retain exact permission. Read needs no sourceId; preview '
          'uses the returned sourceId and changesJson or editsJson.',
      inputSchema: const {
        'type': 'object',
        'additionalProperties': false,
        'properties': {
          'docId': {'type': 'string'},
          'action': {
            'type': 'string',
            'enum': [
              'read',
              'readFile',
              'preview',
              'status',
              'review',
              'apply',
              'undo',
              'reapply',
              'finalize',
            ],
          },
          'candidateId': {'type': 'string'},
          'proposalId': {'type': 'string'},
          'runId': {'type': 'string'},
          'sourceId': {'type': 'string'},
          'path': {'type': 'string'},
          'changesJson': {'type': 'string'},
          'editsJson': {'type': 'string'},
        },
        'required': ['docId', 'action'],
      },
      handler: (args) => addressed(args, (doc) {
        final action = args['action'];
        final native = switch (action) {
          'review' => 'adoptCandidate',
          'undo' => 'recoverRollback',
          'reapply' => 'reviewSaved',
          'read' ||
          'readFile' ||
          'preview' ||
          'status' ||
          'apply' ||
          'finalize' => action! as String,
          _ => null,
        };
        if (native == null) {
          return Future.value({
            'ok': false,
            'error': 'coding_action_unsupported',
          });
        }
        return doc.codingAction(native, {
          for (final key in [
            'candidateId',
            'proposalId',
            'runId',
            'sourceId',
            'path',
            'changesJson',
            'editsJson',
          ])
            if (args[key] != null) key: args[key],
        });
      }),
    ),
  };
}
