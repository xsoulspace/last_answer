// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'idea_project_answer_model.dart';

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
  UserModelId get ownerId => throw _privateConstructorUsedError;

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
          UserModelId ownerId});
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
              as UserModelId,
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
          UserModelId ownerId});
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
              as UserModelId,
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
  final UserModelId ownerId;

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
          required final UserModelId ownerId}) = _$_IdeaProjectAnswerModel;
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
  UserModelId get ownerId => throw _privateConstructorUsedError;
  @override
  @JsonKey(ignore: true)
  _$$_IdeaProjectAnswerModelCopyWith<_$_IdeaProjectAnswerModel> get copyWith =>
      throw _privateConstructorUsedError;
}
