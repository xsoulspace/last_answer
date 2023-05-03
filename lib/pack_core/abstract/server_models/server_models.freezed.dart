// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'server_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

IdeaProjectAnswerModel _$IdeaProjectAnswerModelFromJson(
    Map<String, dynamic> json) {
  return _IdeaProjectAnswerModel.fromJson(json);
}

/// @nodoc
mixin _$IdeaProjectAnswerModel {
  String get id => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  @JsonKey(
      name: 'question_id', fromJson: fromIntToString, toJson: fromStringToInt)
  String get questionId => throw _privateConstructorUsedError;
  @JsonKey(name: 'project_id')
  String get projectId => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'owner_id')
  String get ownerId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $IdeaProjectAnswerModelCopyWith<IdeaProjectAnswerModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IdeaProjectAnswerModelCopyWith<$Res> {
  factory $IdeaProjectAnswerModelCopyWith(IdeaProjectAnswerModel value,
          $Res Function(IdeaProjectAnswerModel) then) =
      _$IdeaProjectAnswerModelCopyWithImpl<$Res, IdeaProjectAnswerModel>;
  @useResult
  $Res call(
      {String id,
      String text,
      @JsonKey(name: 'question_id', fromJson: fromIntToString, toJson: fromStringToInt)
          String questionId,
      @JsonKey(name: 'project_id')
          String projectId,
      @JsonKey(name: 'created_at')
          DateTime createdAt,
      @JsonKey(name: 'updated_at')
          DateTime updatedAt,
      @JsonKey(name: 'owner_id')
          String ownerId});
}

/// @nodoc
class _$IdeaProjectAnswerModelCopyWithImpl<$Res,
        $Val extends IdeaProjectAnswerModel>
    implements $IdeaProjectAnswerModelCopyWith<$Res> {
  _$IdeaProjectAnswerModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? text = null,
    Object? questionId = null,
    Object? projectId = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? ownerId = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      questionId: null == questionId
          ? _value.questionId
          : questionId // ignore: cast_nullable_to_non_nullable
              as String,
      projectId: null == projectId
          ? _value.projectId
          : projectId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      ownerId: null == ownerId
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_IdeaProjectAnswerModelCopyWith<$Res>
    implements $IdeaProjectAnswerModelCopyWith<$Res> {
  factory _$$_IdeaProjectAnswerModelCopyWith(_$_IdeaProjectAnswerModel value,
          $Res Function(_$_IdeaProjectAnswerModel) then) =
      __$$_IdeaProjectAnswerModelCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String text,
      @JsonKey(name: 'question_id', fromJson: fromIntToString, toJson: fromStringToInt)
          String questionId,
      @JsonKey(name: 'project_id')
          String projectId,
      @JsonKey(name: 'created_at')
          DateTime createdAt,
      @JsonKey(name: 'updated_at')
          DateTime updatedAt,
      @JsonKey(name: 'owner_id')
          String ownerId});
}

