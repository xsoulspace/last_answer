import 'package:flutter/foundation.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/settings/views/iap_views.dart';
import 'package:lastanswer/settings/views/supporter_view/supporter_view.dart';
import 'package:lastanswer/settings/widgets/settings_list_container.dart';

class MyAccountViewRemoteImpl extends StatelessWidget {
  const MyAccountViewRemoteImpl({super.key});

  @override
  Widget build(final BuildContext context) {
    final userNotifier = context.watch<RemoteUserNotifier>();
    final isAuthorized = userNotifier.isAuthorized;
    return LaSelectionArea(
      child: isAuthorized || kDebugMode
          ? const _AuthorizedView()
          : const _UnauthorizedView(),
    );
  }
}

class _AuthorizedView extends HookWidget {
  const _AuthorizedView();
  static const isPaymentsAvailable = false;

  @override
  Widget build(final BuildContext context) {
    // The kit tab grammar (Material NestedScrollView/SliverAppBar/TabBar
    // retired): a centered LaTabStrip over a PageView pager — the pinned
    // sliver added nothing here, the strip was the only header content.
    final entries = <(String, Widget)>[
      if (isPaymentsAvailable) ('Subscription', const SubscriptionView()),
      if (isPaymentsAvailable)
        ('Payment History', const PaymentsHistoryListView()),
      ('Become Pro', const SupportAppView()),
      ('Profile', const ProfileView()),
    ];
    final pageController = usePageController();
    final currentTab = useState(0);
    return Column(
      children: [
        LaTabStrip(
          labels: [for (final (label, _) in entries) label],
          currentIndex: currentTab.value,
          centerAligned: true,
          onTap: (final index) => pageController.animateToPage(
            index,
            duration: context.laUi.motionSettle,
            curve: context.laUi.motionCurve,
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: PageView(
              controller: pageController,
              onPageChanged: (final index) => currentTab.value = index,
              children: [for (final (_, view) in entries) view],
            ),
          ),
        ),
      ],
    );
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(final BuildContext context) {
    final userNotifier = context.watch<UserNotifier>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Any information you creating are still be saved on your device.',
        ),
        const Gap(24),
        LaButton(
          onPressed: userNotifier.logout,
          variant: LaButtonVariant.ghost,
          label: 'Sign out',
        ),
        const Gap(24),
        HookBuilder(
          builder: (final context) {
            final isLoading = useState(false);
            return LaBox(
              border: BorderSide(color: context.laUi.danger),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Text(
                    context.l10n.danger,
                    style: context.laUi.body.copyWith(
                      color: context.laUi.danger,
                    ),
                  ),
                  const Spacer(),
                  if (isLoading.value)
                    const LaSpinner()
                  else
                    LaButton(
                      variant: LaButtonVariant.destructiveGhost,
                      label: context.l10n.deleteMyAccount,
                      onPressed: () async {
                        isLoading.value = true;
                        final shouldProceed = await showLaConfirm(
                          context,
                          title: context.l10n.areYouSure,
                          cancelLabel: context.l10n.cancel,
                          confirmLabel: context.l10n.delete,
                          destructive: true,
                          // TODO(arenukvern): add l10n,
                          message:
                              // ignore: lines_longer_than_80_chars
                              'Your account will be deleted. \n\n- All projects will be not deleted since it is stored only your device. \n- Any payment history will be deleted and cannot be restored.',
                        );
                        if (shouldProceed) {
                          await userNotifier.deleteRemoteUser();
                        }

                        isLoading.value = false;
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _UnauthorizedView extends StatelessWidget {
  const _UnauthorizedView();

  @override
  Widget build(final BuildContext context) => SettingsListContainer(
    builder: (final context, final leftColumnWidth) => [
      Text('Log In', style: context.laUi.display),
      const Gap(24),
      const Text(
        'Any projects you created will still be saved on your device.',
      ),
      const Gap(24),
      const GoogleSignInButton(),
    ],
  );
}
