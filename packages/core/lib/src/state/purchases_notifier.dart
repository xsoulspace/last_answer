part of 'state.dart';

class PurchasesNotifierDto {
  PurchasesNotifierDto(final BuildContext context)
      : remoteUserNotifier = context.read(),
        purchasesRepository = context.read(),
        purchasesAdsService = context.read();
  final RemoteUserNotifier remoteUserNotifier;
  final PurchasesRepository purchasesRepository;
  final PurchasesAdsService purchasesAdsService;
}

class PurchasesNotifier extends LoadableStateNotifier<PurchasesModel> {
  PurchasesNotifier(final BuildContext context)
      : dto = PurchasesNotifierDto(context),
        super(PurchasesModel.empty);

  final PurchasesNotifierDto dto;

  Future<void> onLocalUserLoad() async {
    final localPurchases = await dto.purchasesRepository.getLocalPurchases();
    state = localPurchases;
    unawaited(recordNewDay());
  }

  Future<void> onRemoteUserLoad() async {
    final purchases = await dto.purchasesRepository
        .mergePurchases(localPurchases: value.value);
    state = purchases;
  }

  Future<void> recordNewDay() async {
    final purchases = await dto.purchasesRepository.recordNewDay();
    state = purchases;
  }

  bool get isActive => value.value.isActive;
  late final ({String mobile, String desktop}) adUnits = switch (Envs.store) {
    StoreType.appleStore || StoreType.huawaiStore || StoreType.rustore => (
        desktop: '',
        mobile: ''
      ),
    StoreType.snapstore || StoreType.windowsStore => (mobile: '', desktop: ''),
    StoreType.googlePlay => (mobile: 'R-M-5944898-1', desktop: ''),
    StoreType.xsoulspaceWebsite => (
        desktop: 'R-A-5804060-1',
        mobile: 'R-A-5804060-2',
      ),
  };
  bool get isAdSupported =>
      adUnits.mobile.isNotEmpty || adUnits.desktop.isNotEmpty;
  Future<void> watchAd(final BuildContext context) async {
    final toasts = Toasts.of(context);
    final l10n = context.l10n;
    final userNotifier = context.read<UserNotifier>();
    final adsNotifier = context.read<AdsNotifier>();
    final isDark = userNotifier.settings.themeMode == ThemeMode.dark;

    final adInstance = await dto.purchasesAdsService.prepareAdInstance(
      unitIds: (
        isDarkMode: isDark,
        desktop: adUnits.desktop,
        mobile: adUnits.mobile
      ),
    );
    final reward = await adInstance.show();
    if (reward.isRewarded) {
      final updatedPurchases =
          await dto.purchasesRepository.receiveAdVideoReward();
      state = updatedPurchases;
      unawaited(
        Future.wait([
          adsNotifier.onAwareded(),
          toasts.showBottomToast(message: l10n.rewardForAdThankYou(7)),
        ]),
      );
    }
    adInstance.dispose();
  }
}
