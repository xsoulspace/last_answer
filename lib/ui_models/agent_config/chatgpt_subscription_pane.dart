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
                style: context.laUi.emphasis,
              ),
              if (!state.supported)
                Text(strings.chatGptDesktopOnly)
              else ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    LaButton(
                      key: const Key('chatgpt.continue'),
                      variant: LaButtonVariant.ghost,
                      onPressed: state.busy ? null : state.signIn,
                      label: strings.chatGptContinue,
                    ),
                    if (state.busy)
                      LaButton(
                        key: const Key('chatgpt.cancel'),
                        variant: LaButtonVariant.ghost,
                        onPressed: state.cancel,
                        label: strings.cancel,
                      ),
                    if (profile?.signedIn == true ||
                        profile?.recoveryRequired == true)
                      LaButton(
                        key: const Key('chatgpt.sign_out'),
                        variant: LaButtonVariant.ghost,
                        onPressed: state.busy ? null : state.signOut,
                        label: strings.chatGptSignOut,
                      ),
                    LaButton(
                      key: const Key('chatgpt.usage'),
                      variant: LaButtonVariant.ghost,
                      onPressed: () => launchUrl(
                        Uri.parse('https://chatgpt.com/settings/usage'),
                        mode: LaunchMode.externalApplication,
                      ),
                      label: strings.chatGptUsage,
                    ),
                  ],
                ),
                if (state.profiles.isNotEmpty)
                  LaSelect<String>(
                    key: const Key('chatgpt.account'),
                    expand: true,
                    value: state.activeClientId,
                    placeholder: strings.chatGptChooseAccount,
                    items: [
                      for (var i = 0; i < state.profiles.length; i++)
                        LaSelectItem(
                          value: state.profiles[i].clientId,
                          label: _accountLabel(
                            state.profiles[i].email,
                            strings.chatGptAccount,
                            i + 1,
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
                  LaSelect<String>(
                    key: const Key('chatgpt.model'),
                    expand: true,
                    value: model,
                    placeholder: strings.chatGptChooseModel,
                    items: [
                      for (final entry in state.models)
                        LaSelectItem(
                          value: entry.slug,
                          label: entry.displayName,
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
                      LaButton(
                        key: const Key('chatgpt.refresh_models'),
                        variant: LaButtonVariant.ghost,
                        onPressed: state.busy ? null : state.refreshModels,
                        label: strings.chatGptRefreshModels,
                      ),
                      LaButton(
                        key: const Key('chatgpt.verify_access'),
                        variant: LaButtonVariant.ghost,
                        onPressed: state.busy || model == null
                            ? null
                            : state.verifyAccess,
                        label: strings.chatGptVerifyAccess,
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
