import 'package:lastanswer/coding_agent/chatgpt_subscription_controller.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:url_launcher/url_launcher.dart';

/// Account pane over the application's single protected credential owner.
class ChatGptSubscriptionPane extends StatelessWidget {
  const ChatGptSubscriptionPane({this.controller, super.key});
  final ChatGptSubscriptionController? controller;

  @override
  Widget build(BuildContext context) {
    final state = controller ?? context.read<ChatGptSubscriptionController?>();
    if (state == null) return const SizedBox.shrink();
    if (!state.initialized && !state.busy) {
      unawaited(Future<void>.microtask(state.load));
    }
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final strings = context.l10n;
        final profile = state.activeProfile;
        final model =
            state.models.any((entry) => entry.slug == state.selectedModel)
            ? state.selectedModel
            : null;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.chatGptSubscriptionTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (!state.supported)
                Text(strings.chatGptDesktopOnly)
              else ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    TextButton(
                      key: const Key('chatgpt.continue'),
                      onPressed: state.busy ? null : state.signIn,
                      child: Text(strings.chatGptContinue),
                    ),
                    if (state.busy)
                      TextButton(
                        key: const Key('chatgpt.cancel'),
                        onPressed: state.cancel,
                        child: Text(strings.cancel),
                      ),
                    if (profile?.signedIn == true ||
                        profile?.recoveryRequired == true)
                      TextButton(
                        key: const Key('chatgpt.sign_out'),
                        onPressed: state.busy ? null : state.signOut,
                        child: Text(strings.chatGptSignOut),
                      ),
                    TextButton(
                      key: const Key('chatgpt.usage'),
                      onPressed: () => launchUrl(
                        Uri.parse('https://chatgpt.com/settings/usage'),
                        mode: LaunchMode.externalApplication,
                      ),
                      child: Text(strings.chatGptUsage),
                    ),
                  ],
                ),
                if (state.profiles.isNotEmpty)
                  DropdownButton<String>(
                    key: const Key('chatgpt.account'),
                    isExpanded: true,
                    value: state.activeClientId,
                    hint: Text(strings.chatGptChooseAccount),
                    items: [
                      for (var i = 0; i < state.profiles.length; i++)
                        DropdownMenuItem(
                          value: state.profiles[i].clientId,
                          child: Text(
                            _accountLabel(
                              state.profiles[i].email,
                              strings.chatGptAccount,
                              i + 1,
                            ),
                          ),
                        ),
                    ],
                    onChanged: state.busy
                        ? null
                        : (clientId) {
                            if (clientId == null) return;
                            final selected = state.profiles.firstWhere(
                              (entry) => entry.clientId == clientId,
                            );
                            if (selected.signedIn) {
                              unawaited(state.selectAccount(clientId));
                            } else {
                              unawaited(state.signIn(clientId: clientId));
                            }
                          },
                  ),
                if (profile?.signedIn == true &&
                    profile?.planEnabled == true) ...[
                  DropdownButton<String>(
                    key: const Key('chatgpt.model'),
                    isExpanded: true,
                    value: model,
                    hint: Text(strings.chatGptChooseModel),
                    items: [
                      for (final entry in state.models)
                        DropdownMenuItem(
                          value: entry.slug,
                          child: Text(entry.displayName),
                        ),
                    ],
                    onChanged: state.busy
                        ? null
                        : (value) {
                            if (value != null) {
                              unawaited(state.selectModel(value));
                            }
                          },
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      TextButton(
                        key: const Key('chatgpt.refresh_models'),
                        onPressed: state.busy ? null : state.refreshModels,
                        child: Text(strings.chatGptRefreshModels),
                      ),
                      TextButton(
                        key: const Key('chatgpt.verify_access'),
                        onPressed: state.busy || model == null
                            ? null
                            : state.verifyAccess,
                        child: Text(strings.chatGptVerifyAccess),
                      ),
                    ],
                  ),
                  Text(
                    state.accessReceipt == null
                        ? strings.chatGptAccessUnchecked
                        : strings.chatGptAccessVerified,
                    key: const Key('chatgpt.access_status'),
                  ),
                ],
                if (profile?.signedIn == true && profile?.planEnabled == false)
                  Text(strings.chatGptPlanPermissionRequired),
                if (state.busy)
                  Text(
                    strings.chatGptWorking,
                    key: const Key('chatgpt.progress'),
                  ),
                if (profile?.recoveryRequired == true)
                  Text(strings.chatGptSignInRequired),
                if (state.revocationConfirmed == false ||
                    state.hasUnconfirmedCleanup)
                  Text(
                    strings.chatGptRevocationUnconfirmed,
                    key: const Key('chatgpt.revocation_status'),
                  ),
                if (state.errorCode != null &&
                    !const {
                      'authorization_cancelled',
                      'model_catalog_cancelled',
                      'inference_cancelled',
                    }.contains(state.errorCode))
                  Text(
                    strings.chatGptConnectionError,
                    key: const Key('chatgpt.error'),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}

String _accountLabel(String? email, String fallback, int ordinal) =>
    '${email ?? fallback} · $ordinal';