/// @nodoc
class __$$_IdeaProjectAnswerModelCopyWithImpl<$Res>
    extends _$IdeaProjectAnswerModelCopyWithImpl<$Res,
        _$_IdeaProjectAnswerModel>
    implements _$$_IdeaProjectAnswerModelCopyWith<$Res> {
  __$$_IdeaProjectAnswerModelCopyWithImpl(_$_IdeaProjectAnswerModel _value,
      $Res Function(_$_IdeaProjectAnswerModel) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? text = null,
    Object? questionId = null,
    Object? projectId = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? ownerId = null,
  }) {
    return _then(_$_IdeaProjectAnswerModel(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      questionId: null == questionId
          ? _value.questionId
          : questionId // ignore: cast_nullable_to_non_nullable
              as String,
      projectId: null == projectId
          ? _value.projectId
          : projectId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      ownerId: null == ownerId
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$_IdeaProjectAnswerModel extends _IdeaProjectAnswerModel {
  const _$_IdeaProjectAnswerModel(
      {required this.id,
      required this.text,
      @JsonKey(name: 'question_id', fromJson: fromIntToString, toJson: fromStringToInt)
          required this.questionId,
      @JsonKey(name: 'project_id')
          required this.projectId,
      @JsonKey(name: 'created_at')
          required this.createdAt,
      @JsonKey(name: 'updated_at')
          required this.updatedAt,
      @JsonKey(name: 'owner_id')
          required this.ownerId})
      : super._();

  factory _$_IdeaProjectAnswerModel.fromJson(Map<String, dynamic> json) =>
      _$$_IdeaProjectAnswerModelFromJson(json);

  @override
  final String id;
  @override
  final String text;
  @override
  @JsonKey(
      name: 'question_id', fromJson: fromIntToString, toJson: fromStringToInt)
  final String questionId;
  @override
  @JsonKey(name: 'project_id')
  final String projectId;
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
  String toString() {
    return 'IdeaProjectAnswerModel(id: $id, text: $text, questionId: $questionId, projectId: $projectId, createdAt: $createdAt, updatedAt: $updatedAt, ownerId: $ownerId)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_IdeaProjectAnswerModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.questionId, questionId) ||
                other.questionId == questionId) &&
            (identical(other.projectId, projectId) ||
                other.projectId == projectId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.ownerId, ownerId) || other.ownerId == ownerId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, text, questionId, projectId,
      createdAt, updatedAt, ownerId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_IdeaProjectAnswerModelCopyWith<_$_IdeaProjectAnswerModel> get copyWith =>
      __$$_IdeaProjectAnswerModelCopyWithImpl<_$_IdeaProjectAnswerModel>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_IdeaProjectAnswerModelToJson(
      this,
    );
  }
}

abstract class _IdeaProjectAnswerModel extends IdeaProjectAnswerModel {
  const factory _IdeaProjectAnswerModel(
      {required final String id,
      required final String text,
      @JsonKey(name: 'question_id', fromJson: fromIntToString, toJson: fromStringToInt)
          required final String questionId,
      @JsonKey(name: 'project_id')
          required final String projectId,
      @JsonKey(name: 'created_at')
          required final DateTime createdAt,
      @JsonKey(name: 'updated_at')
          required final DateTime updatedAt,
      @JsonKey(name: 'owner_id')
          required final String ownerId}) = _$_IdeaProjectAnswerModel;
  const _IdeaProjectAnswerModel._() : super._();

  factory _IdeaProjectAnswerModel.fromJson(Map<String, dynamic> json) =
      _$_IdeaProjectAnswerModel.fromJson;

  @override
  String get id;
  @override
  String get text;
  @override
  @JsonKey(
      name: 'question_id', fromJson: fromIntToString, toJson: fromStringToInt)
  String get questionId;
  @override
  @JsonKey(name: 'project_id')
  String get projectId;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;
  @override
  @JsonKey(name: 'owner_id')
  String get ownerId;
  @override
  @JsonKey(ignore: true)
  _$$_IdeaProjectAnswerModelCopyWith<_$_IdeaProjectAnswerModel> get copyWith =>
      throw _privateConstructorUsedError;
}

IdeaProjectQuestionModel _$IdeaProjectQuestionModelFromJson(
    Map<String, dynamic> json) {
  return _IdeaProjectQuestionModel.fromJson(json);
}

/// @nodoc
mixin _$IdeaProjectQuestionModel {
  @JsonKey(fromJson: fromIntToString, toJson: fromStringToInt)
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $IdeaProjectQuestionModelCopyWith<IdeaProjectQuestionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IdeaProjectQuestionModelCopyWith<$Res> {
  factory $IdeaProjectQuestionModelCopyWith(IdeaProjectQuestionModel value,
          $Res Function(IdeaProjectQuestionModel) then) =
      _$IdeaProjectQuestionModelCopyWithImpl<$Res, IdeaProjectQuestionModel>;
  @useResult
  $Res call(
      {@JsonKey(fromJson: fromIntToString, toJson: fromStringToInt) String id,
      String title});
}

/// @nodoc
class _$IdeaProjectQuestionModelCopyWithImpl<$Res,
        $Val extends IdeaProjectQuestionModel>
    implements $IdeaProjectQuestionModelCopyWith<$Res> {
  _$IdeaProjectQuestionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_IdeaProjectQuestionModelCopyWith<$Res>
    implements $IdeaProjectQuestionModelCopyWith<$Res> {
  factory _$$_IdeaProjectQuestionModelCopyWith(
          _$_IdeaProjectQuestionModel value,
          $Res Function(_$_IdeaProjectQuestionModel) then) =
      __$$_IdeaProjectQuestionModelCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(fromJson: fromIntToString, toJson: fromStringToInt) String id,
      String title});
}

/// @nodoc
class __$$_IdeaProjectQuestionModelCopyWithImpl<$Res>
    extends _$IdeaProjectQuestionModelCopyWithImpl<$Res,
        _$_IdeaProjectQuestionModel>
    implements _$$_IdeaProjectQuestionModelCopyWith<$Res> {
  __$$_IdeaProjectQuestionModelCopyWithImpl(_$_IdeaProjectQuestionModel _value,
      $Res Function(_$_IdeaProjectQuestionModel) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
  }) {
    return _then(_$_IdeaProjectQuestionModel(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$_IdeaProjectQuestionModel extends _IdeaProjectQuestionModel {
  const _$_IdeaProjectQuestionModel(
      {@JsonKey(fromJson: fromIntToString, toJson: fromStringToInt)
          required this.id,
      required this.title})
      : super._();

  factory _$_IdeaProjectQuestionModel.fromJson(Map<String, dynamic> json) =>
      _$$_IdeaProjectQuestionModelFromJson(json);

  @override
  @JsonKey(fromJson: fromIntToString, toJson: fromStringToInt)
  final String id;
  @override
  final String title;

  @override
  String toString() {
    return 'IdeaProjectQuestionModel(id: $id, title: $title)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_IdeaProjectQuestionModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, title);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_IdeaProjectQuestionModelCopyWith<_$_IdeaProjectQuestionModel>
      get copyWith => __$$_IdeaProjectQuestionModelCopyWithImpl<
          _$_IdeaProjectQuestionModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_IdeaProjectQuestionModelToJson(
      this,
    );
  }
}

abstract class _IdeaProjectQuestionModel extends IdeaProjectQuestionModel {
  const factory _IdeaProjectQuestionModel(
      {@JsonKey(fromJson: fromIntToString, toJson: fromStringToInt)
          required final String id,
      required final String title}) = _$_IdeaProjectQuestionModel;
  const _IdeaProjectQuestionModel._() : super._();

  factory _IdeaProjectQuestionModel.fromJson(Map<String, dynamic> json) =
      _$_IdeaProjectQuestionModel.fromJson;

  @override
  @JsonKey(fromJson: fromIntToString, toJson: fromStringToInt)
  String get id;
  @override
  String get title;
  @override
  @JsonKey(ignore: true)
  _$$_IdeaProjectQuestionModelCopyWith<_$_IdeaProjectQuestionModel>
      get copyWith => throw _privateConstructorUsedError;
}

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
      _$ProjectFolderModelCopyWithImpl<$Res, ProjectFolderModel>;
  @useResult
  $Res call(
      {String id,
      String title,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      @JsonKey(name: 'owner_id') String ownerId});
}

/// @nodoc
class _$ProjectFolderModelCopyWithImpl<$Res, $Val extends ProjectFolderModel>
    implements $ProjectFolderModelCopyWith<$Res> {
  _$ProjectFolderModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? ownerId = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      ownerId: null == ownerId
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_ProjectFolderModelCopyWith<$Res>
    implements $ProjectFolderModelCopyWith<$Res> {
  factory _$$_ProjectFolderModelCopyWith(_$_ProjectFolderModel value,
          $Res Function(_$_ProjectFolderModel) then) =
      __$$_ProjectFolderModelCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      @JsonKey(name: 'owner_id') String ownerId});
}

/// @nodoc
class __$$_ProjectFolderModelCopyWithImpl<$Res>
    extends _$ProjectFolderModelCopyWithImpl<$Res, _$_ProjectFolderModel>
    implements _$$_ProjectFolderModelCopyWith<$Res> {
  __$$_ProjectFolderModelCopyWithImpl(
      _$_ProjectFolderModel _value, $Res Function(_$_ProjectFolderModel) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? ownerId = null,
  }) {
    return _then(_$_ProjectFolderModel(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      ownerId: null == ownerId
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$_ProjectFolderModel extends _ProjectFolderModel {
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
  String toString() {
    return 'ProjectFolderModel(id: $id, title: $title, createdAt: $createdAt, updatedAt: $updatedAt, ownerId: $ownerId)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_ProjectFolderModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.ownerId, ownerId) || other.ownerId == ownerId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, title, createdAt, updatedAt, ownerId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_ProjectFolderModelCopyWith<_$_ProjectFolderModel> get copyWith =>
      __$$_ProjectFolderModelCopyWithImpl<_$_ProjectFolderModel>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_ProjectFolderModelToJson(
      this,
    );
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
  String get id;
  @override
  String get title;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;
  @override
  @JsonKey(name: 'owner_id')
  String get ownerId;
  @override
  @JsonKey(ignore: true)
  _$$_ProjectFolderModelCopyWith<_$_ProjectFolderModel> get copyWith =>
      throw _privateConstructorUsedError;
}

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
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_completed')
  bool get isCompleted => throw _privateConstructorUsedError;
  @JsonKey(name: 'project_type')
  ProjectType get projectType => throw _privateConstructorUsedError;
  @JsonKey(name: 'owner_id')
  String get ownerId => throw _privateConstructorUsedError;
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
            @JsonKey(name: 'owner_id') String ownerId,
            @JsonKey(name: 'folder_id') String folderId,
            @JsonKey(name: 'characters_limit') int? charactersLimit,
            String note)
        noteProjectModel,
    required TResult Function(
            String id,
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
                String ownerId,
            @JsonKey(name: 'folder_id')
                String folderId,
            @JsonKey(name: 'new_answer_text')
                String newAnswerText,
            @JsonKey(name: 'new_question_id', fromJson: fromIntToString, toJson: fromStringToInt)
                String newQuestionId)
        ideaProjectModel,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String id,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'is_completed') bool isCompleted,
            @JsonKey(name: 'project_type') ProjectType projectType,
            @JsonKey(name: 'owner_id') String ownerId,
            @JsonKey(name: 'folder_id') String folderId,
            @JsonKey(name: 'characters_limit') int? charactersLimit,
            String note)?
        noteProjectModel,
    TResult? Function(
            String id,
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
                String ownerId,
            @JsonKey(name: 'folder_id')
                String folderId,
            @JsonKey(name: 'new_answer_text')
                String newAnswerText,
            @JsonKey(name: 'new_question_id', fromJson: fromIntToString, toJson: fromStringToInt)
                String newQuestionId)?
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
            @JsonKey(name: 'owner_id') String ownerId,
            @JsonKey(name: 'folder_id') String folderId,
            @JsonKey(name: 'characters_limit') int? charactersLimit,
            String note)?
        noteProjectModel,
    TResult Function(
            String id,
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
                String ownerId,
            @JsonKey(name: 'folder_id')
                String folderId,
            @JsonKey(name: 'new_answer_text')
                String newAnswerText,
            @JsonKey(name: 'new_question_id', fromJson: fromIntToString, toJson: fromStringToInt)
                String newQuestionId)?
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
    TResult? Function(NoteProjectModel value)? noteProjectModel,
    TResult? Function(IdeaProjectModel value)? ideaProjectModel,
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
      _$BasicProjectModelCopyWithImpl<$Res, BasicProjectModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      @JsonKey(name: 'is_completed') bool isCompleted,
      @JsonKey(name: 'project_type') ProjectType projectType,
      @JsonKey(name: 'owner_id') String ownerId,
      @JsonKey(name: 'folder_id') String folderId});
}

