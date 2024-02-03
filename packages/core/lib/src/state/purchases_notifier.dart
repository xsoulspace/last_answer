part of 'state.dart';

@freezed
class PurchasesNotifierState with _$PurchasesNotifierState {
  const factory PurchasesNotifierState({
    @Default(PurchasesModel.empty) final PurchasesModel purchases,
  }) = _PurchasesNotifierState;
  static const empty = PurchasesNotifierState();
}

class PurchasesNotifierDto {
  PurchasesNotifierDto(final BuildContext context)
      : remoteUserNotifier = context.read(),
        purchasesRepository = context.read();
  final RemoteUserNotifier remoteUserNotifier;
  final PurchasesRepository purchasesRepository;
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
    _emitLoaded(
      value.value.copyWith(
        purchases: user.purchases,
      ),
    );
  }

  UserModelId get _remoteUserId => dto.remoteUserNotifier.value.value.id;

  void _emitLoaded(final PurchasesNotifierState state) {
    value = LoadableContainer.loaded(state);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
