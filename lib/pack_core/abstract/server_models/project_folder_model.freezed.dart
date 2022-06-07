// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'project_folder_model.dart';

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
  UserModelId get ownerId => throw _privateConstructorUsedError;

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
      @JsonKey(name: 'owner_id') UserModelId ownerId});
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
              as UserModelId,
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
      @JsonKey(name: 'owner_id') UserModelId ownerId});
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
              as UserModelId,
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
  final UserModelId ownerId;

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
          @JsonKey(name: 'owner_id') required final UserModelId ownerId}) =
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
  UserModelId get ownerId => throw _privateConstructorUsedError;
  @override
  @JsonKey(ignore: true)
  _$$_ProjectFolderModelCopyWith<_$_ProjectFolderModel> get copyWith =>
      throw _privateConstructorUsedError;
}
