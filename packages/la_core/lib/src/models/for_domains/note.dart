// ignore_for_file: invalid_annotation_target

part of '../models.dart';

@freezed
class BasicProjectIdModel with _$BasicProjectIdModel {
  const factory BasicProjectIdModel({
    required final String value,
  }) = _BasicProjectIdModel;
  factory BasicProjectIdModel.fromJson(final String value) =>
      BasicProjectIdModel(value: value);
  static String toJson(final BasicProjectIdModel obj) => obj.value;
}

@immutable
@Freezed(
  unionValueCase: FreezedUnionCase.pascal,
  unionKey: 'runtime_type',
)
class BasicProjectModel with _$BasicProjectModel {
  @JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
  const factory BasicProjectModel.note({
    @JsonKey(
      fromJson: BasicProjectIdModel.fromJson,
      toJson: BasicProjectIdModel.toJson,
    )
        required final BasicProjectIdModel id,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    required final bool isCompleted,
    required final ProjectType projectType,
    required final UserModelId ownerId,
    required final int? charactersLimit,
    // TODO(arenukvern): add quill
    required final String note,
  }) = NoteProjectModel;
  factory BasicProjectModel.fromJson(final Map<String, dynamic> json) =>
      _$BasicProjectModelFromJson(json);
}
