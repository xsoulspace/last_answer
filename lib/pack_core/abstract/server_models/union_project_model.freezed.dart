// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'union_project_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

BasicProjectModel _$BasicProjectModelFromJson(Map<String, dynamic> json) {
  switch (json['runtime_type']) {
    case 'NoteProjectModel':
      return NoteProjectModel.fromJson(json);
    case 'IdeaProjectModel':
      return IdeaProjectModel.fromJson(json);

    default:
      throw CheckedFromJsonException(json, 'runtime_type', 'BasicProjectModel',
          'Invalid union type "${json['runtime_type']}"!');
  }
}

/// @nodoc
mixin _$BasicProjectModel {
  ProjectFolderId get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_completed')
  bool get isCompleted => throw _privateConstructorUsedError;
  @JsonKey(name: 'project_type')
  ProjectType get projectType => throw _privateConstructorUsedError;
  @JsonKey(name: 'owner_id')
  UserModelId get ownerId => throw _privateConstructorUsedError;
  @JsonKey(name: 'folder_id')
  ProjectFolderId get folderId => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            ProjectFolderId id,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'is_completed') bool isCompleted,
            @JsonKey(name: 'project_type') ProjectType projectType,
            @JsonKey(name: 'owner_id') UserModelId ownerId,
            @JsonKey(name: 'folder_id') ProjectFolderId folderId,
            @JsonKey(name: 'characters_limit') int? charactersLimit,
            String note)
        noteProjectModel,
    required TResult Function(
            ProjectFolderId id,
            String title,
            @JsonKey(name: 'created_at')
                DateTime createdAt,
            @JsonKey(name: 'updated_at')
                DateTime updatedAt,
            @JsonKey(name: 'is_completed')
                bool isCompleted,
            @JsonKey(name: 'project_type')
                ProjectType projectType,
            @JsonKey(name: 'owner_id')
                UserModelId ownerId,
            @JsonKey(name: 'folder_id')
                ProjectFolderId folderId,
            @JsonKey(name: 'new_answer_text')
                String newAnswerText,
            @JsonKey(name: 'new_question_id', fromJson: fromIntToString, toJson: fromStringToInt)
                IdeaProjectQuestionId newQuestionId)
        ideaProjectModel,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(
            ProjectFolderId id,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'is_completed') bool isCompleted,
            @JsonKey(name: 'project_type') ProjectType projectType,
            @JsonKey(name: 'owner_id') UserModelId ownerId,
            @JsonKey(name: 'folder_id') ProjectFolderId folderId,
            @JsonKey(name: 'characters_limit') int? charactersLimit,
            String note)?
        noteProjectModel,
    TResult Function(
            ProjectFolderId id,
            String title,
            @JsonKey(name: 'created_at')
                DateTime createdAt,
            @JsonKey(name: 'updated_at')
                DateTime updatedAt,
            @JsonKey(name: 'is_completed')
                bool isCompleted,
            @JsonKey(name: 'project_type')
                ProjectType projectType,
            @JsonKey(name: 'owner_id')
                UserModelId ownerId,
            @JsonKey(name: 'folder_id')
                ProjectFolderId folderId,
            @JsonKey(name: 'new_answer_text')
                String newAnswerText,
            @JsonKey(name: 'new_question_id', fromJson: fromIntToString, toJson: fromStringToInt)
                IdeaProjectQuestionId newQuestionId)?
        ideaProjectModel,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            ProjectFolderId id,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'is_completed') bool isCompleted,
            @JsonKey(name: 'project_type') ProjectType projectType,
            @JsonKey(name: 'owner_id') UserModelId ownerId,
            @JsonKey(name: 'folder_id') ProjectFolderId folderId,
            @JsonKey(name: 'characters_limit') int? charactersLimit,
            String note)?
        noteProjectModel,
    TResult Function(
            ProjectFolderId id,
            String title,
            @JsonKey(name: 'created_at')
                DateTime createdAt,
            @JsonKey(name: 'updated_at')
                DateTime updatedAt,
            @JsonKey(name: 'is_completed')
                bool isCompleted,
            @JsonKey(name: 'project_type')
                ProjectType projectType,
            @JsonKey(name: 'owner_id')
                UserModelId ownerId,
            @JsonKey(name: 'folder_id')
                ProjectFolderId folderId,
            @JsonKey(name: 'new_answer_text')
                String newAnswerText,
            @JsonKey(name: 'new_question_id', fromJson: fromIntToString, toJson: fromStringToInt)
                IdeaProjectQuestionId newQuestionId)?
        ideaProjectModel,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NoteProjectModel value) noteProjectModel,
    required TResult Function(IdeaProjectModel value) ideaProjectModel,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(NoteProjectModel value)? noteProjectModel,
    TResult Function(IdeaProjectModel value)? ideaProjectModel,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NoteProjectModel value)? noteProjectModel,
    TResult Function(IdeaProjectModel value)? ideaProjectModel,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BasicProjectModelCopyWith<BasicProjectModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BasicProjectModelCopyWith<$Res> {
  factory $BasicProjectModelCopyWith(
          BasicProjectModel value, $Res Function(BasicProjectModel) then) =
      _$BasicProjectModelCopyWithImpl<$Res>;
  $Res call(
      {ProjectFolderId id,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      @JsonKey(name: 'is_completed') bool isCompleted,
      @JsonKey(name: 'project_type') ProjectType projectType,
      @JsonKey(name: 'owner_id') UserModelId ownerId,
      @JsonKey(name: 'folder_id') ProjectFolderId folderId});
}