/// @nodoc
class _$BasicProjectModelCopyWithImpl<$Res, $Val extends BasicProjectModel>
    implements $BasicProjectModelCopyWith<$Res> {
  _$BasicProjectModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? isCompleted = null,
    Object? projectType = null,
    Object? ownerId = null,
    Object? folderId = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      projectType: null == projectType
          ? _value.projectType
          : projectType // ignore: cast_nullable_to_non_nullable
              as ProjectType,
      ownerId: null == ownerId
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as String,
      folderId: null == folderId
          ? _value.folderId
          : folderId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NoteProjectModelCopyWith<$Res>
    implements $BasicProjectModelCopyWith<$Res> {
  factory _$$NoteProjectModelCopyWith(
          _$NoteProjectModel value, $Res Function(_$NoteProjectModel) then) =
      __$$NoteProjectModelCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      @JsonKey(name: 'is_completed') bool isCompleted,
      @JsonKey(name: 'project_type') ProjectType projectType,
      @JsonKey(name: 'owner_id') String ownerId,
      @JsonKey(name: 'folder_id') String folderId,
      @JsonKey(name: 'characters_limit') int? charactersLimit,
      String note});
}

/// @nodoc
class __$$NoteProjectModelCopyWithImpl<$Res>
    extends _$BasicProjectModelCopyWithImpl<$Res, _$NoteProjectModel>
    implements _$$NoteProjectModelCopyWith<$Res> {
  __$$NoteProjectModelCopyWithImpl(
      _$NoteProjectModel _value, $Res Function(_$NoteProjectModel) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? isCompleted = null,
    Object? projectType = null,
    Object? ownerId = null,
    Object? folderId = null,
    Object? charactersLimit = freezed,
    Object? note = null,
  }) {
    return _then(_$NoteProjectModel(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      projectType: null == projectType
          ? _value.projectType
          : projectType // ignore: cast_nullable_to_non_nullable
              as ProjectType,
      ownerId: null == ownerId
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as String,
      folderId: null == folderId
          ? _value.folderId
          : folderId // ignore: cast_nullable_to_non_nullable
              as String,
      charactersLimit: freezed == charactersLimit
          ? _value.charactersLimit
          : charactersLimit // ignore: cast_nullable_to_non_nullable
              as int?,
      note: null == note
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
  @JsonKey(name: 'owner_id')
  final String ownerId;
  @override
  @JsonKey(name: 'folder_id')
  final String folderId;
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
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            (identical(other.projectType, projectType) ||
                other.projectType == projectType) &&
            (identical(other.ownerId, ownerId) || other.ownerId == ownerId) &&
            (identical(other.folderId, folderId) ||
                other.folderId == folderId) &&
            (identical(other.charactersLimit, charactersLimit) ||
                other.charactersLimit == charactersLimit) &&
            (identical(other.note, note) || other.note == note));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, createdAt, updatedAt,
      isCompleted, projectType, ownerId, folderId, charactersLimit, note);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NoteProjectModelCopyWith<_$NoteProjectModel> get copyWith =>
      __$$NoteProjectModelCopyWithImpl<_$NoteProjectModel>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String id,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'is_completed') bool isCompleted,
            @JsonKey(name: 'project_type') ProjectType projectType,
            @JsonKey(name: 'owner_id') String ownerId,
            @JsonKey(name: 'folder_id') String folderId,
            @JsonKey(name: 'characters_limit') int? charactersLimit,
            String note)
        noteProjectModel,
    required TResult Function(
            String id,
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
                String ownerId,
            @JsonKey(name: 'folder_id')
                String folderId,
            @JsonKey(name: 'new_answer_text')
                String newAnswerText,
            @JsonKey(name: 'new_question_id', fromJson: fromIntToString, toJson: fromStringToInt)
                String newQuestionId)
        ideaProjectModel,
  }) {
    return noteProjectModel(id, createdAt, updatedAt, isCompleted, projectType,
        ownerId, folderId, charactersLimit, note);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String id,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'is_completed') bool isCompleted,
            @JsonKey(name: 'project_type') ProjectType projectType,
            @JsonKey(name: 'owner_id') String ownerId,
            @JsonKey(name: 'folder_id') String folderId,
            @JsonKey(name: 'characters_limit') int? charactersLimit,
            String note)?
        noteProjectModel,
    TResult? Function(
            String id,
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
                String ownerId,
            @JsonKey(name: 'folder_id')
                String folderId,
            @JsonKey(name: 'new_answer_text')
                String newAnswerText,
            @JsonKey(name: 'new_question_id', fromJson: fromIntToString, toJson: fromStringToInt)
                String newQuestionId)?
        ideaProjectModel,
  }) {
    return noteProjectModel?.call(id, createdAt, updatedAt, isCompleted,
        projectType, ownerId, folderId, charactersLimit, note);
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
            @JsonKey(name: 'owner_id') String ownerId,
            @JsonKey(name: 'folder_id') String folderId,
            @JsonKey(name: 'characters_limit') int? charactersLimit,
            String note)?
        noteProjectModel,
    TResult Function(
            String id,
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
                String ownerId,
            @JsonKey(name: 'folder_id')
                String folderId,
            @JsonKey(name: 'new_answer_text')
                String newAnswerText,
            @JsonKey(name: 'new_question_id', fromJson: fromIntToString, toJson: fromStringToInt)
                String newQuestionId)?
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
    TResult? Function(NoteProjectModel value)? noteProjectModel,
    TResult? Function(IdeaProjectModel value)? ideaProjectModel,
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
    return _$$NoteProjectModelToJson(
      this,
    );
  }
}

