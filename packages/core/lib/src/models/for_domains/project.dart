// ignore_for_file: invalid_annotation_target, prefer_constructors_over_static_methods

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
  const factory ProjectModelId.local({
    required final String value,
  }) = ProjectModelLocalId;
  const factory ProjectModelId.remote({
    required final String value,
  }) = ProjectModelRemoteId;
  const ProjectModelId._();
  static ProjectModelLocalId createLocal() =>
      ProjectModelLocalId(value: IdCreator.create());
  static ProjectModelLocalId localFromJson(final String value) =>
      ProjectModelLocalId(value: value);
  static ProjectModelRemoteId remoteFromJson(final String value) =>
      ProjectModelRemoteId(value: value);
  static String toStringJson(final ProjectModelId obj) => obj.value;
  static const remoteEmpty = UserModelRemoteId(value: '');
  static const localEmpty = UserModelLocalId(value: '');
  bool get isEmpty => value.isEmpty;
  bool get isNotEmpty => value.isNotEmpty;
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
      fromJson: ProjectModelId.remoteFromJson,
      toJson: ProjectModelId.toStringJson,
    )
        required final ProjectModelRemoteId remoteId,
    @JsonKey(
      fromJson: ProjectModelId.localFromJson,
      toJson: ProjectModelId.toStringJson,
    )
        required final ProjectModelLocalId localId,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    required final bool isArchived,
    required final ProjectType type,
    @JsonKey(
      fromJson: UserModelId.remoteFromJson,
      toJson: UserModelId.toStringJson,
    )
        required final UserModelRemoteId ownerId,
    required final int? charactersLimit,
    required final DeltaModel note,

    /// after the note is deleted, and after
    /// [daysBeforeDeletion] have passed
    /// the note should be deleted.
    @Default(false)
        final bool isDeleted,
    @Default(30)
        final int daysBeforeDeletion,
  }) = NoteProjectModel;
  factory ProjectModel.fromJson(final Map<String, dynamic> json) =>
      _$ProjectModelFromJson(json);
  factory ProjectModel.fromFirestore(
    final DocumentSnapshot<Map<String, dynamic>> snapshot,
    // ignore: avoid_unused_constructor_parameters
    final SnapshotOptions? options,
  ) {
    final json = snapshot.data()!;
    return ProjectModel.fromJson(json);
  }
  static Map<String, Object?> toFirestore(
    final ProjectModel value,
    final SetOptions? options,
  ) =>
      value.toJson();
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