/// @nodoc
class _$BasicProjectModelCopyWithImpl<$Res>
    implements $BasicProjectModelCopyWith<$Res> {
  _$BasicProjectModelCopyWithImpl(this._value, this._then);

  final BasicProjectModel _value;
  // ignore: unused_field
  final $Res Function(BasicProjectModel) _then;

  @override
  $Res call({
    Object? id = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? isCompleted = freezed,
    Object? projectType = freezed,
    Object? ownerId = freezed,
    Object? folderId = freezed,
  }) {
    return _then(_value.copyWith(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as ProjectFolderId,
      createdAt: createdAt == freezed
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: updatedAt == freezed
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isCompleted: isCompleted == freezed
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      projectType: projectType == freezed
          ? _value.projectType
          : projectType // ignore: cast_nullable_to_non_nullable
              as ProjectType,
      ownerId: ownerId == freezed
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as UserModelId,
      folderId: folderId == freezed
          ? _value.folderId
          : folderId // ignore: cast_nullable_to_non_nullable
              as ProjectFolderId,
    ));
  }
}

/// @nodoc
abstract class _$$NoteProjectModelCopyWith<$Res>
    implements $BasicProjectModelCopyWith<$Res> {
  factory _$$NoteProjectModelCopyWith(
          _$NoteProjectModel value, $Res Function(_$NoteProjectModel) then) =
      __$$NoteProjectModelCopyWithImpl<$Res>;
  @override
  $Res call(
      {ProjectFolderId id,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      @JsonKey(name: 'is_completed') bool isCompleted,
      @JsonKey(name: 'project_type') ProjectType projectType,
      @JsonKey(name: 'owner_id') UserModelId ownerId,
      @JsonKey(name: 'folder_id') ProjectFolderId folderId,
      @JsonKey(name: 'characters_limit') int? charactersLimit,
      String note});
}

