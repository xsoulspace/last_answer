import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:lastanswer/_library/widgets/widgets.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/settings/widgets/settings_list_container.dart';

class MyAccountView extends StatelessWidget {
  const MyAccountView({
    super.key,
  });

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final userNotifier = context.watch<RemoteUserNotifier>();
    final isAuthorized = userNotifier.isAuthorized;
    return isAuthorized || kDebugMode
        ? const _AuthorizedView()
        : const _UnauthorizedView();
  }
}

class _AuthorizedView extends StatelessWidget {
  const _AuthorizedView({super.key});

  @override
  Widget build(final BuildContext context) => DefaultTabController(
        length: 3,
        child: NestedScrollView(
          headerSliverBuilder: (final context, final innerBoxIsScrolled) => [
            const SliverAppBar(
              pinned: true,
              toolbarHeight: 0,
              automaticallyImplyLeading: false,
              bottom: TabBar.secondary(
                isScrollable: true,
                tabAlignment: TabAlignment.center,
                tabs: [
                  Tab(text: 'Subscription'),
                  Tab(text: 'Payment History'),
                  Tab(text: 'Profile'),
                ],
              ),
            ),
          ],
          body: const Padding(
            padding: EdgeInsets.all(24),
            child: TabBarView(
              children: [
                SubscriptionView(),
                PaymentsHistoryListView(),
                ProfileView(),
              ],
            ),
          ),
        ),
      );
}

class SubscriptionView extends StatelessWidget {
  const SubscriptionView({super.key});

  @override
  Widget build(final BuildContext context) {
    final userNotifier = context.watch<UserNotifier>();
    final purchasesNotifier = context.watch<PurchasesNotifier>();
    final purchasesContainer = purchasesNotifier.value;

    if (PlatformInfo.isNativeMobile) {
      final nativeIASubscriptions =
          purchasesContainer.value.nativeIASubscriptions;
      return ListView(
        primary: false,
        children: [
          const Gap(24),
          if (nativeIASubscriptions.isEmpty)
            const Text('No plans available.')
          else
            ...nativeIASubscriptions.map(
              (final e) => LoadableWidget(
                builder: (final context, final setLoading, final isLoading) =>
                    PurchasableProductTile(
                  details: e,
                  activeProductId: IAPId.proOneTimePurchase,
                  //  purchasesContainer
                  //     .value.purchases.activePurchase.productId,
                  isLoading: isLoading,
                  onPressed: () async {
                    setLoading(true);
                    // await userNotifier.buySubscription(e);
                    setLoading(false);
                  },
                ),
              ),
            ),
        ],
      );
    } else {
      return const Text('No plans available.');
    }
  }
}

class PurchasableProductTile extends StatelessWidget {
  const PurchasableProductTile({
    required this.details,
    required this.onPressed,
    required this.activeProductId,
    required this.isLoading,
    super.key,
  });
  final bool isLoading;
  final VoidCallback onPressed;
  final ProductDetails details;
  final IAPId activeProductId;
  @override
  Widget build(final BuildContext context) => Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(details.title),
            Text(details.description),
            Text(details.price),
            if (activeProductId.id == details.id)
              const Text('Active')
            else
              TextButton(onPressed: onPressed, child: const Text('Purchase')),
          ],
        ),
      );
}

class PaymentsHistoryListView extends StatelessWidget {
  const PaymentsHistoryListView({super.key});

  @override
  Widget build(final BuildContext context) {
    final userNotifier = context.watch<UserNotifier>();
    return ListView(
      primary: false,
      children: const [
        Gap(24),
        Text('No payment history'),
        Gap(24),
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
        const Gap(24),
        TextButton(
          onPressed: userNotifier.logout,
          child: const Text('Sign out'),
        ),
        const Gap(24),
        LoadableWidget(
          builder: (final context, final setLoading, final isLoading) =>
              DangerZone(
            isLoading: isLoading,
            onRemove: () async {
              setLoading(true);
              final shouldProceed = await Modals.of(context).showWarningDialog(
                title: context.l10n.areYouSure,
                noActionText: context.l10n.cancel,
                yesActionText: context.l10n.delete,
                description:
                    // TODO(arenukvern): add l10n,
                    // ignore: lines_longer_than_80_chars
                    'Your account will be deleted. \n\n- All projects will be not deleted since it is stored only your device. \n- Any payment history will be deleted and cannot be restored.',
              );
              if (shouldProceed == true) {
                await userNotifier.deleteRemoteUser();
              }

              setLoading(false);
            },
            removeText: context.l10n.deleteMyAccount,
          ),
        ),
      ],
    );
  }
}

class _UnauthorizedView extends StatelessWidget {
  const _UnauthorizedView({super.key});

  @override
  Widget build(final BuildContext context) => SettingsListContainer(
        builder: (final context, final leftColumnWidth) => [
          Text(
            'Log In',
            style: context.textTheme.headlineLarge,
          ),
          const Gap(24),
          const Text(
            'Any projects you created will still be saved on your device.',
          ),
          const Gap(24),
          const GoogleSignInButton(),
        ],
      );
}
