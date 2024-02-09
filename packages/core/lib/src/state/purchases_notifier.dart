part of 'state.dart';

class PurchasesNotifierDto {
  PurchasesNotifierDto(final BuildContext context)
      : remoteUserNotifier = context.read(),
        purchasesRepository = context.read();
  final RemoteUserNotifier remoteUserNotifier;
  final PurchasesRepository purchasesRepository;
}

class PurchasesNotifier
    extends ValueNotifier<LoadableContainer<PurchasesModel>> {
  PurchasesNotifier(final BuildContext context)
      : dto = PurchasesNotifierDto(context),
        super(const LoadableContainer(value: PurchasesModel.empty));

  final PurchasesNotifierDto dto;

  Future<void> onLocalUserLoad() async {
    final localPurchases = await dto.purchasesRepository.getLocalPurchases();
    _emitLoaded(localPurchases);
  }

  Future<void> onRemoteUserLoad() async {
    final purchases = await dto.purchasesRepository
        .mergePurchases(localPurchases: value.value);
    _emitLoaded(purchases);
  }

  Future<void> recordNewDay() async {
    final purchases = await dto.purchasesRepository.recordNewDay();
    _emitLoaded(purchases);
  }

  void _emitLoaded(final PurchasesModel state) {
    value = LoadableContainer.loaded(state);
  }
}
