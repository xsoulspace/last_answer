part of abstract;

typedef UserModelId = String;

@immutable
@Freezed(
  fromJson: true,
  toJson: true,
  equal: true,
  addImplicitFinal: true,
  copyWith: true,
)
class UserModel with _$UserModel {
  @JsonSerializable(
    explicitToJson: true,
  )
  const factory UserModel({
    required final UserModelId id,
  }) = _UserModel;

  factory UserModel.fromJson(final Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
