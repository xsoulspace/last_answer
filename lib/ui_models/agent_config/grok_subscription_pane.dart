import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/data_agents/subscriptions/grok_subscription_controller.dart';
import 'package:xsoulspace_inference_xai/xsoulspace_inference_xai.dart';

/// Account pane for Last Answer's own Grok client registration.
class GrokSubscriptionPane extends StatelessWidget {
  const GrokSubscriptionPane({this.controller, super.key});
  final GrokSubscriptionController? controller;

  @override
  Widget build(BuildContext context) {
    final state = controller ?? context.read<GrokSubscriptionController?>();
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
        String accountLabel(int index) {
          final account = state.profiles[index];
          final email = account.email ?? strings.grokAccount;
          return '$email · ${index + 1}';
        }
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(strings.grokSubscriptionTitle, style: context.laUi.emphasis),
              if (!state.supported)
                Text(strings.grokDesktopOnly)
              else ...[
                if (!state.registered) ...[
                  Text(
                    strings.grokClientNotRegistered,
                    key: const Key('grok.registration'),
                  ),
                  const Text(
                    '${LastAnswerGrokRegistration.referrer}\n'
                    '${LastAnswerGrokRegistration.redirectUri}',
                    key: Key('grok.registration_facts'),
                  ),
                  Text(strings.grokRegistrationHint),
                ],
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    LaButton(
                      key: const Key('grok.continue'),
                      variant: LaButtonVariant.ghost,
                      onPressed: state.busy || !state.registered
                          ? null
                          : state.signIn,
                      label: strings.grokContinue,
                    ),
                    LaButton(
                      key: const Key('grok.device'),
                      variant: LaButtonVariant.ghost,
                      onPressed: state.busy || !state.registered
                          ? null
                          : state.signInWithDevice,
                      label: strings.grokDeviceSignIn,
                    ),
                    if (state.busy)
                      LaButton(
                        key: const Key('grok.cancel'),
                        variant: LaButtonVariant.ghost,
                        onPressed: state.cancel,
                        label: strings.cancel,
                      ),
                    if (profile?.signedIn == true)
                      LaButton(
                        key: const Key('grok.sign_out'),
                        variant: LaButtonVariant.ghost,
                        onPressed: state.busy ? null : state.signOut,
                        label: strings.grokSignOut,
                      ),
                  ],
                ),
                if (state.devicePrompt != null)
                  Text(
                    '${state.devicePrompt!.userCode}\n'
                    '${state.devicePrompt!.verificationUri}',
                    key: const Key('grok.device_code'),
                  ),
                if (state.profiles.isNotEmpty)
                  LaSelect<String>(
                    key: const Key('grok.account'),
                    expand: true,
                    value: state.activeAccountId,
                    placeholder: strings.grokChooseAccount,
                    items: [
                      for (var i = 0; i < state.profiles.length; i++)
                        LaSelectItem(
                          value: state.profiles[i].subject,
                          label: accountLabel(i),
                        ),
                    ],
                    onChanged: state.busy
                        ? null
                        : (subject) {
                            if (subject == null) return;
                            final selected = state.profiles.firstWhere(
                              (entry) => entry.subject == subject,
                            );
                            if (selected.signedIn) {
                              unawaited(state.selectAccount(subject));
                            } else {
                              unawaited(state.signIn(subject: subject));
                            }
                          },
                  ),
                if (profile?.signedIn == true &&
                    profile?.planEnabled == true) ...[
                  LaSelect<String>(
                    key: const Key('grok.model'),
                    expand: true,
                    value: model,
                    placeholder: strings.grokChooseModel,
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
                        key: const Key('grok.refresh_models'),
                        variant: LaButtonVariant.ghost,
                        onPressed: state.busy ? null : state.refreshModels,
                        label: strings.grokRefreshModels,
                      ),
                      LaButton(
                        key: const Key('grok.verify_access'),
                        variant: LaButtonVariant.ghost,
                        onPressed: state.busy || model == null
                            ? null
                            : state.verifyAccess,
                        label: strings.grokVerifyAccess,
                      ),
                    ],
                  ),
                  Text(
                    state.accessReceipt == null
                        ? strings.grokAccessUnchecked
                        : strings.grokAccessVerified,
                    key: const Key('grok.access_status'),
                  ),
                ],
                if (profile?.signedIn == true && profile?.planEnabled == false)
                  Text(strings.grokPlanPermissionRequired),
                if (state.busy)
                  Text(strings.grokWorking, key: const Key('grok.progress')),
                if (state.revocationConfirmed == false)
                  Text(
                    strings.grokRevocationUnconfirmed,
                    key: const Key('grok.revocation_status'),
                  ),
                if (state.errorCode != null &&
                    state.errorCode != 'authorization_cancelled' &&
                    state.errorCode != 'client_not_registered')
                  Text(
                    strings.grokConnectionError,
                    key: const Key('grok.error'),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}