abstract class NoteProjectModel implements BasicProjectModel {
  const factory NoteProjectModel(
      {required final String id,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      @JsonKey(name: 'updated_at') required final DateTime updatedAt,
      @JsonKey(name: 'is_completed') required final bool isCompleted,
      @JsonKey(name: 'project_type') required final ProjectType projectType,
      @JsonKey(name: 'owner_id') required final String ownerId,
      @JsonKey(name: 'folder_id') required final String folderId,
      @JsonKey(name: 'characters_limit') required final int? charactersLimit,
      required final String note}) = _$NoteProjectModel;

  factory NoteProjectModel.fromJson(Map<String, dynamic> json) =
      _$NoteProjectModel.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;
  @override
  @JsonKey(name: 'is_completed')
  bool get isCompleted;
  @override
  @JsonKey(name: 'project_type')
  ProjectType get projectType;
  @override
  @JsonKey(name: 'owner_id')
  String get ownerId;
  @override
  @JsonKey(name: 'folder_id')
  String get folderId;
  @JsonKey(name: 'characters_limit')
  int? get charactersLimit;
  String get note;
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
  @useResult
  $Res call(
      {String id,
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
          String ownerId,
      @JsonKey(name: 'folder_id')
          String folderId,
      @JsonKey(name: 'new_answer_text')
          String newAnswerText,
      @JsonKey(name: 'new_question_id', fromJson: fromIntToString, toJson: fromStringToInt)
          String newQuestionId});
}

