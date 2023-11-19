part of 'state.dart';

enum AppStatus {
  offline,
  online,
  loading;
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
  AppNotifier({
    required this.dto,
  }) : super(const AppNotifierState());

  factory AppNotifier.provide(final BuildContext context) => AppNotifier(
        dto: AppNotifierDto(context),
      );
  final AppNotifierDto dto;

  // TODO(arenukvern): add logic for connection change,
  void updateAppStatus(final AppStatus status) =>
      setValue(value.copyWith(status: status));
}
