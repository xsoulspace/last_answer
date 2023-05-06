// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

AppSettingsModel _$AppSettingsModelFromJson(Map<String, dynamic> json) {
  return _AppSettingsModel.fromJson(json);
}

/// @nodoc
mixin _$AppSettingsModel {
  @JsonKey(fromJson: localeFromString, toJson: localeToString)
  Locale? get locale => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AppSettingsModelCopyWith<AppSettingsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppSettingsModelCopyWith<$Res> {
  factory $AppSettingsModelCopyWith(
          AppSettingsModel value, $Res Function(AppSettingsModel) then) =
      _$AppSettingsModelCopyWithImpl<$Res, AppSettingsModel>;
  @useResult
  $Res call(
      {@JsonKey(fromJson: localeFromString, toJson: localeToString)
          Locale? locale});
}

/// @nodoc
class _$AppSettingsModelCopyWithImpl<$Res, $Val extends AppSettingsModel>
    implements $AppSettingsModelCopyWith<$Res> {
  _$AppSettingsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? locale = freezed,
  }) {
    return _then(_value.copyWith(
      locale: freezed == locale
          ? _value.locale
          : locale // ignore: cast_nullable_to_non_nullable
              as Locale?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_AppSettingsModelCopyWith<$Res>
    implements $AppSettingsModelCopyWith<$Res> {
  factory _$$_AppSettingsModelCopyWith(
          _$_AppSettingsModel value, $Res Function(_$_AppSettingsModel) then) =
      __$$_AppSettingsModelCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(fromJson: localeFromString, toJson: localeToString)
          Locale? locale});
}

/// @nodoc
class __$$_AppSettingsModelCopyWithImpl<$Res>
    extends _$AppSettingsModelCopyWithImpl<$Res, _$_AppSettingsModel>
    implements _$$_AppSettingsModelCopyWith<$Res> {
  __$$_AppSettingsModelCopyWithImpl(
      _$_AppSettingsModel _value, $Res Function(_$_AppSettingsModel) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? locale = freezed,
  }) {
    return _then(_$_AppSettingsModel(
      locale: freezed == locale
          ? _value.locale
          : locale // ignore: cast_nullable_to_non_nullable
              as Locale?,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$_AppSettingsModel extends _AppSettingsModel {
  const _$_AppSettingsModel(
      {@JsonKey(fromJson: localeFromString, toJson: localeToString)
          this.locale})
      : super._();

  factory _$_AppSettingsModel.fromJson(Map<String, dynamic> json) =>
      _$$_AppSettingsModelFromJson(json);

  @override
  @JsonKey(fromJson: localeFromString, toJson: localeToString)
  final Locale? locale;

  @override
  String toString() {
    return 'AppSettingsModel(locale: $locale)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_AppSettingsModel &&
            (identical(other.locale, locale) || other.locale == locale));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, locale);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_AppSettingsModelCopyWith<_$_AppSettingsModel> get copyWith =>
      __$$_AppSettingsModelCopyWithImpl<_$_AppSettingsModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_AppSettingsModelToJson(
      this,
    );
  }
}

abstract class _AppSettingsModel extends AppSettingsModel {
  const factory _AppSettingsModel(
      {@JsonKey(fromJson: localeFromString, toJson: localeToString)
          final Locale? locale}) = _$_AppSettingsModel;
  const _AppSettingsModel._() : super._();

  factory _AppSettingsModel.fromJson(Map<String, dynamic> json) =
      _$_AppSettingsModel.fromJson;

  @override
  @JsonKey(fromJson: localeFromString, toJson: localeToString)
  Locale? get locale;
  @override
  @JsonKey(ignore: true)
  _$$_AppSettingsModelCopyWith<_$_AppSettingsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

ProjectModelId _$ProjectModelIdFromJson(Map<String, dynamic> json) {
  return _ProjectModelId.fromJson(json);
}

/// @nodoc
mixin _$ProjectModelId {
  String get value => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ProjectModelIdCopyWith<ProjectModelId> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProjectModelIdCopyWith<$Res> {
  factory $ProjectModelIdCopyWith(
          ProjectModelId value, $Res Function(ProjectModelId) then) =
      _$ProjectModelIdCopyWithImpl<$Res, ProjectModelId>;
  @useResult
  $Res call({String value});
}

/// @nodoc
class _$ProjectModelIdCopyWithImpl<$Res, $Val extends ProjectModelId>
    implements $ProjectModelIdCopyWith<$Res> {
  _$ProjectModelIdCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
  }) {
    return _then(_value.copyWith(
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_ProjectModelIdCopyWith<$Res>
    implements $ProjectModelIdCopyWith<$Res> {
  factory _$$_ProjectModelIdCopyWith(
          _$_ProjectModelId value, $Res Function(_$_ProjectModelId) then) =
      __$$_ProjectModelIdCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String value});
}

/// @nodoc
class __$$_ProjectModelIdCopyWithImpl<$Res>
    extends _$ProjectModelIdCopyWithImpl<$Res, _$_ProjectModelId>
    implements _$$_ProjectModelIdCopyWith<$Res> {
  __$$_ProjectModelIdCopyWithImpl(
      _$_ProjectModelId _value, $Res Function(_$_ProjectModelId) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
  }) {
    return _then(_$_ProjectModelId(
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_ProjectModelId implements _ProjectModelId {
  const _$_ProjectModelId({required this.value});

  factory _$_ProjectModelId.fromJson(Map<String, dynamic> json) =>
      _$$_ProjectModelIdFromJson(json);

  @override
  final String value;

  @override
  String toString() {
    return 'ProjectModelId(value: $value)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_ProjectModelId &&
            (identical(other.value, value) || other.value == value));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, value);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_ProjectModelIdCopyWith<_$_ProjectModelId> get copyWith =>
      __$$_ProjectModelIdCopyWithImpl<_$_ProjectModelId>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_ProjectModelIdToJson(
      this,
    );
  }
}

abstract class _ProjectModelId implements ProjectModelId {
  const factory _ProjectModelId({required final String value}) =
      _$_ProjectModelId;

  factory _ProjectModelId.fromJson(Map<String, dynamic> json) =
      _$_ProjectModelId.fromJson;

  @override
  String get value;
  @override
  @JsonKey(ignore: true)
  _$$_ProjectModelIdCopyWith<_$_ProjectModelId> get copyWith =>
      throw _privateConstructorUsedError;
}

ProjectModel _$ProjectModelFromJson(Map<String, dynamic> json) {
  return NoteProjectModel.fromJson(json);
}

/// @nodoc
mixin _$ProjectModel {
  @JsonKey(
      fromJson: ProjectModelId.fromJson, toJson: ProjectModelId.toStringJson)
  ProjectModelId get id => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  bool get isArchived => throw _privateConstructorUsedError;
  ProjectType get type => throw _privateConstructorUsedError;
  UserModelId get ownerId => throw _privateConstructorUsedError;
  int? get charactersLimit => throw _privateConstructorUsedError;
  DeltaModel get note => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            @JsonKey(fromJson: ProjectModelId.fromJson, toJson: ProjectModelId.toStringJson)
                ProjectModelId id,
            DateTime createdAt,
            DateTime updatedAt,
            bool isArchived,
            ProjectType type,
            UserModelId ownerId,
            int? charactersLimit,
            DeltaModel note)
        note,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            @JsonKey(fromJson: ProjectModelId.fromJson, toJson: ProjectModelId.toStringJson)
                ProjectModelId id,
            DateTime createdAt,
            DateTime updatedAt,
            bool isArchived,
            ProjectType type,
            UserModelId ownerId,
            int? charactersLimit,
            DeltaModel note)?
        note,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            @JsonKey(fromJson: ProjectModelId.fromJson, toJson: ProjectModelId.toStringJson)
                ProjectModelId id,
            DateTime createdAt,
            DateTime updatedAt,
            bool isArchived,
            ProjectType type,
            UserModelId ownerId,
            int? charactersLimit,
            DeltaModel note)?
        note,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NoteProjectModel value) note,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NoteProjectModel value)? note,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NoteProjectModel value)? note,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ProjectModelCopyWith<ProjectModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProjectModelCopyWith<$Res> {
  factory $ProjectModelCopyWith(
          ProjectModel value, $Res Function(ProjectModel) then) =
      _$ProjectModelCopyWithImpl<$Res, ProjectModel>;
  @useResult
  $Res call(
      {@JsonKey(fromJson: ProjectModelId.fromJson, toJson: ProjectModelId.toStringJson)
          ProjectModelId id,
      DateTime createdAt,
      DateTime updatedAt,
      bool isArchived,
      ProjectType type,
      UserModelId ownerId,
      int? charactersLimit,
      DeltaModel note});

  $ProjectModelIdCopyWith<$Res> get id;
  $UserModelIdCopyWith<$Res> get ownerId;
  $DeltaModelCopyWith<$Res> get note;
}