/// @nodoc
class __$$IdeaProjectModelCopyWithImpl<$Res>
    extends _$BasicProjectModelCopyWithImpl<$Res, _$IdeaProjectModel>
    implements _$$IdeaProjectModelCopyWith<$Res> {
  __$$IdeaProjectModelCopyWithImpl(
      _$IdeaProjectModel _value, $Res Function(_$IdeaProjectModel) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? isCompleted = null,
    Object? projectType = null,
    Object? ownerId = null,
    Object? folderId = null,
    Object? newAnswerText = null,
    Object? newQuestionId = null,
  }) {
    return _then(_$IdeaProjectModel(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      projectType: null == projectType
          ? _value.projectType
          : projectType // ignore: cast_nullable_to_non_nullable
              as ProjectType,
      ownerId: null == ownerId
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as String,
      folderId: null == folderId
          ? _value.folderId
          : folderId // ignore: cast_nullable_to_non_nullable
              as String,
      newAnswerText: null == newAnswerText
          ? _value.newAnswerText
          : newAnswerText // ignore: cast_nullable_to_non_nullable
              as String,
      newQuestionId: null == newQuestionId
          ? _value.newQuestionId
          : newQuestionId // ignore: cast_nullable_to_non_nullable
              as String,
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
  @JsonKey(name: 'is_completed')
  final bool isCompleted;
  @override
  @JsonKey(name: 'project_type')
  final ProjectType projectType;
  @override
  @JsonKey(name: 'owner_id')
  final String ownerId;
  @override
  @JsonKey(name: 'folder_id')
  final String folderId;
  @override
  @JsonKey(name: 'new_answer_text')
  final String newAnswerText;
  @override
  @JsonKey(
      name: 'new_question_id',
      fromJson: fromIntToString,
      toJson: fromStringToInt)
  final String newQuestionId;

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
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            (identical(other.projectType, projectType) ||
                other.projectType == projectType) &&
            (identical(other.ownerId, ownerId) || other.ownerId == ownerId) &&
            (identical(other.folderId, folderId) ||
                other.folderId == folderId) &&
            (identical(other.newAnswerText, newAnswerText) ||
                other.newAnswerText == newAnswerText) &&
            (identical(other.newQuestionId, newQuestionId) ||
                other.newQuestionId == newQuestionId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      createdAt,
      updatedAt,
      isCompleted,
      projectType,
      ownerId,
      folderId,
      newAnswerText,
      newQuestionId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$IdeaProjectModelCopyWith<_$IdeaProjectModel> get copyWith =>
      __$$IdeaProjectModelCopyWithImpl<_$IdeaProjectModel>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String id,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'is_completed') bool isCompleted,
            @JsonKey(name: 'project_type') ProjectType projectType,
            @JsonKey(name: 'owner_id') String ownerId,
            @JsonKey(name: 'folder_id') String folderId,
            @JsonKey(name: 'characters_limit') int? charactersLimit,
            String note)
        noteProjectModel,
    required TResult Function(
            String id,
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
                String ownerId,
            @JsonKey(name: 'folder_id')
                String folderId,
            @JsonKey(name: 'new_answer_text')
                String newAnswerText,
            @JsonKey(name: 'new_question_id', fromJson: fromIntToString, toJson: fromStringToInt)
                String newQuestionId)
        ideaProjectModel,
  }) {
    return ideaProjectModel(id, title, createdAt, updatedAt, isCompleted,
        projectType, ownerId, folderId, newAnswerText, newQuestionId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String id,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'is_completed') bool isCompleted,
            @JsonKey(name: 'project_type') ProjectType projectType,
            @JsonKey(name: 'owner_id') String ownerId,
            @JsonKey(name: 'folder_id') String folderId,
            @JsonKey(name: 'characters_limit') int? charactersLimit,
            String note)?
        noteProjectModel,
    TResult? Function(
            String id,
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
                String ownerId,
            @JsonKey(name: 'folder_id')
                String folderId,
            @JsonKey(name: 'new_answer_text')
                String newAnswerText,
            @JsonKey(name: 'new_question_id', fromJson: fromIntToString, toJson: fromStringToInt)
                String newQuestionId)?
        ideaProjectModel,
  }) {
    return ideaProjectModel?.call(id, title, createdAt, updatedAt, isCompleted,
        projectType, ownerId, folderId, newAnswerText, newQuestionId);
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
            @JsonKey(name: 'owner_id') String ownerId,
            @JsonKey(name: 'folder_id') String folderId,
            @JsonKey(name: 'characters_limit') int? charactersLimit,
            String note)?
        noteProjectModel,
    TResult Function(
            String id,
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
                String ownerId,
            @JsonKey(name: 'folder_id')
                String folderId,
            @JsonKey(name: 'new_answer_text')
                String newAnswerText,
            @JsonKey(name: 'new_question_id', fromJson: fromIntToString, toJson: fromStringToInt)
                String newQuestionId)?
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
    TResult? Function(NoteProjectModel value)? noteProjectModel,
    TResult? Function(IdeaProjectModel value)? ideaProjectModel,
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
    return _$$IdeaProjectModelToJson(
      this,
    );
  }
}

