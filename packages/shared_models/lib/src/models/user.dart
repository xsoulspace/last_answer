// ignore_for_file: invalid_annotation_target

part of 'models.dart';

@Freezed(fromJson: false, toJson: false)
class UserModelId with _$UserModelId {
  const factory UserModelId({
    required final String value,
  }) = _UserModelId;
  const UserModelId._();
  factory UserModelId.fromJson(final String value) => UserModelId(value: value);
  static const empty = UserModelId(value: '');
  bool get isEmpty => value.isEmpty;
  String toJson() => value;
  int toInt() => int.parse(value);
}