/// @nodoc
class _$ProjectModelCopyWithImpl<$Res, $Val extends ProjectModel>
    implements $ProjectModelCopyWith<$Res> {
  _$ProjectModelCopyWithImpl(this._value, this._then);

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
    Object? isArchived = null,
    Object? type = null,
    Object? ownerId = null,
    Object? charactersLimit = freezed,
    Object? note = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as ProjectModelId,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isArchived: null == isArchived
          ? _value.isArchived
          : isArchived // ignore: cast_nullable_to_non_nullable
              as bool,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ProjectType,
      ownerId: null == ownerId
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as UserModelId,
      charactersLimit: freezed == charactersLimit
          ? _value.charactersLimit
          : charactersLimit // ignore: cast_nullable_to_non_nullable
              as int?,
      note: null == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as DeltaModel,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ProjectModelIdCopyWith<$Res> get id {
    return $ProjectModelIdCopyWith<$Res>(_value.id, (value) {
      return _then(_value.copyWith(id: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $UserModelIdCopyWith<$Res> get ownerId {
    return $UserModelIdCopyWith<$Res>(_value.ownerId, (value) {
      return _then(_value.copyWith(ownerId: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $DeltaModelCopyWith<$Res> get note {
    return $DeltaModelCopyWith<$Res>(_value.note, (value) {
      return _then(_value.copyWith(note: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$NoteProjectModelCopyWith<$Res>
    implements $ProjectModelCopyWith<$Res> {
  factory _$$NoteProjectModelCopyWith(
          _$NoteProjectModel value, $Res Function(_$NoteProjectModel) then) =
      __$$NoteProjectModelCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(fromJson: ProjectModelId.fromJson, toJson: ProjectModelId.toStringJson)
          ProjectModelId id,
      DateTime createdAt,
      DateTime updatedAt,
      bool isArchived,
      ProjectType type,
      UserModelId ownerId,
      int? charactersLimit,
      DeltaModel note});

  @override
  $ProjectModelIdCopyWith<$Res> get id;
  @override
  $UserModelIdCopyWith<$Res> get ownerId;
  @override
  $DeltaModelCopyWith<$Res> get note;
}

/// @nodoc
class __$$NoteProjectModelCopyWithImpl<$Res>
    extends _$ProjectModelCopyWithImpl<$Res, _$NoteProjectModel>
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
    Object? isArchived = null,
    Object? type = null,
    Object? ownerId = null,
    Object? charactersLimit = freezed,
    Object? note = null,
  }) {
    return _then(_$NoteProjectModel(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as ProjectModelId,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isArchived: null == isArchived
          ? _value.isArchived
          : isArchived // ignore: cast_nullable_to_non_nullable
              as bool,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ProjectType,
      ownerId: null == ownerId
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as UserModelId,
      charactersLimit: freezed == charactersLimit
          ? _value.charactersLimit
          : charactersLimit // ignore: cast_nullable_to_non_nullable
              as int?,
      note: null == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as DeltaModel,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class _$NoteProjectModel implements NoteProjectModel {
  const _$NoteProjectModel(
      {@JsonKey(fromJson: ProjectModelId.fromJson, toJson: ProjectModelId.toStringJson)
          required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.isArchived,
      required this.type,
      required this.ownerId,
      required this.charactersLimit,
      required this.note});

  factory _$NoteProjectModel.fromJson(Map<String, dynamic> json) =>
      _$$NoteProjectModelFromJson(json);

  @override
  @JsonKey(
      fromJson: ProjectModelId.fromJson, toJson: ProjectModelId.toStringJson)
  final ProjectModelId id;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final bool isArchived;
  @override
  final ProjectType type;
  @override
  final UserModelId ownerId;
  @override
  final int? charactersLimit;
  @override
  final DeltaModel note;

  @override
  String toString() {
    return 'ProjectModel.note(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, isArchived: $isArchived, type: $type, ownerId: $ownerId, charactersLimit: $charactersLimit, note: $note)';
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
            (identical(other.isArchived, isArchived) ||
                other.isArchived == isArchived) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.ownerId, ownerId) || other.ownerId == ownerId) &&
            (identical(other.charactersLimit, charactersLimit) ||
                other.charactersLimit == charactersLimit) &&
            (identical(other.note, note) || other.note == note));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, createdAt, updatedAt,
      isArchived, type, ownerId, charactersLimit, note);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NoteProjectModelCopyWith<_$NoteProjectModel> get copyWith =>
      __$$NoteProjectModelCopyWithImpl<_$NoteProjectModel>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            @JsonKey(fromJson: ProjectModelId.fromJson, toJson: ProjectModelId.toStringJson)
                ProjectModelId id,
            DateTime createdAt,
            DateTime updatedAt,
            bool isArchived,
            ProjectType type,
            UserModelId ownerId,
            int? charactersLimit,
            DeltaModel note)
        note,
  }) {
    return note(id, createdAt, updatedAt, isArchived, type, ownerId,
        charactersLimit, this.note);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            @JsonKey(fromJson: ProjectModelId.fromJson, toJson: ProjectModelId.toStringJson)
                ProjectModelId id,
            DateTime createdAt,
            DateTime updatedAt,
            bool isArchived,
            ProjectType type,
            UserModelId ownerId,
            int? charactersLimit,
            DeltaModel note)?
        note,
  }) {
    return note?.call(id, createdAt, updatedAt, isArchived, type, ownerId,
        charactersLimit, this.note);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            @JsonKey(fromJson: ProjectModelId.fromJson, toJson: ProjectModelId.toStringJson)
                ProjectModelId id,
            DateTime createdAt,
            DateTime updatedAt,
            bool isArchived,
            ProjectType type,
            UserModelId ownerId,
            int? charactersLimit,
            DeltaModel note)?
        note,
    required TResult orElse(),
  }) {
    if (note != null) {
      return note(id, createdAt, updatedAt, isArchived, type, ownerId,
          charactersLimit, this.note);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NoteProjectModel value) note,
  }) {
    return note(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NoteProjectModel value)? note,
  }) {
    return note?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NoteProjectModel value)? note,
    required TResult orElse(),
  }) {
    if (note != null) {
      return note(this);
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

abstract class NoteProjectModel implements ProjectModel {
  const factory NoteProjectModel(
      {@JsonKey(fromJson: ProjectModelId.fromJson, toJson: ProjectModelId.toStringJson)
          required final ProjectModelId id,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      required final bool isArchived,
      required final ProjectType type,
      required final UserModelId ownerId,
      required final int? charactersLimit,
      required final DeltaModel note}) = _$NoteProjectModel;

  factory NoteProjectModel.fromJson(Map<String, dynamic> json) =
      _$NoteProjectModel.fromJson;

  @override
  @JsonKey(
      fromJson: ProjectModelId.fromJson, toJson: ProjectModelId.toStringJson)
  ProjectModelId get id;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  bool get isArchived;
  @override
  ProjectType get type;
  @override
  UserModelId get ownerId;
  @override
  int? get charactersLimit;
  @override
  DeltaModel get note;
  @override
  @JsonKey(ignore: true)
  _$$NoteProjectModelCopyWith<_$NoteProjectModel> get copyWith =>
      throw _privateConstructorUsedError;
}

DeltaModel _$DeltaModelFromJson(Map<String, dynamic> json) {
  return _DeltaModel.fromJson(json);
}

/// @nodoc
mixin _$DeltaModel {
  @JsonKey(fromJson: DeltaModel._deltaFromJson, toJson: DeltaModel._deltaToJson)
  Delta get value => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DeltaModelCopyWith<DeltaModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeltaModelCopyWith<$Res> {
  factory $DeltaModelCopyWith(
          DeltaModel value, $Res Function(DeltaModel) then) =
      _$DeltaModelCopyWithImpl<$Res, DeltaModel>;
  @useResult
  $Res call(
      {@JsonKey(fromJson: DeltaModel._deltaFromJson, toJson: DeltaModel._deltaToJson)
          Delta value});
}

/// @nodoc
class _$DeltaModelCopyWithImpl<$Res, $Val extends DeltaModel>
    implements $DeltaModelCopyWith<$Res> {
  _$DeltaModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
  }) {
    return _then(_value.copyWith(
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as Delta,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_DeltaModelCopyWith<$Res>
    implements $DeltaModelCopyWith<$Res> {
  factory _$$_DeltaModelCopyWith(
          _$_DeltaModel value, $Res Function(_$_DeltaModel) then) =
      __$$_DeltaModelCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(fromJson: DeltaModel._deltaFromJson, toJson: DeltaModel._deltaToJson)
          Delta value});
}

/// @nodoc
class __$$_DeltaModelCopyWithImpl<$Res>
    extends _$DeltaModelCopyWithImpl<$Res, _$_DeltaModel>
    implements _$$_DeltaModelCopyWith<$Res> {
  __$$_DeltaModelCopyWithImpl(
      _$_DeltaModel _value, $Res Function(_$_DeltaModel) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
  }) {
    return _then(_$_DeltaModel(
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as Delta,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$_DeltaModel extends _DeltaModel {
  const _$_DeltaModel(
      {@JsonKey(fromJson: DeltaModel._deltaFromJson, toJson: DeltaModel._deltaToJson)
          required this.value})
      : super._();

  factory _$_DeltaModel.fromJson(Map<String, dynamic> json) =>
      _$$_DeltaModelFromJson(json);

  @override
  @JsonKey(fromJson: DeltaModel._deltaFromJson, toJson: DeltaModel._deltaToJson)
  final Delta value;

  @override
  String toString() {
    return 'DeltaModel(value: $value)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_DeltaModel &&
            (identical(other.value, value) || other.value == value));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, value);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_DeltaModelCopyWith<_$_DeltaModel> get copyWith =>
      __$$_DeltaModelCopyWithImpl<_$_DeltaModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_DeltaModelToJson(
      this,
    );
  }
}

abstract class _DeltaModel extends DeltaModel {
  const factory _DeltaModel(
      {@JsonKey(fromJson: DeltaModel._deltaFromJson, toJson: DeltaModel._deltaToJson)
          required final Delta value}) = _$_DeltaModel;
  const _DeltaModel._() : super._();

  factory _DeltaModel.fromJson(Map<String, dynamic> json) =
      _$_DeltaModel.fromJson;

  @override
  @JsonKey(fromJson: DeltaModel._deltaFromJson, toJson: DeltaModel._deltaToJson)
  Delta get value;
  @override
  @JsonKey(ignore: true)
  _$$_DeltaModelCopyWith<_$_DeltaModel> get copyWith =>
      throw _privateConstructorUsedError;
}

UserModelId _$UserModelIdFromJson(Map<String, dynamic> json) {
  return _UserModelId.fromJson(json);
}

/// @nodoc
mixin _$UserModelId {
  String get value => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserModelIdCopyWith<UserModelId> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserModelIdCopyWith<$Res> {
  factory $UserModelIdCopyWith(
          UserModelId value, $Res Function(UserModelId) then) =
      _$UserModelIdCopyWithImpl<$Res, UserModelId>;
  @useResult
  $Res call({String value});
}

/// @nodoc
class _$UserModelIdCopyWithImpl<$Res, $Val extends UserModelId>
    implements $UserModelIdCopyWith<$Res> {
  _$UserModelIdCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
  }) {
    return _then(_value.copyWith(
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_UserModelIdCopyWith<$Res>
    implements $UserModelIdCopyWith<$Res> {
  factory _$$_UserModelIdCopyWith(
          _$_UserModelId value, $Res Function(_$_UserModelId) then) =
      __$$_UserModelIdCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String value});
}

/// @nodoc
class __$$_UserModelIdCopyWithImpl<$Res>
    extends _$UserModelIdCopyWithImpl<$Res, _$_UserModelId>
    implements _$$_UserModelIdCopyWith<$Res> {
  __$$_UserModelIdCopyWithImpl(
      _$_UserModelId _value, $Res Function(_$_UserModelId) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
  }) {
    return _then(_$_UserModelId(
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_UserModelId implements _UserModelId {
  const _$_UserModelId({required this.value});

  factory _$_UserModelId.fromJson(Map<String, dynamic> json) =>
      _$$_UserModelIdFromJson(json);

  @override
  final String value;

  @override
  String toString() {
    return 'UserModelId(value: $value)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_UserModelId &&
            (identical(other.value, value) || other.value == value));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, value);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_UserModelIdCopyWith<_$_UserModelId> get copyWith =>
      __$$_UserModelIdCopyWithImpl<_$_UserModelId>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_UserModelIdToJson(
      this,
    );
  }
}

abstract class _UserModelId implements UserModelId {
  const factory _UserModelId({required final String value}) = _$_UserModelId;

  factory _UserModelId.fromJson(Map<String, dynamic> json) =
      _$_UserModelId.fromJson;

  @override
  String get value;
  @override
  @JsonKey(ignore: true)
  _$$_UserModelIdCopyWith<_$_UserModelId> get copyWith =>
      throw _privateConstructorUsedError;
}

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return _UserModel.fromJson(json);
}

/// @nodoc
mixin _$UserModel {
  @JsonKey(fromJson: UserModelId.fromJson, toJson: UserModelId.toStringJson)
  UserModelId get id => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  SubscriptionModel get subscription => throw _privateConstructorUsedError;

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
  $Res call(
      {@JsonKey(fromJson: UserModelId.fromJson, toJson: UserModelId.toStringJson)
          UserModelId id,
      DateTime createdAt,
      DateTime updatedAt,
      SubscriptionModel subscription});

  $UserModelIdCopyWith<$Res> get id;
  $SubscriptionModelCopyWith<$Res> get subscription;
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
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? subscription = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as UserModelId,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      subscription: null == subscription
          ? _value.subscription
          : subscription // ignore: cast_nullable_to_non_nullable
              as SubscriptionModel,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $UserModelIdCopyWith<$Res> get id {
    return $UserModelIdCopyWith<$Res>(_value.id, (value) {
      return _then(_value.copyWith(id: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $SubscriptionModelCopyWith<$Res> get subscription {
    return $SubscriptionModelCopyWith<$Res>(_value.subscription, (value) {
      return _then(_value.copyWith(subscription: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_UserModelCopyWith<$Res> implements $UserModelCopyWith<$Res> {
  factory _$$_UserModelCopyWith(
          _$_UserModel value, $Res Function(_$_UserModel) then) =
      __$$_UserModelCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(fromJson: UserModelId.fromJson, toJson: UserModelId.toStringJson)
          UserModelId id,
      DateTime createdAt,
      DateTime updatedAt,
      SubscriptionModel subscription});

  @override
  $UserModelIdCopyWith<$Res> get id;
  @override
  $SubscriptionModelCopyWith<$Res> get subscription;
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
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? subscription = null,
  }) {
    return _then(_$_UserModel(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as UserModelId,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      subscription: null == subscription
          ? _value.subscription
          : subscription // ignore: cast_nullable_to_non_nullable
              as SubscriptionModel,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class _$_UserModel extends _UserModel {
  const _$_UserModel(
      {@JsonKey(fromJson: UserModelId.fromJson, toJson: UserModelId.toStringJson)
          required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.subscription})
      : super._();

  factory _$_UserModel.fromJson(Map<String, dynamic> json) =>
      _$$_UserModelFromJson(json);

  @override
  @JsonKey(fromJson: UserModelId.fromJson, toJson: UserModelId.toStringJson)
  final UserModelId id;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final SubscriptionModel subscription;

  @override
  String toString() {
    return 'UserModel(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, subscription: $subscription)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_UserModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.subscription, subscription) ||
                other.subscription == subscription));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, createdAt, updatedAt, subscription);

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
      {@JsonKey(fromJson: UserModelId.fromJson, toJson: UserModelId.toStringJson)
          required final UserModelId id,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      required final SubscriptionModel subscription}) = _$_UserModel;
  const _UserModel._() : super._();

  factory _UserModel.fromJson(Map<String, dynamic> json) =
      _$_UserModel.fromJson;

  @override
  @JsonKey(fromJson: UserModelId.fromJson, toJson: UserModelId.toStringJson)
  UserModelId get id;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  SubscriptionModel get subscription;
  @override
  @JsonKey(ignore: true)
  _$$_UserModelCopyWith<_$_UserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

SubscriptionModel _$SubscriptionModelFromJson(Map<String, dynamic> json) {
  return _SubscriptionModel.fromJson(json);
}

/// @nodoc
mixin _$SubscriptionModel {
  int get paidDaysLeft => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SubscriptionModelCopyWith<SubscriptionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubscriptionModelCopyWith<$Res> {
  factory $SubscriptionModelCopyWith(
          SubscriptionModel value, $Res Function(SubscriptionModel) then) =
      _$SubscriptionModelCopyWithImpl<$Res, SubscriptionModel>;
  @useResult
  $Res call({int paidDaysLeft});
}

/// @nodoc
class _$SubscriptionModelCopyWithImpl<$Res, $Val extends SubscriptionModel>
    implements $SubscriptionModelCopyWith<$Res> {
  _$SubscriptionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? paidDaysLeft = null,
  }) {
    return _then(_value.copyWith(
      paidDaysLeft: null == paidDaysLeft
          ? _value.paidDaysLeft
          : paidDaysLeft // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_SubscriptionModelCopyWith<$Res>
    implements $SubscriptionModelCopyWith<$Res> {
  factory _$$_SubscriptionModelCopyWith(_$_SubscriptionModel value,
          $Res Function(_$_SubscriptionModel) then) =
      __$$_SubscriptionModelCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int paidDaysLeft});
}

/// @nodoc
class __$$_SubscriptionModelCopyWithImpl<$Res>
    extends _$SubscriptionModelCopyWithImpl<$Res, _$_SubscriptionModel>
    implements _$$_SubscriptionModelCopyWith<$Res> {
  __$$_SubscriptionModelCopyWithImpl(
      _$_SubscriptionModel _value, $Res Function(_$_SubscriptionModel) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? paidDaysLeft = null,
  }) {
    return _then(_$_SubscriptionModel(
      paidDaysLeft: null == paidDaysLeft
          ? _value.paidDaysLeft
          : paidDaysLeft // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class _$_SubscriptionModel implements _SubscriptionModel {
  const _$_SubscriptionModel({this.paidDaysLeft = 0});

  factory _$_SubscriptionModel.fromJson(Map<String, dynamic> json) =>
      _$$_SubscriptionModelFromJson(json);

  @override
  @JsonKey()
  final int paidDaysLeft;

  @override
  String toString() {
    return 'SubscriptionModel(paidDaysLeft: $paidDaysLeft)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_SubscriptionModel &&
            (identical(other.paidDaysLeft, paidDaysLeft) ||
                other.paidDaysLeft == paidDaysLeft));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, paidDaysLeft);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_SubscriptionModelCopyWith<_$_SubscriptionModel> get copyWith =>
      __$$_SubscriptionModelCopyWithImpl<_$_SubscriptionModel>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_SubscriptionModelToJson(
      this,
    );
  }
}

abstract class _SubscriptionModel implements SubscriptionModel {
  const factory _SubscriptionModel({final int paidDaysLeft}) =
      _$_SubscriptionModel;

  factory _SubscriptionModel.fromJson(Map<String, dynamic> json) =
      _$_SubscriptionModel.fromJson;

  @override
  int get paidDaysLeft;
  @override
  @JsonKey(ignore: true)
  _$$_SubscriptionModelCopyWith<_$_SubscriptionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

UserPermissionsModel _$UserPermissionsModelFromJson(Map<String, dynamic> json) {
  return _UserPermissionsModel.fromJson(json);
}

/// @nodoc
mixin _$UserPermissionsModel {
  bool get shouldBeSynced => throw _privateConstructorUsedError;
  int get tagLimit => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserPermissionsModelCopyWith<UserPermissionsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserPermissionsModelCopyWith<$Res> {
  factory $UserPermissionsModelCopyWith(UserPermissionsModel value,
          $Res Function(UserPermissionsModel) then) =
      _$UserPermissionsModelCopyWithImpl<$Res, UserPermissionsModel>;
  @useResult
  $Res call({bool shouldBeSynced, int tagLimit});
}

/// @nodoc
class _$UserPermissionsModelCopyWithImpl<$Res,
        $Val extends UserPermissionsModel>
    implements $UserPermissionsModelCopyWith<$Res> {
  _$UserPermissionsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? shouldBeSynced = null,
    Object? tagLimit = null,
  }) {
    return _then(_value.copyWith(
      shouldBeSynced: null == shouldBeSynced
          ? _value.shouldBeSynced
          : shouldBeSynced // ignore: cast_nullable_to_non_nullable
              as bool,
      tagLimit: null == tagLimit
          ? _value.tagLimit
          : tagLimit // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_UserPermissionsModelCopyWith<$Res>
    implements $UserPermissionsModelCopyWith<$Res> {
  factory _$$_UserPermissionsModelCopyWith(_$_UserPermissionsModel value,
          $Res Function(_$_UserPermissionsModel) then) =
      __$$_UserPermissionsModelCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool shouldBeSynced, int tagLimit});
}

/// @nodoc
class __$$_UserPermissionsModelCopyWithImpl<$Res>
    extends _$UserPermissionsModelCopyWithImpl<$Res, _$_UserPermissionsModel>
    implements _$$_UserPermissionsModelCopyWith<$Res> {
  __$$_UserPermissionsModelCopyWithImpl(_$_UserPermissionsModel _value,
      $Res Function(_$_UserPermissionsModel) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? shouldBeSynced = null,
    Object? tagLimit = null,
  }) {
    return _then(_$_UserPermissionsModel(
      shouldBeSynced: null == shouldBeSynced
          ? _value.shouldBeSynced
          : shouldBeSynced // ignore: cast_nullable_to_non_nullable
              as bool,
      tagLimit: null == tagLimit
          ? _value.tagLimit
          : tagLimit // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class _$_UserPermissionsModel implements _UserPermissionsModel {
  const _$_UserPermissionsModel(
      {this.shouldBeSynced = false, this.tagLimit = 5});

  factory _$_UserPermissionsModel.fromJson(Map<String, dynamic> json) =>
      _$$_UserPermissionsModelFromJson(json);

  @override
  @JsonKey()
  final bool shouldBeSynced;
  @override
  @JsonKey()
  final int tagLimit;

  @override
  String toString() {
    return 'UserPermissionsModel(shouldBeSynced: $shouldBeSynced, tagLimit: $tagLimit)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_UserPermissionsModel &&
            (identical(other.shouldBeSynced, shouldBeSynced) ||
                other.shouldBeSynced == shouldBeSynced) &&
            (identical(other.tagLimit, tagLimit) ||
                other.tagLimit == tagLimit));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, shouldBeSynced, tagLimit);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_UserPermissionsModelCopyWith<_$_UserPermissionsModel> get copyWith =>
      __$$_UserPermissionsModelCopyWithImpl<_$_UserPermissionsModel>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_UserPermissionsModelToJson(
      this,
    );
  }
}

abstract class _UserPermissionsModel implements UserPermissionsModel {
  const factory _UserPermissionsModel(
      {final bool shouldBeSynced,
      final int tagLimit}) = _$_UserPermissionsModel;

  factory _UserPermissionsModel.fromJson(Map<String, dynamic> json) =
      _$_UserPermissionsModel.fromJson;

  @override
  bool get shouldBeSynced;
  @override
  int get tagLimit;
  @override
  @JsonKey(ignore: true)
  _$$_UserPermissionsModelCopyWith<_$_UserPermissionsModel> get copyWith =>
      throw _privateConstructorUsedError;
}
