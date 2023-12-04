import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_provider.freezed.dart';

@freezed
class ProviderResponseModel with _$ProviderResponseModel {
  const factory ProviderResponseModel({
    required final String token,
  }) = _ProviderResponseModel;
}

abstract interface class AuthProvider {
  AuthProvider._();
  Future<ProviderResponseModel> getCredentials();
}
