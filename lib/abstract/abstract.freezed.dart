// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of abstract;

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

ProjectFolderModel _$ProjectFolderModelFromJson(Map<String, dynamic> json) {
  return _ProjectFolderModel.fromJson(json);
}

/// @nodoc
mixin _$ProjectFolderModel {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'owner_id')
  String get ownerId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ProjectFolderModelCopyWith<ProjectFolderModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProjectFolderModelCopyWith<$Res> {
  factory $ProjectFolderModelCopyWith(
          ProjectFolderModel value, $Res Function(ProjectFolderModel) then) =
      _$ProjectFolderModelCopyWithImpl<$Res>;
  $Res call(
      {String id,
      String title,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      @JsonKey(name: 'owner_id') String ownerId});
}

/// @nodoc
class _$ProjectFolderModelCopyWithImpl<$Res>
    implements $ProjectFolderModelCopyWith<$Res> {
  _$ProjectFolderModelCopyWithImpl(this._value, this._then);

  final ProjectFolderModel _value;
  // ignore: unused_field
  final $Res Function(ProjectFolderModel) _then;

  @override
  $Res call({
    Object? id = freezed,
    Object? title = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? ownerId = freezed,
  }) {
    return _then(_value.copyWith(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
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
      ownerId: ownerId == freezed
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
abstract class _$$_ProjectFolderModelCopyWith<$Res>
    implements $ProjectFolderModelCopyWith<$Res> {
  factory _$$_ProjectFolderModelCopyWith(_$_ProjectFolderModel value,
          $Res Function(_$_ProjectFolderModel) then) =
      __$$_ProjectFolderModelCopyWithImpl<$Res>;
  @override
  $Res call(
      {String id,
      String title,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      @JsonKey(name: 'owner_id') String ownerId});
}

/// @nodoc
class __$$_ProjectFolderModelCopyWithImpl<$Res>
    extends _$ProjectFolderModelCopyWithImpl<$Res>
    implements _$$_ProjectFolderModelCopyWith<$Res> {
  __$$_ProjectFolderModelCopyWithImpl(
      _$_ProjectFolderModel _value, $Res Function(_$_ProjectFolderModel) _then)
      : super(_value, (v) => _then(v as _$_ProjectFolderModel));

  @override
  _$_ProjectFolderModel get _value => super._value as _$_ProjectFolderModel;

  @override
  $Res call({
    Object? id = freezed,
    Object? title = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? ownerId = freezed,
  }) {
    return _then(_$_ProjectFolderModel(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
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
      ownerId: ownerId == freezed
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$_ProjectFolderModel extends _ProjectFolderModel
    with DiagnosticableTreeMixin {
  const _$_ProjectFolderModel(
      {required this.id,
      required this.title,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt,
      @JsonKey(name: 'owner_id') required this.ownerId})
      : super._();

  factory _$_ProjectFolderModel.fromJson(Map<String, dynamic> json) =>
      _$$_ProjectFolderModelFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @override
  @JsonKey(name: 'owner_id')
  final String ownerId;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ProjectFolderModel(id: $id, title: $title, createdAt: $createdAt, updatedAt: $updatedAt, ownerId: $ownerId)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ProjectFolderModel'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('title', title))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('updatedAt', updatedAt))
      ..add(DiagnosticsProperty('ownerId', ownerId));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_ProjectFolderModel &&
            const DeepCollectionEquality().equals(other.id, id) &&
            const DeepCollectionEquality().equals(other.title, title) &&
            const DeepCollectionEquality().equals(other.createdAt, createdAt) &&
            const DeepCollectionEquality().equals(other.updatedAt, updatedAt) &&
            const DeepCollectionEquality().equals(other.ownerId, ownerId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(id),
      const DeepCollectionEquality().hash(title),
      const DeepCollectionEquality().hash(createdAt),
      const DeepCollectionEquality().hash(updatedAt),
      const DeepCollectionEquality().hash(ownerId));

  @JsonKey(ignore: true)
  @override
  _$$_ProjectFolderModelCopyWith<_$_ProjectFolderModel> get copyWith =>
      __$$_ProjectFolderModelCopyWithImpl<_$_ProjectFolderModel>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_ProjectFolderModelToJson(this);
  }
}

abstract class _ProjectFolderModel extends ProjectFolderModel {
  const factory _ProjectFolderModel(
          {required final String id,
          required final String title,
          @JsonKey(name: 'created_at') required final DateTime createdAt,
          @JsonKey(name: 'updated_at') required final DateTime updatedAt,
          @JsonKey(name: 'owner_id') required final String ownerId}) =
      _$_ProjectFolderModel;
  const _ProjectFolderModel._() : super._();

  factory _ProjectFolderModel.fromJson(Map<String, dynamic> json) =
      _$_ProjectFolderModel.fromJson;

  @override
  String get id => throw _privateConstructorUsedError;
  @override
  String get title => throw _privateConstructorUsedError;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;
  @override
  @JsonKey(name: 'owner_id')
  String get ownerId => throw _privateConstructorUsedError;
  @override
  @JsonKey(ignore: true)
  _$$_ProjectFolderModelCopyWith<_$_ProjectFolderModel> get copyWith =>
      throw _privateConstructorUsedError;
}

BasicProjectModel _$BasicProjectModelFromJson(Map<String, dynamic> json) {
  switch (json['runtimeType']) {
    case 'NoteProjectModel':
      return _NoteProjectModel.fromJson(json);
    case 'IdeaProjectModel':
      return _IdeaProjectModel.fromJson(json);

    default:
      throw CheckedFromJsonException(json, 'runtimeType', 'BasicProjectModel',
          'Invalid union type "${json['runtimeType']}"!');
  }
}

/// @nodoc
mixin _$BasicProjectModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'project_type')
  ProjectType get projectType => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'folder_id')
  String get folderId => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String id,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'is_completed') bool isCompleted,
            @JsonKey(name: 'project_type') ProjectType projectType,
            @JsonKey(name: 'user_id') String userId,
            @JsonKey(name: 'folder_id') String folderId,
            @JsonKey(name: 'characters_limit') int? charactersLimit,
            String note)
        noteProjectModel,
    required TResult Function(
            String id,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'project_type') ProjectType projectType,
            @JsonKey(name: 'user_id') String userId,
            @JsonKey(name: 'folder_id') String folderId,
            @JsonKey(name: 'new_answer_text') String newAnswerText,
            @JsonKey(name: 'new_question_id') String newQuestionId,
            String title)
        ideaProjectModel,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(
            String id,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'is_completed') bool isCompleted,
            @JsonKey(name: 'project_type') ProjectType projectType,
            @JsonKey(name: 'user_id') String userId,
            @JsonKey(name: 'folder_id') String folderId,
            @JsonKey(name: 'characters_limit') int? charactersLimit,
            String note)?
        noteProjectModel,
    TResult Function(
            String id,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'project_type') ProjectType projectType,
            @JsonKey(name: 'user_id') String userId,
            @JsonKey(name: 'folder_id') String folderId,
            @JsonKey(name: 'new_answer_text') String newAnswerText,
            @JsonKey(name: 'new_question_id') String newQuestionId,
            String title)?
        ideaProjectModel,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String id,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'is_completed') bool isCompleted,
            @JsonKey(name: 'project_type') ProjectType projectType,
            @JsonKey(name: 'user_id') String userId,
            @JsonKey(name: 'folder_id') String folderId,
            @JsonKey(name: 'characters_limit') int? charactersLimit,
            String note)?
        noteProjectModel,
    TResult Function(
            String id,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'project_type') ProjectType projectType,
            @JsonKey(name: 'user_id') String userId,
            @JsonKey(name: 'folder_id') String folderId,
            @JsonKey(name: 'new_answer_text') String newAnswerText,
            @JsonKey(name: 'new_question_id') String newQuestionId,
            String title)?
        ideaProjectModel,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_NoteProjectModel value) noteProjectModel,
    required TResult Function(_IdeaProjectModel value) ideaProjectModel,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(_NoteProjectModel value)? noteProjectModel,
    TResult Function(_IdeaProjectModel value)? ideaProjectModel,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_NoteProjectModel value)? noteProjectModel,
    TResult Function(_IdeaProjectModel value)? ideaProjectModel,
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
      {String id,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      @JsonKey(name: 'project_type') ProjectType projectType,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'folder_id') String folderId});
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
    Object? projectType = freezed,
    Object? userId = freezed,
    Object? folderId = freezed,
  }) {
    return _then(_value.copyWith(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: createdAt == freezed
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: updatedAt == freezed
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      projectType: projectType == freezed
          ? _value.projectType
          : projectType // ignore: cast_nullable_to_non_nullable
              as ProjectType,
      userId: userId == freezed
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      folderId: folderId == freezed
          ? _value.folderId
          : folderId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
abstract class _$$_NoteProjectModelCopyWith<$Res>
    implements $BasicProjectModelCopyWith<$Res> {
  factory _$$_NoteProjectModelCopyWith(
          _$_NoteProjectModel value, $Res Function(_$_NoteProjectModel) then) =
      __$$_NoteProjectModelCopyWithImpl<$Res>;
  @override
  $Res call(
      {String id,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      @JsonKey(name: 'is_completed') bool isCompleted,
      @JsonKey(name: 'project_type') ProjectType projectType,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'folder_id') String folderId,
      @JsonKey(name: 'characters_limit') int? charactersLimit,
      String note});
}

/// @nodoc
class __$$_NoteProjectModelCopyWithImpl<$Res>
    extends _$BasicProjectModelCopyWithImpl<$Res>
    implements _$$_NoteProjectModelCopyWith<$Res> {
  __$$_NoteProjectModelCopyWithImpl(
      _$_NoteProjectModel _value, $Res Function(_$_NoteProjectModel) _then)
      : super(_value, (v) => _then(v as _$_NoteProjectModel));

  @override
  _$_NoteProjectModel get _value => super._value as _$_NoteProjectModel;

  @override
  $Res call({
    Object? id = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? isCompleted = freezed,
    Object? projectType = freezed,
    Object? userId = freezed,
    Object? folderId = freezed,
    Object? charactersLimit = freezed,
    Object? note = freezed,
  }) {
    return _then(_$_NoteProjectModel(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
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
      userId: userId == freezed
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      folderId: folderId == freezed
          ? _value.folderId
          : folderId // ignore: cast_nullable_to_non_nullable
              as String,
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
class _$_NoteProjectModel
    with DiagnosticableTreeMixin
    implements _NoteProjectModel {
  const _$_NoteProjectModel(
      {required this.id,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt,
      @JsonKey(name: 'is_completed') required this.isCompleted,
      @JsonKey(name: 'project_type') required this.projectType,
      @JsonKey(name: 'user_id') required this.userId,
      @JsonKey(name: 'folder_id') required this.folderId,
      @JsonKey(name: 'characters_limit') required this.charactersLimit,
      required this.note,
      final String? $type})
      : $type = $type ?? 'NoteProjectModel';

  factory _$_NoteProjectModel.fromJson(Map<String, dynamic> json) =>
      _$$_NoteProjectModelFromJson(json);

  @override
  final String id;
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
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'folder_id')
  final String folderId;
  @override
  @JsonKey(name: 'characters_limit')
  final int? charactersLimit;
  @override
  final String note;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'BasicProjectModel.noteProjectModel(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, isCompleted: $isCompleted, projectType: $projectType, userId: $userId, folderId: $folderId, charactersLimit: $charactersLimit, note: $note)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'BasicProjectModel.noteProjectModel'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('updatedAt', updatedAt))
      ..add(DiagnosticsProperty('isCompleted', isCompleted))
      ..add(DiagnosticsProperty('projectType', projectType))
      ..add(DiagnosticsProperty('userId', userId))
      ..add(DiagnosticsProperty('folderId', folderId))
      ..add(DiagnosticsProperty('charactersLimit', charactersLimit))
      ..add(DiagnosticsProperty('note', note));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_NoteProjectModel &&
            const DeepCollectionEquality().equals(other.id, id) &&
            const DeepCollectionEquality().equals(other.createdAt, createdAt) &&
            const DeepCollectionEquality().equals(other.updatedAt, updatedAt) &&
            const DeepCollectionEquality()
                .equals(other.isCompleted, isCompleted) &&
            const DeepCollectionEquality()
                .equals(other.projectType, projectType) &&
            const DeepCollectionEquality().equals(other.userId, userId) &&
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
      const DeepCollectionEquality().hash(userId),
      const DeepCollectionEquality().hash(folderId),
      const DeepCollectionEquality().hash(charactersLimit),
      const DeepCollectionEquality().hash(note));

  @JsonKey(ignore: true)
  @override
  _$$_NoteProjectModelCopyWith<_$_NoteProjectModel> get copyWith =>
      __$$_NoteProjectModelCopyWithImpl<_$_NoteProjectModel>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String id,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'is_completed') bool isCompleted,
            @JsonKey(name: 'project_type') ProjectType projectType,
            @JsonKey(name: 'user_id') String userId,
            @JsonKey(name: 'folder_id') String folderId,
            @JsonKey(name: 'characters_limit') int? charactersLimit,
            String note)
        noteProjectModel,
    required TResult Function(
            String id,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'project_type') ProjectType projectType,
            @JsonKey(name: 'user_id') String userId,
            @JsonKey(name: 'folder_id') String folderId,
            @JsonKey(name: 'new_answer_text') String newAnswerText,
            @JsonKey(name: 'new_question_id') String newQuestionId,
            String title)
        ideaProjectModel,
  }) {
    return noteProjectModel(id, createdAt, updatedAt, isCompleted, projectType,
        userId, folderId, charactersLimit, note);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(
            String id,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'is_completed') bool isCompleted,
            @JsonKey(name: 'project_type') ProjectType projectType,
            @JsonKey(name: 'user_id') String userId,
            @JsonKey(name: 'folder_id') String folderId,
            @JsonKey(name: 'characters_limit') int? charactersLimit,
            String note)?
        noteProjectModel,
    TResult Function(
            String id,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'project_type') ProjectType projectType,
            @JsonKey(name: 'user_id') String userId,
            @JsonKey(name: 'folder_id') String folderId,
            @JsonKey(name: 'new_answer_text') String newAnswerText,
            @JsonKey(name: 'new_question_id') String newQuestionId,
            String title)?
        ideaProjectModel,
  }) {
    return noteProjectModel?.call(id, createdAt, updatedAt, isCompleted,
        projectType, userId, folderId, charactersLimit, note);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String id,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'is_completed') bool isCompleted,
            @JsonKey(name: 'project_type') ProjectType projectType,
            @JsonKey(name: 'user_id') String userId,
            @JsonKey(name: 'folder_id') String folderId,
            @JsonKey(name: 'characters_limit') int? charactersLimit,
            String note)?
        noteProjectModel,
    TResult Function(
            String id,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'project_type') ProjectType projectType,
            @JsonKey(name: 'user_id') String userId,
            @JsonKey(name: 'folder_id') String folderId,
            @JsonKey(name: 'new_answer_text') String newAnswerText,
            @JsonKey(name: 'new_question_id') String newQuestionId,
            String title)?
        ideaProjectModel,
    required TResult orElse(),
  }) {
    if (noteProjectModel != null) {
      return noteProjectModel(id, createdAt, updatedAt, isCompleted,
          projectType, userId, folderId, charactersLimit, note);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_NoteProjectModel value) noteProjectModel,
    required TResult Function(_IdeaProjectModel value) ideaProjectModel,
  }) {
    return noteProjectModel(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(_NoteProjectModel value)? noteProjectModel,
    TResult Function(_IdeaProjectModel value)? ideaProjectModel,
  }) {
    return noteProjectModel?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_NoteProjectModel value)? noteProjectModel,
    TResult Function(_IdeaProjectModel value)? ideaProjectModel,
    required TResult orElse(),
  }) {
    if (noteProjectModel != null) {
      return noteProjectModel(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$_NoteProjectModelToJson(this);
  }
}

abstract class _NoteProjectModel implements BasicProjectModel {
  const factory _NoteProjectModel(
      {required final String id,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      @JsonKey(name: 'updated_at') required final DateTime updatedAt,
      @JsonKey(name: 'is_completed') required final bool isCompleted,
      @JsonKey(name: 'project_type') required final ProjectType projectType,
      @JsonKey(name: 'user_id') required final String userId,
      @JsonKey(name: 'folder_id') required final String folderId,
      @JsonKey(name: 'characters_limit') required final int? charactersLimit,
      required final String note}) = _$_NoteProjectModel;

  factory _NoteProjectModel.fromJson(Map<String, dynamic> json) =
      _$_NoteProjectModel.fromJson;

  @override
  String get id => throw _privateConstructorUsedError;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_completed')
  bool get isCompleted => throw _privateConstructorUsedError;
  @override
  @JsonKey(name: 'project_type')
  ProjectType get projectType => throw _privateConstructorUsedError;
  @override
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @override
  @JsonKey(name: 'folder_id')
  String get folderId => throw _privateConstructorUsedError;
  @JsonKey(name: 'characters_limit')
  int? get charactersLimit => throw _privateConstructorUsedError;
  String get note => throw _privateConstructorUsedError;
  @override
  @JsonKey(ignore: true)
  _$$_NoteProjectModelCopyWith<_$_NoteProjectModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$_IdeaProjectModelCopyWith<$Res>
    implements $BasicProjectModelCopyWith<$Res> {
  factory _$$_IdeaProjectModelCopyWith(
          _$_IdeaProjectModel value, $Res Function(_$_IdeaProjectModel) then) =
      __$$_IdeaProjectModelCopyWithImpl<$Res>;
  @override
  $Res call(
      {String id,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      @JsonKey(name: 'project_type') ProjectType projectType,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'folder_id') String folderId,
      @JsonKey(name: 'new_answer_text') String newAnswerText,
      @JsonKey(name: 'new_question_id') String newQuestionId,
      String title});
}

/// @nodoc
class __$$_IdeaProjectModelCopyWithImpl<$Res>
    extends _$BasicProjectModelCopyWithImpl<$Res>
    implements _$$_IdeaProjectModelCopyWith<$Res> {
  __$$_IdeaProjectModelCopyWithImpl(
      _$_IdeaProjectModel _value, $Res Function(_$_IdeaProjectModel) _then)
      : super(_value, (v) => _then(v as _$_IdeaProjectModel));

  @override
  _$_IdeaProjectModel get _value => super._value as _$_IdeaProjectModel;

  @override
  $Res call({
    Object? id = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? projectType = freezed,
    Object? userId = freezed,
    Object? folderId = freezed,
    Object? newAnswerText = freezed,
    Object? newQuestionId = freezed,
    Object? title = freezed,
  }) {
    return _then(_$_IdeaProjectModel(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: createdAt == freezed
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: updatedAt == freezed
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      projectType: projectType == freezed
          ? _value.projectType
          : projectType // ignore: cast_nullable_to_non_nullable
              as ProjectType,
      userId: userId == freezed
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      folderId: folderId == freezed
          ? _value.folderId
          : folderId // ignore: cast_nullable_to_non_nullable
              as String,
      newAnswerText: newAnswerText == freezed
          ? _value.newAnswerText
          : newAnswerText // ignore: cast_nullable_to_non_nullable
              as String,
      newQuestionId: newQuestionId == freezed
          ? _value.newQuestionId
          : newQuestionId // ignore: cast_nullable_to_non_nullable
              as String,
      title: title == freezed
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$_IdeaProjectModel
    with DiagnosticableTreeMixin
    implements _IdeaProjectModel {
  const _$_IdeaProjectModel(
      {required this.id,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt,
      @JsonKey(name: 'project_type') required this.projectType,
      @JsonKey(name: 'user_id') required this.userId,
      @JsonKey(name: 'folder_id') required this.folderId,
      @JsonKey(name: 'new_answer_text') required this.newAnswerText,
      @JsonKey(name: 'new_question_id') required this.newQuestionId,
      required this.title,
      final String? $type})
      : $type = $type ?? 'IdeaProjectModel';

  factory _$_IdeaProjectModel.fromJson(Map<String, dynamic> json) =>
      _$$_IdeaProjectModelFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @override
  @JsonKey(name: 'project_type')
  final ProjectType projectType;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'folder_id')
  final String folderId;
  @override
  @JsonKey(name: 'new_answer_text')
  final String newAnswerText;
  @override
  @JsonKey(name: 'new_question_id')
  final String newQuestionId;
  @override
  final String title;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'BasicProjectModel.ideaProjectModel(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, projectType: $projectType, userId: $userId, folderId: $folderId, newAnswerText: $newAnswerText, newQuestionId: $newQuestionId, title: $title)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'BasicProjectModel.ideaProjectModel'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('updatedAt', updatedAt))
      ..add(DiagnosticsProperty('projectType', projectType))
      ..add(DiagnosticsProperty('userId', userId))
      ..add(DiagnosticsProperty('folderId', folderId))
      ..add(DiagnosticsProperty('newAnswerText', newAnswerText))
      ..add(DiagnosticsProperty('newQuestionId', newQuestionId))
      ..add(DiagnosticsProperty('title', title));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_IdeaProjectModel &&
            const DeepCollectionEquality().equals(other.id, id) &&
            const DeepCollectionEquality().equals(other.createdAt, createdAt) &&
            const DeepCollectionEquality().equals(other.updatedAt, updatedAt) &&
            const DeepCollectionEquality()
                .equals(other.projectType, projectType) &&
            const DeepCollectionEquality().equals(other.userId, userId) &&
            const DeepCollectionEquality().equals(other.folderId, folderId) &&
            const DeepCollectionEquality()
                .equals(other.newAnswerText, newAnswerText) &&
            const DeepCollectionEquality()
                .equals(other.newQuestionId, newQuestionId) &&
            const DeepCollectionEquality().equals(other.title, title));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(id),
      const DeepCollectionEquality().hash(createdAt),
      const DeepCollectionEquality().hash(updatedAt),
      const DeepCollectionEquality().hash(projectType),
      const DeepCollectionEquality().hash(userId),
      const DeepCollectionEquality().hash(folderId),
      const DeepCollectionEquality().hash(newAnswerText),
      const DeepCollectionEquality().hash(newQuestionId),
      const DeepCollectionEquality().hash(title));

  @JsonKey(ignore: true)
  @override
  _$$_IdeaProjectModelCopyWith<_$_IdeaProjectModel> get copyWith =>
      __$$_IdeaProjectModelCopyWithImpl<_$_IdeaProjectModel>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String id,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'is_completed') bool isCompleted,
            @JsonKey(name: 'project_type') ProjectType projectType,
            @JsonKey(name: 'user_id') String userId,
            @JsonKey(name: 'folder_id') String folderId,
            @JsonKey(name: 'characters_limit') int? charactersLimit,
            String note)
        noteProjectModel,
    required TResult Function(
            String id,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'project_type') ProjectType projectType,
            @JsonKey(name: 'user_id') String userId,
            @JsonKey(name: 'folder_id') String folderId,
            @JsonKey(name: 'new_answer_text') String newAnswerText,
            @JsonKey(name: 'new_question_id') String newQuestionId,
            String title)
        ideaProjectModel,
  }) {
    return ideaProjectModel(id, createdAt, updatedAt, projectType, userId,
        folderId, newAnswerText, newQuestionId, title);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(
            String id,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'is_completed') bool isCompleted,
            @JsonKey(name: 'project_type') ProjectType projectType,
            @JsonKey(name: 'user_id') String userId,
            @JsonKey(name: 'folder_id') String folderId,
            @JsonKey(name: 'characters_limit') int? charactersLimit,
            String note)?
        noteProjectModel,
    TResult Function(
            String id,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'project_type') ProjectType projectType,
            @JsonKey(name: 'user_id') String userId,
            @JsonKey(name: 'folder_id') String folderId,
            @JsonKey(name: 'new_answer_text') String newAnswerText,
            @JsonKey(name: 'new_question_id') String newQuestionId,
            String title)?
        ideaProjectModel,
  }) {
    return ideaProjectModel?.call(id, createdAt, updatedAt, projectType, userId,
        folderId, newAnswerText, newQuestionId, title);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String id,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'is_completed') bool isCompleted,
            @JsonKey(name: 'project_type') ProjectType projectType,
            @JsonKey(name: 'user_id') String userId,
            @JsonKey(name: 'folder_id') String folderId,
            @JsonKey(name: 'characters_limit') int? charactersLimit,
            String note)?
        noteProjectModel,
    TResult Function(
            String id,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'project_type') ProjectType projectType,
            @JsonKey(name: 'user_id') String userId,
            @JsonKey(name: 'folder_id') String folderId,
            @JsonKey(name: 'new_answer_text') String newAnswerText,
            @JsonKey(name: 'new_question_id') String newQuestionId,
            String title)?
        ideaProjectModel,
    required TResult orElse(),
  }) {
    if (ideaProjectModel != null) {
      return ideaProjectModel(id, createdAt, updatedAt, projectType, userId,
          folderId, newAnswerText, newQuestionId, title);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_NoteProjectModel value) noteProjectModel,
    required TResult Function(_IdeaProjectModel value) ideaProjectModel,
  }) {
    return ideaProjectModel(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(_NoteProjectModel value)? noteProjectModel,
    TResult Function(_IdeaProjectModel value)? ideaProjectModel,
  }) {
    return ideaProjectModel?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_NoteProjectModel value)? noteProjectModel,
    TResult Function(_IdeaProjectModel value)? ideaProjectModel,
    required TResult orElse(),
  }) {
    if (ideaProjectModel != null) {
      return ideaProjectModel(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$_IdeaProjectModelToJson(this);
  }
}

abstract class _IdeaProjectModel implements BasicProjectModel {
  const factory _IdeaProjectModel(
      {required final String id,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      @JsonKey(name: 'updated_at') required final DateTime updatedAt,
      @JsonKey(name: 'project_type') required final ProjectType projectType,
      @JsonKey(name: 'user_id') required final String userId,
      @JsonKey(name: 'folder_id') required final String folderId,
      @JsonKey(name: 'new_answer_text') required final String newAnswerText,
      @JsonKey(name: 'new_question_id') required final String newQuestionId,
      required final String title}) = _$_IdeaProjectModel;

  factory _IdeaProjectModel.fromJson(Map<String, dynamic> json) =
      _$_IdeaProjectModel.fromJson;

  @override
  String get id => throw _privateConstructorUsedError;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;
  @override
  @JsonKey(name: 'project_type')
  ProjectType get projectType => throw _privateConstructorUsedError;
  @override
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @override
  @JsonKey(name: 'folder_id')
  String get folderId => throw _privateConstructorUsedError;
  @JsonKey(name: 'new_answer_text')
  String get newAnswerText => throw _privateConstructorUsedError;
  @JsonKey(name: 'new_question_id')
  String get newQuestionId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  @override
  @JsonKey(ignore: true)
  _$$_IdeaProjectModelCopyWith<_$_IdeaProjectModel> get copyWith =>
      throw _privateConstructorUsedError;
}

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return _UserModel.fromJson(json);
}