abstract class IdeaProjectModel implements BasicProjectModel {
  const factory IdeaProjectModel(
      {required final String id,
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
          required final String ownerId,
      @JsonKey(name: 'folder_id')
          required final String folderId,
      @JsonKey(name: 'new_answer_text')
          required final String newAnswerText,
      @JsonKey(name: 'new_question_id', fromJson: fromIntToString, toJson: fromStringToInt)
          required final String newQuestionId}) = _$IdeaProjectModel;

  factory IdeaProjectModel.fromJson(Map<String, dynamic> json) =
      _$IdeaProjectModel.fromJson;

  @override
  String get id;
  String get title;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;
  @override
  @JsonKey(name: 'is_completed')
  bool get isCompleted;
  @override
  @JsonKey(name: 'project_type')
  ProjectType get projectType;
  @override
  @JsonKey(name: 'owner_id')
  String get ownerId;
  @override
  @JsonKey(name: 'folder_id')
  String get folderId;
  @JsonKey(name: 'new_answer_text')
  String get newAnswerText;
  @JsonKey(
      name: 'new_question_id',
      fromJson: fromIntToString,
      toJson: fromStringToInt)
  String get newQuestionId;
  @override
  @JsonKey(ignore: true)
  _$$IdeaProjectModelCopyWith<_$IdeaProjectModel> get copyWith =>
      throw _privateConstructorUsedError;
}

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return _UserModel.fromJson(json);
}

