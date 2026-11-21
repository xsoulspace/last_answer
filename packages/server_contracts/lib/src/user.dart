// ignore_for_file: invalid_annotation_target

part of 'models.dart';

/// A user id as it crosses the RPC boundary (opaque int-as-string on the
/// wire — the Serverpod user id).
@Freezed(fromJson: false, toJson: false)
sealed class UserModelId with _$UserModelId {
  const factory UserModelId({
    required final String value,
  }) = _UserModelId;
  const UserModelId._();
  factory UserModelId.fromJson(final dynamic value) =>
      UserModelId(value: '$value');
  static const empty = UserModelId(value: '');
  bool get isEmpty => value.isEmpty;
  String toJson() => value;
  int toInt() => int.parse(value);
}

/// The remote user as the app sees it after `getUser` (snake_case on the
/// wire, matching the Serverpod `User` row JSON).
@freezed
sealed class RemoteUserModel with _$RemoteUserModel {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory RemoteUserModel({
    @Default(UserModelId.empty) final UserModelId id,
  }) = _RemoteUserModel;
  factory RemoteUserModel.fromRawJson(final Map<String, dynamic> json) =>
      _$RemoteUserModelFromJson(json);
  factory RemoteUserModel.fromJson(final Map<String, dynamic> json) =>
      _$RemoteUserModelFromJson(json);
  const RemoteUserModel._();
  static const empty = RemoteUserModel();
  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => !isEmpty;
}