/// @nodoc
mixin _$UserModel {
  String get id => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserModelCopyWith<UserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserModelCopyWith<$Res> {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) then) =
      _$UserModelCopyWithImpl<$Res>;
  $Res call({String id});
}

/// @nodoc
class _$UserModelCopyWithImpl<$Res> implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._value, this._then);

  final UserModel _value;
  // ignore: unused_field
  final $Res Function(UserModel) _then;

  @override
  $Res call({
    Object? id = freezed,
  }) {
    return _then(_value.copyWith(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
abstract class _$$_UserModelCopyWith<$Res> implements $UserModelCopyWith<$Res> {
  factory _$$_UserModelCopyWith(
          _$_UserModel value, $Res Function(_$_UserModel) then) =
      __$$_UserModelCopyWithImpl<$Res>;
  @override
  $Res call({String id});
}

/// @nodoc
class __$$_UserModelCopyWithImpl<$Res> extends _$UserModelCopyWithImpl<$Res>
    implements _$$_UserModelCopyWith<$Res> {
  __$$_UserModelCopyWithImpl(
      _$_UserModel _value, $Res Function(_$_UserModel) _then)
      : super(_value, (v) => _then(v as _$_UserModel));

  @override
  _$_UserModel get _value => super._value as _$_UserModel;

  @override
  $Res call({
    Object? id = freezed,
  }) {
    return _then(_$_UserModel(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$_UserModel with DiagnosticableTreeMixin implements _UserModel {
  const _$_UserModel({required this.id});

  factory _$_UserModel.fromJson(Map<String, dynamic> json) =>
      _$$_UserModelFromJson(json);

  @override
  final String id;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'UserModel(id: $id)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'UserModel'))
      ..add(DiagnosticsProperty('id', id));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_UserModel &&
            const DeepCollectionEquality().equals(other.id, id));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(id));

  @JsonKey(ignore: true)
  @override
  _$$_UserModelCopyWith<_$_UserModel> get copyWith =>
      __$$_UserModelCopyWithImpl<_$_UserModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_UserModelToJson(this);
  }
}

abstract class _UserModel implements UserModel {
  const factory _UserModel({required final String id}) = _$_UserModel;

  factory _UserModel.fromJson(Map<String, dynamic> json) =
      _$_UserModel.fromJson;

  @override
  String get id => throw _privateConstructorUsedError;
  @override
  @JsonKey(ignore: true)
  _$$_UserModelCopyWith<_$_UserModel> get copyWith =>
      throw _privateConstructorUsedError;
}
