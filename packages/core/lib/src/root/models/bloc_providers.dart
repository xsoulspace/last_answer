part of 'models.dart';

@freezed
class BlocProvidersModel with _$BlocProvidersModel {
  const factory BlocProvidersModel({
    required final Create<AuthCubit> authCubit,
  }) = _BlocProvidersModel;

  factory BlocProvidersModel.appRuntime() => BlocProvidersModel(
        authCubit: (final context) =>
            AuthCubit(dto: AuthCubitDto(context: context)),
      );
  factory BlocProvidersModel.mock() => BlocProvidersModel(
        authCubit: (final context) =>
            AuthCubit(dto: AuthCubitDto(context: context)),
      );
}
