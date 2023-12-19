part of 'state.dart';

@freezed
class PurchasesNotifierState with _$PurchasesNotifierState {
  const factory PurchasesNotifierState({
    @Default([]) final List<ProductDetails> iAppSubscriptions,
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
  Future<void> onLoad() async {
    if (PlatformInfo.isNativeMobile) {
      final isStoreAvailable =
          await dto.purchasesIapGoogleAppleImpl.checkIsStoreAvailable();
      if (isStoreAvailable) {
        final subscriptions =
            await dto.purchasesIapGoogleAppleImpl.getProducts();
        _emitLoaded(
          value.value.copyWith(iAppSubscriptions: subscriptions),
        );
      }
    }
  }

  Future<void> buySubscription(final ProductDetails details) async {
    await dto.purchasesIapGoogleAppleImpl.buySubscription(
      PurchaseParam(
        productDetails: details,
        applicationUserName: dto.userNotifier.remoteValue.value.id.value,
      ),
    );
    await dto.purchasesRepository.verifySubscription(details);
  }

  void _emitLoaded(final PurchasesNotifierState state) {
    value = LoadableContainer.loaded(state);
  }
}
