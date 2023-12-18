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
        purchasesIapGoogleAppleImpl =
            PurchasesIap.ofContextAsGoogleAppleImpl(context);
  final UserNotifier userNotifier;
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

  void _emitLoaded(final PurchasesNotifierState state) {
    value = LoadableContainer.loaded(state);
  }
}