/// @nodoc
mixin _$UserModel {
  String get id => throw _privateConstructorUsedError;
  UserStatus get status => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserModelCopyWith<UserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserModelCopyWith<$Res> {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) then) =
      _$UserModelCopyWithImpl<$Res, UserModel>;
  @useResult
  $Res call({String id, UserStatus status, String username});
}

/// @nodoc
class _$UserModelCopyWithImpl<$Res, $Val extends UserModel>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? username = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as UserStatus,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_UserModelCopyWith<$Res> implements $UserModelCopyWith<$Res> {
  factory _$$_UserModelCopyWith(
          _$_UserModel value, $Res Function(_$_UserModel) then) =
      __$$_UserModelCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, UserStatus status, String username});
}

/// @nodoc
class __$$_UserModelCopyWithImpl<$Res>
    extends _$UserModelCopyWithImpl<$Res, _$_UserModel>
    implements _$$_UserModelCopyWith<$Res> {
  __$$_UserModelCopyWithImpl(
      _$_UserModel _value, $Res Function(_$_UserModel) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? username = null,
  }) {
    return _then(_$_UserModel(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as UserStatus,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$_UserModel extends _UserModel {
  const _$_UserModel(
      {required this.id, required this.status, required this.username})
      : super._();

  factory _$_UserModel.fromJson(Map<String, dynamic> json) =>
      _$$_UserModelFromJson(json);

  @override
  final String id;
  @override
  final UserStatus status;
  @override
  final String username;

  @override
  String toString() {
    return 'UserModel(id: $id, status: $status, username: $username)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_UserModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.username, username) ||
                other.username == username));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, status, username);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_UserModelCopyWith<_$_UserModel> get copyWith =>
      __$$_UserModelCopyWithImpl<_$_UserModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_UserModelToJson(
      this,
    );
  }
}

abstract class _UserModel extends UserModel {
  const factory _UserModel(
      {required final String id,
      required final UserStatus status,
      required final String username}) = _$_UserModel;
  const _UserModel._() : super._();

  factory _UserModel.fromJson(Map<String, dynamic> json) =
      _$_UserModel.fromJson;

  @override
  String get id;
  @override
  UserStatus get status;
  @override
  String get username;
  @override
  @JsonKey(ignore: true)
  _$$_UserModelCopyWith<_$_UserModel> get copyWith =>
      throw _privateConstructorUsedError;
}
