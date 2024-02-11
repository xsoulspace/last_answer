part of 'state.dart';

enum AppStatus {
  offline,
  online,
  loading;
}

@freezed
class AppFeaturesModel with _$AppFeaturesModel {
  const factory AppFeaturesModel({
    @Default(false) final bool isRemoteServicesEnabled,
  }) = _AppFeaturesModel;
}

@stateDistributor
class AppFeaturesNotifier extends ValueNotifier<AppFeaturesModel> {
  // ignore: avoid_unused_constructor_parameters
  AppFeaturesNotifier(final BuildContext context)
      : super(const AppFeaturesModel());
}

@freezed
class AppNotifierState with _$AppNotifierState {
  const factory AppNotifierState({
    @Default(AppStatus.loading) final AppStatus status,
  }) = _AppNotifierState;
}

class AppNotifierDto {
  // ignore: avoid_unused_constructor_parameters
  AppNotifierDto(final BuildContext context);
}

class AppNotifier extends ValueNotifier<AppNotifierState> {
  AppNotifier(final BuildContext context)
      : dto = AppNotifierDto(context),
        super(const AppNotifierState());

  final AppNotifierDto dto;

  // TODO(arenukvern): add logic for connection change,
  void updateAppStatus(final AppStatus status) =>
      setValue(value.copyWith(status: status));
}
