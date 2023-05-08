part of 'auth_cubit.dart';

@freezed
class AuthCubitState with _$AuthCubitState {
  const factory AuthCubitState.unauthorized() = AuthCubitStateUnathorized;
  const factory AuthCubitState.authorized() = AuthCubitStateAuthorized;
}
