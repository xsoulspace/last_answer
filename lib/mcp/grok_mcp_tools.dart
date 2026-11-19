import 'package:lastanswer/data_agents/subscriptions/grok_subscription_controller.dart';
import 'package:lastanswer/router.dart';
import 'package:mcp_toolkit/mcp_toolkit.dart';
import 'package:provider/provider.dart';

/// Debug account actions. Browser sign-in still needs the account holder.
/// No tool receives tokens.
Set<AgentCallEntry> grokMcpEntries({
  GrokSubscriptionController? Function()? controller,
}) {
  GrokSubscriptionController? resolve() =>
      controller?.call() ??
      appRouter.routerDelegate.navigatorKey.currentContext
          ?.read<GrokSubscriptionController?>();
  MCPCallResult result(Map<String, Object?> state) => MCPCallResult(
    message: 'Device-local Grok account state.',
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
        name: 'grok_account_state',
        description:
            'Read safe device-local Grok account state, including whether '
            'xAI has registered Last Answer. No credentials.',
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
        final subject = parameters['subject'];
        final model = parameters['model'];
        switch (op) {
          case 'sign_in':
            await state.signIn(subject: subject is String ? subject : null);
          case 'sign_in_device':
            await state.signInWithDevice(
              subject: subject is String ? subject : null,
            );
          case 'cancel':
            await state.cancel();
          case 'sign_out':
            await state.signOut();
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
            return result({'ok': false, 'error': 'unknown_account_op'});
        }
        return result({'ok': state.errorCode == null, ...state.snapshot()});
      },
      definition: MCPToolDefinition(
        name: 'grok_account_action',
        description:
            'Sign in, cancel, sign out, or check the Grok subscription '
            'account. Sign-in opens the system browser or a device code.',
        inputSchema: ObjectSchema.fromMap({
          'type': 'object',
          'properties': {
            'op': {
              'type': 'string',
              'enum': [
                'sign_in',
                'sign_in_device',
                'cancel',
                'sign_out',
                'select_model',
                'refresh_models',
                'verify_access',
              ],
            },
            'subject': {'type': 'string'},
            'model': {'type': 'string'},
          },
          'required': ['op'],
        }),
      ),
    ),
  };
}
