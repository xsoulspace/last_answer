import 'package:lastanswer/coding_agent/chatgpt_subscription_controller.dart';
import 'package:lastanswer/router.dart';
import 'package:mcp_toolkit/mcp_toolkit.dart';
import 'package:provider/provider.dart';

/// Debug/profile app actions over the same account controller used by widgets.
/// Browser sign-in requires human OAuth consent; no tool sees tokens.
Set<AgentCallEntry> chatGptMcpEntries({
  ChatGptSubscriptionController? Function()? controller,
}) {
  ChatGptSubscriptionController? resolve() =>
      controller?.call() ??
      appRouter.routerDelegate.navigatorKey.currentContext
          ?.read<ChatGptSubscriptionController?>();
  MCPCallResult result(Map<String, Object?> state) => MCPCallResult(
    message: 'Device-local ChatGPT account state.',
    parameters: state,
  );
  return {
    mcpToolkitTool(
      handler: (_) async {
        final state = resolve();
        await state?.load();
        return result(
          state == null
              ? {'ok': false, 'error': 'account_owner_unavailable'}
              : {'ok': true, ...state.snapshot()},
        );
      },
      definition: MCPToolDefinition(
        name: 'chatgpt_account_state',
        description:
            'Read safe device-local ChatGPT account/model/connection state; no credentials.',
        inputSchema: ObjectSchema.fromMap({
          'type': 'object',
          'properties': <String, dynamic>{},
        }),
      ),
    ),
    mcpToolkitTool(
      handler: (parameters) async {
        final state = resolve();
        if (state == null) {
          return result({'ok': false, 'error': 'account_owner_unavailable'});
        }
        if (!state.initialized) await state.load();
        final op = parameters['op'];
        if (state.busy && op != 'cancel') {
          return result({'ok': false, 'error': 'account_busy'});
        }
        final clientId = parameters['clientId'];
        final model = parameters['model'];
        switch (op) {
          case 'sign_in':
            await state.signIn(clientId: clientId is String ? clientId : null);
          case 'cancel':
            await state.cancel();
          case 'sign_out':
            await state.signOut();
          case 'select_account':
            if (clientId is! String || clientId.isEmpty) {
              return result({'ok': false, 'error': 'client_id_required'});
            }
            final saved = state.profiles
                .where((profile) => profile.clientId == clientId)
                .toList();
            if (saved.length != 1) {
              return result({'ok': false, 'error': 'registration_missing'});
            }
            if (saved.single.signedIn) {
              await state.selectAccount(clientId);
            } else {
              await state.signIn(clientId: clientId);
            }
          case 'select_model':
            if (model is! String || model.isEmpty) {
              return result({'ok': false, 'error': 'model_required'});
            }
            await state.selectModel(model);
          case 'refresh_models':
            await state.refreshModels();
          case 'verify_access':
            await state.verifyAccess();
          default:
            return result({
              'ok': false,
              'error': 'account_operation_unsupported',
            });
        }
        return result({
          'ok': op == 'cancel' || state.errorCode == null,
          ...state.snapshot(),
        });
      },
      definition: MCPToolDefinition(
        name: 'chatgpt_account_action',
        description:
            'Operate the product ChatGPT account pane through its controller. '
            'Sign-in opens the system browser for human consent.',
        inputSchema: ObjectSchema.fromMap({
          'type': 'object',
          'properties': {
            'op': {
              'type': 'string',
              'enum': [
                'sign_in',
                'cancel',
                'sign_out',
                'select_account',
                'select_model',
                'refresh_models',
                'verify_access',
              ],
            },
            'clientId': {'type': 'string'},
            'model': {'type': 'string'},
          },
          'required': ['op'],
        }),
      ),
    ),
  };
}
