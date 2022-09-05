import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lastanswer/pack_core/abstract/primitives/has_id.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

typedef UserModelId = String;

enum UserStatus {
  online,
  offline,
}

@immutable
@Freezed(
  fromJson: true,
  toJson: true,
  equal: true,
  addImplicitFinal: true,
  copyWith: true,
)
class UserModel with _$UserModel implements HasId {
  @JsonSerializable(
    explicitToJson: true,
  )
  const factory UserModel({
    required final UserModelId id,
    required final UserStatus status,
    required final String username,
  }) = _UserModel;
  factory UserModel.fromJson(final Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
  const UserModel._();
  static Map<String, dynamic> modelToJson(final UserModel model) =>
      model.toJson();
  static const UserModel zero = UserModel(
    id: '',
    status: UserStatus.offline,
    username: '',
  );
}