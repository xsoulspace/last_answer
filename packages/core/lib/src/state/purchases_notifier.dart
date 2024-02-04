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
  Future<void> onLoad() async {
    if (PlatformInfo.isNativeMobile) {
    } else {
      _emitLoaded(value.value);
    }
  }

  Future<void> onLocalUserLoad() async {
    // add if needed
  }
  Future<void> onRemoteUserLoad() async {
    final remoteUserContainer = dto.remoteUserNotifier.value;
    if (remoteUserContainer.isLoading) {
      throw ArgumentError.value('User should be already loaded');
    }
    final user = remoteUserContainer.value;
    if (PlatformInfo.isNativeMobile) {}
    _emitLoaded(user.purchases);
  }

  UserModelId get _remoteUserId => dto.remoteUserNotifier.value.value.id;

  void _emitLoaded(final PurchasesModel state) {
    value = LoadableContainer.loaded(state);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
