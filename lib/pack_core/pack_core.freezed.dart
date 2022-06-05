// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of pack_core;

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
      _$IdeaProjectAnswerModelCopyWithImpl<$Res>;
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
class _$IdeaProjectAnswerModelCopyWithImpl<$Res>
    implements $IdeaProjectAnswerModelCopyWith<$Res> {
  _$IdeaProjectAnswerModelCopyWithImpl(this._value, this._then);

  final IdeaProjectAnswerModel _value;
  // ignore: unused_field
  final $Res Function(IdeaProjectAnswerModel) _then;

  @override
  $Res call({
    Object? id = freezed,
    Object? text = freezed,
    Object? questionId = freezed,
    Object? projectId = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? ownerId = freezed,
  }) {
    return _then(_value.copyWith(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      text: text == freezed
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      questionId: questionId == freezed
          ? _value.questionId
          : questionId // ignore: cast_nullable_to_non_nullable
              as String,
      projectId: projectId == freezed
          ? _value.projectId
          : projectId // ignore: cast_nullable_to_non_nullable
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
abstract class _$$_IdeaProjectAnswerModelCopyWith<$Res>
    implements $IdeaProjectAnswerModelCopyWith<$Res> {
  factory _$$_IdeaProjectAnswerModelCopyWith(_$_IdeaProjectAnswerModel value,
          $Res Function(_$_IdeaProjectAnswerModel) then) =
      __$$_IdeaProjectAnswerModelCopyWithImpl<$Res>;
  @override
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
    extends _$IdeaProjectAnswerModelCopyWithImpl<$Res>
    implements _$$_IdeaProjectAnswerModelCopyWith<$Res> {
  __$$_IdeaProjectAnswerModelCopyWithImpl(_$_IdeaProjectAnswerModel _value,
      $Res Function(_$_IdeaProjectAnswerModel) _then)
      : super(_value, (v) => _then(v as _$_IdeaProjectAnswerModel));

  @override
  _$_IdeaProjectAnswerModel get _value =>
      super._value as _$_IdeaProjectAnswerModel;

  @override
  $Res call({
    Object? id = freezed,
    Object? text = freezed,
    Object? questionId = freezed,
    Object? projectId = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? ownerId = freezed,
  }) {
    return _then(_$_IdeaProjectAnswerModel(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      text: text == freezed
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      questionId: questionId == freezed
          ? _value.questionId
          : questionId // ignore: cast_nullable_to_non_nullable
              as String,
      projectId: projectId == freezed
          ? _value.projectId
          : projectId // ignore: cast_nullable_to_non_nullable
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
            const DeepCollectionEquality().equals(other.id, id) &&
            const DeepCollectionEquality().equals(other.text, text) &&
            const DeepCollectionEquality()
                .equals(other.questionId, questionId) &&
            const DeepCollectionEquality().equals(other.projectId, projectId) &&
            const DeepCollectionEquality().equals(other.createdAt, createdAt) &&
            const DeepCollectionEquality().equals(other.updatedAt, updatedAt) &&
            const DeepCollectionEquality().equals(other.ownerId, ownerId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(id),
      const DeepCollectionEquality().hash(text),
      const DeepCollectionEquality().hash(questionId),
      const DeepCollectionEquality().hash(projectId),
      const DeepCollectionEquality().hash(createdAt),
      const DeepCollectionEquality().hash(updatedAt),
      const DeepCollectionEquality().hash(ownerId));

  @JsonKey(ignore: true)
  @override
  _$$_IdeaProjectAnswerModelCopyWith<_$_IdeaProjectAnswerModel> get copyWith =>
      __$$_IdeaProjectAnswerModelCopyWithImpl<_$_IdeaProjectAnswerModel>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_IdeaProjectAnswerModelToJson(this);
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
  String get id => throw _privateConstructorUsedError;
  @override
  String get text => throw _privateConstructorUsedError;
  @override
  @JsonKey(
      name: 'question_id', fromJson: fromIntToString, toJson: fromStringToInt)
  String get questionId => throw _privateConstructorUsedError;
  @override
  @JsonKey(name: 'project_id')
  String get projectId => throw _privateConstructorUsedError;
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
      _$IdeaProjectQuestionModelCopyWithImpl<$Res>;
  $Res call(
      {@JsonKey(fromJson: fromIntToString, toJson: fromStringToInt) String id,
      String title});
}

/// @nodoc
class _$IdeaProjectQuestionModelCopyWithImpl<$Res>
    implements $IdeaProjectQuestionModelCopyWith<$Res> {
  _$IdeaProjectQuestionModelCopyWithImpl(this._value, this._then);

  final IdeaProjectQuestionModel _value;
  // ignore: unused_field
  final $Res Function(IdeaProjectQuestionModel) _then;

  @override
  $Res call({
    Object? id = freezed,
    Object? title = freezed,
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
    ));
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
  $Res call(
      {@JsonKey(fromJson: fromIntToString, toJson: fromStringToInt) String id,
      String title});
}

/// @nodoc
class __$$_IdeaProjectQuestionModelCopyWithImpl<$Res>
    extends _$IdeaProjectQuestionModelCopyWithImpl<$Res>
    implements _$$_IdeaProjectQuestionModelCopyWith<$Res> {
  __$$_IdeaProjectQuestionModelCopyWithImpl(_$_IdeaProjectQuestionModel _value,
      $Res Function(_$_IdeaProjectQuestionModel) _then)
      : super(_value, (v) => _then(v as _$_IdeaProjectQuestionModel));

  @override
  _$_IdeaProjectQuestionModel get _value =>
      super._value as _$_IdeaProjectQuestionModel;

  @override
  $Res call({
    Object? id = freezed,
    Object? title = freezed,
  }) {
    return _then(_$_IdeaProjectQuestionModel(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
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
            const DeepCollectionEquality().equals(other.id, id) &&
            const DeepCollectionEquality().equals(other.title, title));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(id),
      const DeepCollectionEquality().hash(title));

  @JsonKey(ignore: true)
  @override
  _$$_IdeaProjectQuestionModelCopyWith<_$_IdeaProjectQuestionModel>
      get copyWith => __$$_IdeaProjectQuestionModelCopyWithImpl<
          _$_IdeaProjectQuestionModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_IdeaProjectQuestionModelToJson(this);
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
  String get id => throw _privateConstructorUsedError;
  @override
  String get title => throw _privateConstructorUsedError;
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
      {String id,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      @JsonKey(name: 'is_completed') bool isCompleted,
      @JsonKey(name: 'project_type') ProjectType projectType,
      @JsonKey(name: 'owner_id') String ownerId,
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
    Object? isCompleted = freezed,
    Object? projectType = freezed,
    Object? ownerId = freezed,
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
              as String,
      folderId: folderId == freezed
          ? _value.folderId
          : folderId // ignore: cast_nullable_to_non_nullable
              as String,
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
  String get id => throw _privateConstructorUsedError;
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
  String get ownerId => throw _privateConstructorUsedError;
  @override
  @JsonKey(name: 'folder_id')
  String get folderId => throw _privateConstructorUsedError;
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
  String get id => throw _privateConstructorUsedError;
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
  String get ownerId => throw _privateConstructorUsedError;
  @override
  @JsonKey(name: 'folder_id')
  String get folderId => throw _privateConstructorUsedError;
  @JsonKey(name: 'new_answer_text')
  String get newAnswerText => throw _privateConstructorUsedError;
  @JsonKey(
      name: 'new_question_id',
      fromJson: fromIntToString,
      toJson: fromStringToInt)
  String get newQuestionId => throw _privateConstructorUsedError;
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
      _$UserModelCopyWithImpl<$Res>;
  $Res call({String id, UserStatus status, String username});
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
    Object? status = freezed,
    Object? username = freezed,
  }) {
    return _then(_value.copyWith(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      status: status == freezed
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as UserStatus,
      username: username == freezed
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
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
  $Res call({String id, UserStatus status, String username});
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
    Object? status = freezed,
    Object? username = freezed,
  }) {
    return _then(_$_UserModel(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      status: status == freezed
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as UserStatus,
      username: username == freezed
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
            const DeepCollectionEquality().equals(other.id, id) &&
            const DeepCollectionEquality().equals(other.status, status) &&
            const DeepCollectionEquality().equals(other.username, username));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(id),
      const DeepCollectionEquality().hash(status),
      const DeepCollectionEquality().hash(username));

  @JsonKey(ignore: true)
  @override
  _$$_UserModelCopyWith<_$_UserModel> get copyWith =>
      __$$_UserModelCopyWithImpl<_$_UserModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_UserModelToJson(this);
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
  String get id => throw _privateConstructorUsedError;
  @override
  UserStatus get status => throw _privateConstructorUsedError;
  @override
  String get username => throw _privateConstructorUsedError;
  @override
  @JsonKey(ignore: true)
  _$$_UserModelCopyWith<_$_UserModel> get copyWith =>
      throw _privateConstructorUsedError;
}
