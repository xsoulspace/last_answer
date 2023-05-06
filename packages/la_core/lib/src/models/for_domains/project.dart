// ignore_for_file: invalid_annotation_target

part of '../models.dart';

/// The JsonValue should be aligned with Union Type Name
enum ProjectType {
  @JsonValue('NoteProjectModel')
  note,
  @JsonValue('IdeaProjectModel')
  idea,
  @JsonValue('StoryProjectModel')
  story,
}

@freezed
class ProjectModelId with _$ProjectModelId {
  const factory ProjectModelId({
    required final String value,
  }) = _ProjectModelId;
  factory ProjectModelId.fromJson(final String value) =>
      ProjectModelId(value: value);
  static String toStringJson(final ProjectModelId obj) => obj.value;
}

@immutable
@Freezed(
  unionValueCase: FreezedUnionCase.pascal,
  unionKey: 'type',
)
class ProjectModel with _$ProjectModel {
  @JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
  const factory ProjectModel.note({
    @JsonKey(
      fromJson: ProjectModelId.fromJson,
      toJson: ProjectModelId.toStringJson,
    )
        required final ProjectModelId id,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    required final bool isArchived,
    required final ProjectType type,
    required final UserModelId ownerId,
    required final int? charactersLimit,
    required final DeltaModel note,
  }) = NoteProjectModel;
  factory ProjectModel.fromJson(final Map<String, dynamic> json) =>
      _$ProjectModelFromJson(json);
}

@immutable
@Freezed()
class DeltaModel with _$DeltaModel {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory DeltaModel({
    @JsonKey(
      fromJson: DeltaModel._deltaFromJson,
      toJson: DeltaModel._deltaToJson,
    )
        required final Delta value,
  }) = _DeltaModel;
  const DeltaModel._();
  factory DeltaModel.fromJson(final Map<String, dynamic> json) =>
      _$DeltaModelFromJson(json);

  Document toDocument() => Document.fromDelta(value);

  static Delta _deltaFromJson(final String value) =>
      Delta.fromJson(jsonDecode(value));

  static String _deltaToJson(final Delta value) => jsonEncode(value.toJson());
}
