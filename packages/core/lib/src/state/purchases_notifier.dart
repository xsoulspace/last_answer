part of 'state.dart';

@freezed
class PurchasesNotifierState with _$PurchasesNotifierState {
  const factory PurchasesNotifierState({
    @Default([]) final List<ProductDetails> nativeIASubscriptions,
    @Default(PurchasesModel.empty) final PurchasesModel purchases,
  }) = _PurchasesNotifierState;
  static const empty = PurchasesNotifierState();
}

class PurchasesNotifierDto {
  PurchasesNotifierDto(final BuildContext context)
      : userNotifier = context.read(),
        purchasesRepository = context.read(),
        purchasesIapGoogleAppleImpl =
            PurchasesIap.ofContextAsGoogleAppleImpl(context);
  final UserNotifier userNotifier;
  final PurchasesRepository purchasesRepository;
  final PurchasesIapGoogleAppleImpl purchasesIapGoogleAppleImpl;
}

class PurchasesNotifier
    extends ValueNotifier<LoadableContainer<PurchasesNotifierState>> {
  PurchasesNotifier({
    required this.dto,
  }) : super(const LoadableContainer(value: PurchasesNotifierState.empty));

  factory PurchasesNotifier.provide(final BuildContext context) =>
      PurchasesNotifier(
        dto: PurchasesNotifierDto(context),
      );
  final PurchasesNotifierDto dto;
  StreamSubscription<List<PurchaseDetails>>? _nativeIAPSubscription;
  Future<void> onLoad() async {
    if (PlatformInfo.isNativeMobile) {
      final isStoreAvailable =
          await dto.purchasesIapGoogleAppleImpl.checkIsStoreAvailable();
      _nativeIAPSubscription = dto.purchasesIapGoogleAppleImpl.stream.listen(
        _handleNativeIAP,
        onDone: _onNativeIAPDone,
        onError: _onNativeIAPError,
      );
      if (isStoreAvailable) {
        final subscriptions =
            await dto.purchasesIapGoogleAppleImpl.getProducts();
        _emitLoaded(
          value.value.copyWith(nativeIASubscriptions: subscriptions),
        );
      }
    } else {
      _emitLoaded(value.value);
    }
  }

  Future<void> onLocalUserLoad() async {
    // add if needed
  }
  Future<void> onRemoteUserLoad() async {
    final remoteUserContainer = dto.userNotifier.remoteValue;
    if (remoteUserContainer.isLoading) {
      throw ArgumentError.value('User should be already loaded');
    }
    final user = remoteUserContainer.value;
    if (PlatformInfo.isNativeMobile) {
      await dto.purchasesIapGoogleAppleImpl.restorePurchases(user.id);
    }
    _emitLoaded(
      value.value.copyWith(
        purchases: user.purchases,
      ),
    );
  }

  Future<void> _handleNativeIAP(final List<PurchaseDetails> events) async {
    for (final purchase in events) {
      switch (purchase.status) {
        case PurchaseStatus.canceled:
          break;
        case PurchaseStatus.error:
          break;
        case PurchaseStatus.pending:
          break;
        case PurchaseStatus.purchased:
          if (purchase.pendingCompletePurchase) {
            final verifiedPurchase =
                await dto.purchasesRepository.verifyNativeMobilePurchase(
              productId: ProductModelId.fromRawJson(purchase.productID),
              verificationData:
                  purchase.verificationData.serverVerificationData,
            );
            if (verifiedPurchase == null) {
              assert(false, 'payment verification failed');
              break;
            }
            await dto.purchasesIapGoogleAppleImpl.completePurchase(purchase);
          }
        case PurchaseStatus.restored:
          assert(false, 'not implemented');
      }
    }
  }

  Future<void> _onNativeIAPDone() async {
    await _nativeIAPSubscription?.cancel();
    _nativeIAPSubscription = null;
  }

  void _onNativeIAPError(final dynamic error) {
    //Handle error here
  }

  UserModelId get _remoteUserId => dto.userNotifier.remoteValue.value.id;
  Future<void> restorePurchases() async {
    await dto.purchasesIapGoogleAppleImpl.restorePurchases(_remoteUserId);
  }

  Future<void> makePurchase(final ProductDetails details) async {
    if (PlatformInfo.isNativeMobile) {
      final id = IAPId.byId(details.id);
      final purchaseParam = PurchaseParam(
        productDetails: details,
        applicationUserName: _remoteUserId.value,
      );
      final bool shouldProceed = switch (id) {
        IAPId.proOneTimePurchase =>
          await dto.purchasesIapGoogleAppleImpl.buyNonConsumable(purchaseParam)
      };

      if (shouldProceed != true) {
        debugPrint('Payment aborted');
        return;
      }
      debugPrint('Payment continued');
    }
  }

  void _emitLoaded(final PurchasesNotifierState state) {
    value = LoadableContainer.loaded(state);
  }

  @override
  void dispose() {
    unawaited(_onNativeIAPDone());
    super.dispose();
  }
}