/// @nodoc
class __$$NoteProjectModelCopyWithImpl<$Res>
    extends _$BasicProjectModelCopyWithImpl<$Res>
    implements _$$NoteProjectModelCopyWith<$Res> {
  __$$NoteProjectModelCopyWithImpl(
      _$NoteProjectModel _value, $Res Function(_$NoteProjectModel) _then)
      : super(_value, (v) => _then(v as _$NoteProjectModel));

  @override
  _$NoteProjectModel get _value => super._value as _$NoteProjectModel;

  @override
  $Res call({
    Object? id = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? isCompleted = freezed,
    Object? projectType = freezed,
    Object? ownerId = freezed,
    Object? folderId = freezed,
    Object? charactersLimit = freezed,
    Object? note = freezed,
  }) {
    return _then(_$NoteProjectModel(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as ProjectFolderId,
      createdAt: createdAt == freezed
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: updatedAt == freezed
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isCompleted: isCompleted == freezed
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      projectType: projectType == freezed
          ? _value.projectType
          : projectType // ignore: cast_nullable_to_non_nullable
              as ProjectType,
      ownerId: ownerId == freezed
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as UserModelId,
      folderId: folderId == freezed
          ? _value.folderId
          : folderId // ignore: cast_nullable_to_non_nullable
              as ProjectFolderId,
      charactersLimit: charactersLimit == freezed
          ? _value.charactersLimit
          : charactersLimit // ignore: cast_nullable_to_non_nullable
              as int?,
      note: note == freezed
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$NoteProjectModel implements NoteProjectModel {
  const _$NoteProjectModel(
      {required this.id,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt,
      @JsonKey(name: 'is_completed') required this.isCompleted,
      @JsonKey(name: 'project_type') required this.projectType,
      @JsonKey(name: 'owner_id') required this.ownerId,
      @JsonKey(name: 'folder_id') required this.folderId,
      @JsonKey(name: 'characters_limit') required this.charactersLimit,
      required this.note,
      final String? $type})
      : $type = $type ?? 'NoteProjectModel';

  factory _$NoteProjectModel.fromJson(Map<String, dynamic> json) =>
      _$$NoteProjectModelFromJson(json);

  @override
  final ProjectFolderId id;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @override
  @JsonKey(name: 'is_completed')
  final bool isCompleted;
  @override
  @JsonKey(name: 'project_type')
  final ProjectType projectType;
  @override
  @JsonKey(name: 'owner_id')
  final UserModelId ownerId;
  @override
  @JsonKey(name: 'folder_id')
  final ProjectFolderId folderId;
  @override
  @JsonKey(name: 'characters_limit')
  final int? charactersLimit;
  @override
  final String note;

  @JsonKey(name: 'runtime_type')
  final String $type;

  @override
  String toString() {
    return 'BasicProjectModel.noteProjectModel(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, isCompleted: $isCompleted, projectType: $projectType, ownerId: $ownerId, folderId: $folderId, charactersLimit: $charactersLimit, note: $note)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NoteProjectModel &&
            const DeepCollectionEquality().equals(other.id, id) &&
            const DeepCollectionEquality().equals(other.createdAt, createdAt) &&
            const DeepCollectionEquality().equals(other.updatedAt, updatedAt) &&
            const DeepCollectionEquality()
                .equals(other.isCompleted, isCompleted) &&
            const DeepCollectionEquality()
                .equals(other.projectType, projectType) &&
            const DeepCollectionEquality().equals(other.ownerId, ownerId) &&
            const DeepCollectionEquality().equals(other.folderId, folderId) &&
            const DeepCollectionEquality()
                .equals(other.charactersLimit, charactersLimit) &&
            const DeepCollectionEquality().equals(other.note, note));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(id),
      const DeepCollectionEquality().hash(createdAt),
      const DeepCollectionEquality().hash(updatedAt),
      const DeepCollectionEquality().hash(isCompleted),
      const DeepCollectionEquality().hash(projectType),
      const DeepCollectionEquality().hash(ownerId),
      const DeepCollectionEquality().hash(folderId),
      const DeepCollectionEquality().hash(charactersLimit),
      const DeepCollectionEquality().hash(note));

  @JsonKey(ignore: true)
  @override
  _$$NoteProjectModelCopyWith<_$NoteProjectModel> get copyWith =>
      __$$NoteProjectModelCopyWithImpl<_$NoteProjectModel>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            ProjectFolderId id,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'is_completed') bool isCompleted,
            @JsonKey(name: 'project_type') ProjectType projectType,
            @JsonKey(name: 'owner_id') UserModelId ownerId,
            @JsonKey(name: 'folder_id') ProjectFolderId folderId,
            @JsonKey(name: 'characters_limit') int? charactersLimit,
            String note)
        noteProjectModel,
    required TResult Function(
            ProjectFolderId id,
            String title,
            @JsonKey(name: 'created_at')
                DateTime createdAt,
            @JsonKey(name: 'updated_at')
                DateTime updatedAt,
            @JsonKey(name: 'is_completed')
                bool isCompleted,
            @JsonKey(name: 'project_type')
                ProjectType projectType,
            @JsonKey(name: 'owner_id')
                UserModelId ownerId,
            @JsonKey(name: 'folder_id')
                ProjectFolderId folderId,
            @JsonKey(name: 'new_answer_text')
                String newAnswerText,
            @JsonKey(name: 'new_question_id', fromJson: fromIntToString, toJson: fromStringToInt)
                IdeaProjectQuestionId newQuestionId)
        ideaProjectModel,
  }) {
    return noteProjectModel(id, createdAt, updatedAt, isCompleted, projectType,
        ownerId, folderId, charactersLimit, note);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(
            ProjectFolderId id,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'is_completed') bool isCompleted,
            @JsonKey(name: 'project_type') ProjectType projectType,
            @JsonKey(name: 'owner_id') UserModelId ownerId,
            @JsonKey(name: 'folder_id') ProjectFolderId folderId,
            @JsonKey(name: 'characters_limit') int? charactersLimit,
            String note)?
        noteProjectModel,
    TResult Function(
            ProjectFolderId id,
            String title,
            @JsonKey(name: 'created_at')
                DateTime createdAt,
            @JsonKey(name: 'updated_at')
                DateTime updatedAt,
            @JsonKey(name: 'is_completed')
                bool isCompleted,
            @JsonKey(name: 'project_type')
                ProjectType projectType,
            @JsonKey(name: 'owner_id')
                UserModelId ownerId,
            @JsonKey(name: 'folder_id')
                ProjectFolderId folderId,
            @JsonKey(name: 'new_answer_text')
                String newAnswerText,
            @JsonKey(name: 'new_question_id', fromJson: fromIntToString, toJson: fromStringToInt)
                IdeaProjectQuestionId newQuestionId)?
        ideaProjectModel,
  }) {
    return noteProjectModel?.call(id, createdAt, updatedAt, isCompleted,
        projectType, ownerId, folderId, charactersLimit, note);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            ProjectFolderId id,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'is_completed') bool isCompleted,
            @JsonKey(name: 'project_type') ProjectType projectType,
            @JsonKey(name: 'owner_id') UserModelId ownerId,
            @JsonKey(name: 'folder_id') ProjectFolderId folderId,
            @JsonKey(name: 'characters_limit') int? charactersLimit,
            String note)?
        noteProjectModel,
    TResult Function(
            ProjectFolderId id,
            String title,
            @JsonKey(name: 'created_at')
                DateTime createdAt,
            @JsonKey(name: 'updated_at')
                DateTime updatedAt,
            @JsonKey(name: 'is_completed')
                bool isCompleted,
            @JsonKey(name: 'project_type')
                ProjectType projectType,
            @JsonKey(name: 'owner_id')
                UserModelId ownerId,
            @JsonKey(name: 'folder_id')
                ProjectFolderId folderId,
            @JsonKey(name: 'new_answer_text')
                String newAnswerText,
            @JsonKey(name: 'new_question_id', fromJson: fromIntToString, toJson: fromStringToInt)
                IdeaProjectQuestionId newQuestionId)?
        ideaProjectModel,
    required TResult orElse(),
  }) {
    if (noteProjectModel != null) {
      return noteProjectModel(id, createdAt, updatedAt, isCompleted,
          projectType, ownerId, folderId, charactersLimit, note);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NoteProjectModel value) noteProjectModel,
    required TResult Function(IdeaProjectModel value) ideaProjectModel,
  }) {
    return noteProjectModel(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(NoteProjectModel value)? noteProjectModel,
    TResult Function(IdeaProjectModel value)? ideaProjectModel,
  }) {
    return noteProjectModel?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NoteProjectModel value)? noteProjectModel,
    TResult Function(IdeaProjectModel value)? ideaProjectModel,
    required TResult orElse(),
  }) {
    if (noteProjectModel != null) {
      return noteProjectModel(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$NoteProjectModelToJson(this);
  }
}

abstract class NoteProjectModel implements BasicProjectModel {
  const factory NoteProjectModel(
      {required final ProjectFolderId id,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      @JsonKey(name: 'updated_at') required final DateTime updatedAt,
      @JsonKey(name: 'is_completed') required final bool isCompleted,
      @JsonKey(name: 'project_type') required final ProjectType projectType,
      @JsonKey(name: 'owner_id') required final UserModelId ownerId,
      @JsonKey(name: 'folder_id') required final ProjectFolderId folderId,
      @JsonKey(name: 'characters_limit') required final int? charactersLimit,
      required final String note}) = _$NoteProjectModel;

  factory NoteProjectModel.fromJson(Map<String, dynamic> json) =
      _$NoteProjectModel.fromJson;

  @override
  ProjectFolderId get id => throw _privateConstructorUsedError;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;
  @override
  @JsonKey(name: 'is_completed')
  bool get isCompleted => throw _privateConstructorUsedError;
  @override
  @JsonKey(name: 'project_type')
  ProjectType get projectType => throw _privateConstructorUsedError;
  @override
  @JsonKey(name: 'owner_id')
  UserModelId get ownerId => throw _privateConstructorUsedError;
  @override
  @JsonKey(name: 'folder_id')
  ProjectFolderId get folderId => throw _privateConstructorUsedError;
  @JsonKey(name: 'characters_limit')
  int? get charactersLimit => throw _privateConstructorUsedError;
  String get note => throw _privateConstructorUsedError;
  @override
  @JsonKey(ignore: true)
  _$$NoteProjectModelCopyWith<_$NoteProjectModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$IdeaProjectModelCopyWith<$Res>
    implements $BasicProjectModelCopyWith<$Res> {
  factory _$$IdeaProjectModelCopyWith(
          _$IdeaProjectModel value, $Res Function(_$IdeaProjectModel) then) =
      __$$IdeaProjectModelCopyWithImpl<$Res>;
  @override
  $Res call(
      {ProjectFolderId id,
      String title,
      @JsonKey(name: 'created_at')
          DateTime createdAt,
      @JsonKey(name: 'updated_at')
          DateTime updatedAt,
      @JsonKey(name: 'is_completed')
          bool isCompleted,
      @JsonKey(name: 'project_type')
          ProjectType projectType,
      @JsonKey(name: 'owner_id')
          UserModelId ownerId,
      @JsonKey(name: 'folder_id')
          ProjectFolderId folderId,
      @JsonKey(name: 'new_answer_text')
          String newAnswerText,
      @JsonKey(name: 'new_question_id', fromJson: fromIntToString, toJson: fromStringToInt)
          IdeaProjectQuestionId newQuestionId});
}

/// @nodoc
class __$$IdeaProjectModelCopyWithImpl<$Res>
    extends _$BasicProjectModelCopyWithImpl<$Res>
    implements _$$IdeaProjectModelCopyWith<$Res> {
  __$$IdeaProjectModelCopyWithImpl(
      _$IdeaProjectModel _value, $Res Function(_$IdeaProjectModel) _then)
      : super(_value, (v) => _then(v as _$IdeaProjectModel));

  @override
  _$IdeaProjectModel get _value => super._value as _$IdeaProjectModel;

  @override
  $Res call({
    Object? id = freezed,
    Object? title = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? isCompleted = freezed,
    Object? projectType = freezed,
    Object? ownerId = freezed,
    Object? folderId = freezed,
    Object? newAnswerText = freezed,
    Object? newQuestionId = freezed,
  }) {
    return _then(_$IdeaProjectModel(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as ProjectFolderId,
      title: title == freezed
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: createdAt == freezed
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: updatedAt == freezed
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isCompleted: isCompleted == freezed
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      projectType: projectType == freezed
          ? _value.projectType
          : projectType // ignore: cast_nullable_to_non_nullable
              as ProjectType,
      ownerId: ownerId == freezed
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as UserModelId,
      folderId: folderId == freezed
          ? _value.folderId
          : folderId // ignore: cast_nullable_to_non_nullable
              as ProjectFolderId,
      newAnswerText: newAnswerText == freezed
          ? _value.newAnswerText
          : newAnswerText // ignore: cast_nullable_to_non_nullable
              as String,
      newQuestionId: newQuestionId == freezed
          ? _value.newQuestionId
          : newQuestionId // ignore: cast_nullable_to_non_nullable
              as IdeaProjectQuestionId,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$IdeaProjectModel implements IdeaProjectModel {
  const _$IdeaProjectModel(
      {required this.id,
      required this.title,
      @JsonKey(name: 'created_at')
          required this.createdAt,
      @JsonKey(name: 'updated_at')
          required this.updatedAt,
      @JsonKey(name: 'is_completed')
          required this.isCompleted,
      @JsonKey(name: 'project_type')
          required this.projectType,
      @JsonKey(name: 'owner_id')
          required this.ownerId,
      @JsonKey(name: 'folder_id')
          required this.folderId,
      @JsonKey(name: 'new_answer_text')
          required this.newAnswerText,
      @JsonKey(name: 'new_question_id', fromJson: fromIntToString, toJson: fromStringToInt)
          required this.newQuestionId,
      final String? $type})
      : $type = $type ?? 'IdeaProjectModel';

  factory _$IdeaProjectModel.fromJson(Map<String, dynamic> json) =>
      _$$IdeaProjectModelFromJson(json);

  @override
  final ProjectFolderId id;
  @override
  final String title;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @override
  @JsonKey(name: 'is_completed')
  final bool isCompleted;
  @override
  @JsonKey(name: 'project_type')
  final ProjectType projectType;
  @override
  @JsonKey(name: 'owner_id')
  final UserModelId ownerId;
  @override
  @JsonKey(name: 'folder_id')
  final ProjectFolderId folderId;
  @override
  @JsonKey(name: 'new_answer_text')
  final String newAnswerText;
  @override
  @JsonKey(
      name: 'new_question_id',
      fromJson: fromIntToString,
      toJson: fromStringToInt)
  final IdeaProjectQuestionId newQuestionId;

  @JsonKey(name: 'runtime_type')
  final String $type;

  @override
  String toString() {
    return 'BasicProjectModel.ideaProjectModel(id: $id, title: $title, createdAt: $createdAt, updatedAt: $updatedAt, isCompleted: $isCompleted, projectType: $projectType, ownerId: $ownerId, folderId: $folderId, newAnswerText: $newAnswerText, newQuestionId: $newQuestionId)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IdeaProjectModel &&
            const DeepCollectionEquality().equals(other.id, id) &&
            const DeepCollectionEquality().equals(other.title, title) &&
            const DeepCollectionEquality().equals(other.createdAt, createdAt) &&
            const DeepCollectionEquality().equals(other.updatedAt, updatedAt) &&
            const DeepCollectionEquality()
                .equals(other.isCompleted, isCompleted) &&
            const DeepCollectionEquality()
                .equals(other.projectType, projectType) &&
            const DeepCollectionEquality().equals(other.ownerId, ownerId) &&
            const DeepCollectionEquality().equals(other.folderId, folderId) &&
            const DeepCollectionEquality()
                .equals(other.newAnswerText, newAnswerText) &&
            const DeepCollectionEquality()
                .equals(other.newQuestionId, newQuestionId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(id),
      const DeepCollectionEquality().hash(title),
      const DeepCollectionEquality().hash(createdAt),
      const DeepCollectionEquality().hash(updatedAt),
      const DeepCollectionEquality().hash(isCompleted),
      const DeepCollectionEquality().hash(projectType),
      const DeepCollectionEquality().hash(ownerId),
      const DeepCollectionEquality().hash(folderId),
      const DeepCollectionEquality().hash(newAnswerText),
      const DeepCollectionEquality().hash(newQuestionId));

  @JsonKey(ignore: true)
  @override
  _$$IdeaProjectModelCopyWith<_$IdeaProjectModel> get copyWith =>
      __$$IdeaProjectModelCopyWithImpl<_$IdeaProjectModel>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            ProjectFolderId id,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'is_completed') bool isCompleted,
            @JsonKey(name: 'project_type') ProjectType projectType,
            @JsonKey(name: 'owner_id') UserModelId ownerId,
            @JsonKey(name: 'folder_id') ProjectFolderId folderId,
            @JsonKey(name: 'characters_limit') int? charactersLimit,
            String note)
        noteProjectModel,
    required TResult Function(
            ProjectFolderId id,
            String title,
            @JsonKey(name: 'created_at')
                DateTime createdAt,
            @JsonKey(name: 'updated_at')
                DateTime updatedAt,
            @JsonKey(name: 'is_completed')
                bool isCompleted,
            @JsonKey(name: 'project_type')
                ProjectType projectType,
            @JsonKey(name: 'owner_id')
                UserModelId ownerId,
            @JsonKey(name: 'folder_id')
                ProjectFolderId folderId,
            @JsonKey(name: 'new_answer_text')
                String newAnswerText,
            @JsonKey(name: 'new_question_id', fromJson: fromIntToString, toJson: fromStringToInt)
                IdeaProjectQuestionId newQuestionId)
        ideaProjectModel,
  }) {
    return ideaProjectModel(id, title, createdAt, updatedAt, isCompleted,
        projectType, ownerId, folderId, newAnswerText, newQuestionId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(
            ProjectFolderId id,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'is_completed') bool isCompleted,
            @JsonKey(name: 'project_type') ProjectType projectType,
            @JsonKey(name: 'owner_id') UserModelId ownerId,
            @JsonKey(name: 'folder_id') ProjectFolderId folderId,
            @JsonKey(name: 'characters_limit') int? charactersLimit,
            String note)?
        noteProjectModel,
    TResult Function(
            ProjectFolderId id,
            String title,
            @JsonKey(name: 'created_at')
                DateTime createdAt,
            @JsonKey(name: 'updated_at')
                DateTime updatedAt,
            @JsonKey(name: 'is_completed')
                bool isCompleted,
            @JsonKey(name: 'project_type')
                ProjectType projectType,
            @JsonKey(name: 'owner_id')
                UserModelId ownerId,
            @JsonKey(name: 'folder_id')
                ProjectFolderId folderId,
            @JsonKey(name: 'new_answer_text')
                String newAnswerText,
            @JsonKey(name: 'new_question_id', fromJson: fromIntToString, toJson: fromStringToInt)
                IdeaProjectQuestionId newQuestionId)?
        ideaProjectModel,
  }) {
    return ideaProjectModel?.call(id, title, createdAt, updatedAt, isCompleted,
        projectType, ownerId, folderId, newAnswerText, newQuestionId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            ProjectFolderId id,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'is_completed') bool isCompleted,
            @JsonKey(name: 'project_type') ProjectType projectType,
            @JsonKey(name: 'owner_id') UserModelId ownerId,
            @JsonKey(name: 'folder_id') ProjectFolderId folderId,
            @JsonKey(name: 'characters_limit') int? charactersLimit,
            String note)?
        noteProjectModel,
    TResult Function(
            ProjectFolderId id,
            String title,
            @JsonKey(name: 'created_at')
                DateTime createdAt,
            @JsonKey(name: 'updated_at')
                DateTime updatedAt,
            @JsonKey(name: 'is_completed')
                bool isCompleted,
            @JsonKey(name: 'project_type')
                ProjectType projectType,
            @JsonKey(name: 'owner_id')
                UserModelId ownerId,
            @JsonKey(name: 'folder_id')
                ProjectFolderId folderId,
            @JsonKey(name: 'new_answer_text')
                String newAnswerText,
            @JsonKey(name: 'new_question_id', fromJson: fromIntToString, toJson: fromStringToInt)
                IdeaProjectQuestionId newQuestionId)?
        ideaProjectModel,
    required TResult orElse(),
  }) {
    if (ideaProjectModel != null) {
      return ideaProjectModel(id, title, createdAt, updatedAt, isCompleted,
          projectType, ownerId, folderId, newAnswerText, newQuestionId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NoteProjectModel value) noteProjectModel,
    required TResult Function(IdeaProjectModel value) ideaProjectModel,
  }) {
    return ideaProjectModel(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(NoteProjectModel value)? noteProjectModel,
    TResult Function(IdeaProjectModel value)? ideaProjectModel,
  }) {
    return ideaProjectModel?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NoteProjectModel value)? noteProjectModel,
    TResult Function(IdeaProjectModel value)? ideaProjectModel,
    required TResult orElse(),
  }) {
    if (ideaProjectModel != null) {
      return ideaProjectModel(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$IdeaProjectModelToJson(this);
  }
}

abstract class IdeaProjectModel implements BasicProjectModel {
  const factory IdeaProjectModel(
      {required final ProjectFolderId id,
      required final String title,
      @JsonKey(name: 'created_at')
          required final DateTime createdAt,
      @JsonKey(name: 'updated_at')
          required final DateTime updatedAt,
      @JsonKey(name: 'is_completed')
          required final bool isCompleted,
      @JsonKey(name: 'project_type')
          required final ProjectType projectType,
      @JsonKey(name: 'owner_id')
          required final UserModelId ownerId,
      @JsonKey(name: 'folder_id')
          required final ProjectFolderId folderId,
      @JsonKey(name: 'new_answer_text')
          required final String newAnswerText,
      @JsonKey(name: 'new_question_id', fromJson: fromIntToString, toJson: fromStringToInt)
          required final IdeaProjectQuestionId newQuestionId}) = _$IdeaProjectModel;

  factory IdeaProjectModel.fromJson(Map<String, dynamic> json) =
      _$IdeaProjectModel.fromJson;

  @override
  ProjectFolderId get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;
  @override
  @JsonKey(name: 'is_completed')
  bool get isCompleted => throw _privateConstructorUsedError;
  @override
  @JsonKey(name: 'project_type')
  ProjectType get projectType => throw _privateConstructorUsedError;
  @override
  @JsonKey(name: 'owner_id')
  UserModelId get ownerId => throw _privateConstructorUsedError;
  @override
  @JsonKey(name: 'folder_id')
  ProjectFolderId get folderId => throw _privateConstructorUsedError;
  @JsonKey(name: 'new_answer_text')
  String get newAnswerText => throw _privateConstructorUsedError;
  @JsonKey(
      name: 'new_question_id',
      fromJson: fromIntToString,
      toJson: fromStringToInt)
  IdeaProjectQuestionId get newQuestionId => throw _privateConstructorUsedError;
  @override
  @JsonKey(ignore: true)
  _$$IdeaProjectModelCopyWith<_$IdeaProjectModel> get copyWith =>
      throw _privateConstructorUsedError;
}
