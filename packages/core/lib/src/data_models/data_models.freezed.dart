// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'data_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

EmojiModel _$EmojiModelFromJson(Map<String, dynamic> json) {
  return _EmojiModel.fromJson(json);
}

/// @nodoc
mixin _$EmojiModel {
  String get category => throw _privateConstructorUsedError;
  String get emoji => throw _privateConstructorUsedError;
  String get keywords => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $EmojiModelCopyWith<EmojiModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EmojiModelCopyWith<$Res> {
  factory $EmojiModelCopyWith(
          EmojiModel value, $Res Function(EmojiModel) then) =
      _$EmojiModelCopyWithImpl<$Res, EmojiModel>;
  @useResult
  $Res call({String category, String emoji, String keywords});
}

/// @nodoc
class _$EmojiModelCopyWithImpl<$Res, $Val extends EmojiModel>
    implements $EmojiModelCopyWith<$Res> {
  _$EmojiModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = null,
    Object? emoji = null,
    Object? keywords = null,
  }) {
    return _then(_value.copyWith(
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      emoji: null == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
      keywords: null == keywords
          ? _value.keywords
          : keywords // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EmojiModelImplCopyWith<$Res>
    implements $EmojiModelCopyWith<$Res> {
  factory _$$EmojiModelImplCopyWith(
          _$EmojiModelImpl value, $Res Function(_$EmojiModelImpl) then) =
      __$$EmojiModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String category, String emoji, String keywords});
}

/// @nodoc
class __$$EmojiModelImplCopyWithImpl<$Res>
    extends _$EmojiModelCopyWithImpl<$Res, _$EmojiModelImpl>
    implements _$$EmojiModelImplCopyWith<$Res> {
  __$$EmojiModelImplCopyWithImpl(
      _$EmojiModelImpl _value, $Res Function(_$EmojiModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = null,
    Object? emoji = null,
    Object? keywords = null,
  }) {
    return _then(_$EmojiModelImpl(
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      emoji: null == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
      keywords: null == keywords
          ? _value.keywords
          : keywords // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EmojiModelImpl implements _EmojiModel {
  const _$EmojiModelImpl(
      {required this.category, required this.emoji, required this.keywords});

  factory _$EmojiModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$EmojiModelImplFromJson(json);

  @override
  final String category;
  @override
  final String emoji;
  @override
  final String keywords;

  @override
  String toString() {
    return 'EmojiModel(category: $category, emoji: $emoji, keywords: $keywords)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EmojiModelImpl &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.emoji, emoji) || other.emoji == emoji) &&
            (identical(other.keywords, keywords) ||
                other.keywords == keywords));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, category, emoji, keywords);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$EmojiModelImplCopyWith<_$EmojiModelImpl> get copyWith =>
      __$$EmojiModelImplCopyWithImpl<_$EmojiModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EmojiModelImplToJson(
      this,
    );
  }
}

abstract class _EmojiModel implements EmojiModel {
  const factory _EmojiModel(
      {required final String category,
      required final String emoji,
      required final String keywords}) = _$EmojiModelImpl;

  factory _EmojiModel.fromJson(Map<String, dynamic> json) =
      _$EmojiModelImpl.fromJson;

  @override
  String get category;
  @override
  String get emoji;
  @override
  String get keywords;
  @override
  @JsonKey(ignore: true)
  _$$EmojiModelImplCopyWith<_$EmojiModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

NotificationMessageModel _$NotificationMessageModelFromJson(
    Map<String, dynamic> json) {
  return _NotificationMessageModel.fromJson(json);
}

/// @nodoc
mixin _$NotificationMessageModel {
  String get id => throw _privateConstructorUsedError;
  LocalizedTextModel get message => throw _privateConstructorUsedError;
  LocalizedTextModel get title => throw _privateConstructorUsedError;
  DateTime get created => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $NotificationMessageModelCopyWith<NotificationMessageModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationMessageModelCopyWith<$Res> {
  factory $NotificationMessageModelCopyWith(NotificationMessageModel value,
          $Res Function(NotificationMessageModel) then) =
      _$NotificationMessageModelCopyWithImpl<$Res, NotificationMessageModel>;
  @useResult
  $Res call(
      {String id,
      LocalizedTextModel message,
      LocalizedTextModel title,
      DateTime created});

  $LocalizedTextModelCopyWith<$Res> get message;
  $LocalizedTextModelCopyWith<$Res> get title;
}

/// @nodoc
class _$NotificationMessageModelCopyWithImpl<$Res,
        $Val extends NotificationMessageModel>
    implements $NotificationMessageModelCopyWith<$Res> {
  _$NotificationMessageModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? message = null,
    Object? title = null,
    Object? created = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as LocalizedTextModel,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as LocalizedTextModel,
      created: null == created
          ? _value.created
          : created // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $LocalizedTextModelCopyWith<$Res> get message {
    return $LocalizedTextModelCopyWith<$Res>(_value.message, (value) {
      return _then(_value.copyWith(message: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $LocalizedTextModelCopyWith<$Res> get title {
    return $LocalizedTextModelCopyWith<$Res>(_value.title, (value) {
      return _then(_value.copyWith(title: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$NotificationMessageModelImplCopyWith<$Res>
    implements $NotificationMessageModelCopyWith<$Res> {
  factory _$$NotificationMessageModelImplCopyWith(
          _$NotificationMessageModelImpl value,
          $Res Function(_$NotificationMessageModelImpl) then) =
      __$$NotificationMessageModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      LocalizedTextModel message,
      LocalizedTextModel title,
      DateTime created});

  @override
  $LocalizedTextModelCopyWith<$Res> get message;
  @override
  $LocalizedTextModelCopyWith<$Res> get title;
}

/// @nodoc
class __$$NotificationMessageModelImplCopyWithImpl<$Res>
    extends _$NotificationMessageModelCopyWithImpl<$Res,
        _$NotificationMessageModelImpl>
    implements _$$NotificationMessageModelImplCopyWith<$Res> {
  __$$NotificationMessageModelImplCopyWithImpl(
      _$NotificationMessageModelImpl _value,
      $Res Function(_$NotificationMessageModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? message = null,
    Object? title = null,
    Object? created = null,
  }) {
    return _then(_$NotificationMessageModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as LocalizedTextModel,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as LocalizedTextModel,
      created: null == created
          ? _value.created
          : created // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationMessageModelImpl implements _NotificationMessageModel {
  const _$NotificationMessageModelImpl(
      {required this.id,
      required this.message,
      required this.title,
      required this.created});

  factory _$NotificationMessageModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationMessageModelImplFromJson(json);

  @override
  final String id;
  @override
  final LocalizedTextModel message;
  @override
  final LocalizedTextModel title;
  @override
  final DateTime created;

  @override
  String toString() {
    return 'NotificationMessageModel(id: $id, message: $message, title: $title, created: $created)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationMessageModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.created, created) || other.created == created));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, message, title, created);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationMessageModelImplCopyWith<_$NotificationMessageModelImpl>
      get copyWith => __$$NotificationMessageModelImplCopyWithImpl<
          _$NotificationMessageModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationMessageModelImplToJson(
      this,
    );
  }
}

abstract class _NotificationMessageModel implements NotificationMessageModel {
  const factory _NotificationMessageModel(
      {required final String id,
      required final LocalizedTextModel message,
      required final LocalizedTextModel title,
      required final DateTime created}) = _$NotificationMessageModelImpl;

  factory _NotificationMessageModel.fromJson(Map<String, dynamic> json) =
      _$NotificationMessageModelImpl.fromJson;

  @override
  String get id;
  @override
  LocalizedTextModel get message;
  @override
  LocalizedTextModel get title;
  @override
  DateTime get created;
  @override
  @JsonKey(ignore: true)
  _$$NotificationMessageModelImplCopyWith<_$NotificationMessageModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ProjectModelId {
  String get value => throw _privateConstructorUsedError;

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
abstract class _$$ProjectModelIdImplCopyWith<$Res>
    implements $ProjectModelIdCopyWith<$Res> {
  factory _$$ProjectModelIdImplCopyWith(_$ProjectModelIdImpl value,
          $Res Function(_$ProjectModelIdImpl) then) =
      __$$ProjectModelIdImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String value});
}

/// @nodoc
class __$$ProjectModelIdImplCopyWithImpl<$Res>
    extends _$ProjectModelIdCopyWithImpl<$Res, _$ProjectModelIdImpl>
    implements _$$ProjectModelIdImplCopyWith<$Res> {
  __$$ProjectModelIdImplCopyWithImpl(
      _$ProjectModelIdImpl _value, $Res Function(_$ProjectModelIdImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
  }) {
    return _then(_$ProjectModelIdImpl(
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ProjectModelIdImpl extends _ProjectModelId {
  const _$ProjectModelIdImpl({required this.value}) : super._();

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
            other is _$ProjectModelIdImpl &&
            (identical(other.value, value) || other.value == value));
  }

  @override
  int get hashCode => Object.hash(runtimeType, value);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ProjectModelIdImplCopyWith<_$ProjectModelIdImpl> get copyWith =>
      __$$ProjectModelIdImplCopyWithImpl<_$ProjectModelIdImpl>(
          this, _$identity);
}

abstract class _ProjectModelId extends ProjectModelId {
  const factory _ProjectModelId({required final String value}) =
      _$ProjectModelIdImpl;
  const _ProjectModelId._() : super._();

  @override
  String get value;
  @override
  @JsonKey(ignore: true)
  _$$ProjectModelIdImplCopyWith<_$ProjectModelIdImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProjectModel _$ProjectModelFromJson(Map<String, dynamic> json) {
  switch (json['runtimeType']) {
    case 'idea':
      return ProjectModelIdea.fromJson(json);
    case 'note':
      return ProjectModelNote.fromJson(json);

    default:
      throw CheckedFromJsonException(json, 'runtimeType', 'ProjectModel',
          'Invalid union type "${json['runtimeType']}"!');
  }
}

/// @nodoc
mixin _$ProjectModel {
  ProjectModelId get id => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  ProjectTypes get type => throw _privateConstructorUsedError;
  DateTime? get archivedAt => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            ProjectModelId id,
            DateTime createdAt,
            DateTime updatedAt,
            String title,
            ProjectTypes type,
            DateTime? archivedAt,
            List<IdeaProjectAnswerModel> answers)
        idea,
    required TResult Function(
            ProjectModelId id,
            DateTime createdAt,
            DateTime updatedAt,
            String note,
            ProjectTypes type,
            int charactersLimit,
            DateTime? archivedAt)
        note,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            ProjectModelId id,
            DateTime createdAt,
            DateTime updatedAt,
            String title,
            ProjectTypes type,
            DateTime? archivedAt,
            List<IdeaProjectAnswerModel> answers)?
        idea,
    TResult? Function(
            ProjectModelId id,
            DateTime createdAt,
            DateTime updatedAt,
            String note,
            ProjectTypes type,
            int charactersLimit,
            DateTime? archivedAt)?
        note,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            ProjectModelId id,
            DateTime createdAt,
            DateTime updatedAt,
            String title,
            ProjectTypes type,
            DateTime? archivedAt,
            List<IdeaProjectAnswerModel> answers)?
        idea,
    TResult Function(
            ProjectModelId id,
            DateTime createdAt,
            DateTime updatedAt,
            String note,
            ProjectTypes type,
            int charactersLimit,
            DateTime? archivedAt)?
        note,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ProjectModelIdea value) idea,
    required TResult Function(ProjectModelNote value) note,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ProjectModelIdea value)? idea,
    TResult? Function(ProjectModelNote value)? note,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ProjectModelIdea value)? idea,
    TResult Function(ProjectModelNote value)? note,
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
      {ProjectModelId id,
      DateTime createdAt,
      DateTime updatedAt,
      ProjectTypes type,
      DateTime? archivedAt});

  $ProjectModelIdCopyWith<$Res> get id;
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
    Object? type = null,
    Object? archivedAt = freezed,
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
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ProjectTypes,
      archivedAt: freezed == archivedAt
          ? _value.archivedAt
          : archivedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ProjectModelIdCopyWith<$Res> get id {
    return $ProjectModelIdCopyWith<$Res>(_value.id, (value) {
      return _then(_value.copyWith(id: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ProjectModelIdeaImplCopyWith<$Res>
    implements $ProjectModelCopyWith<$Res> {
  factory _$$ProjectModelIdeaImplCopyWith(_$ProjectModelIdeaImpl value,
          $Res Function(_$ProjectModelIdeaImpl) then) =
      __$$ProjectModelIdeaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {ProjectModelId id,
      DateTime createdAt,
      DateTime updatedAt,
      String title,
      ProjectTypes type,
      DateTime? archivedAt,
      List<IdeaProjectAnswerModel> answers});

  @override
  $ProjectModelIdCopyWith<$Res> get id;
}

/// @nodoc
class __$$ProjectModelIdeaImplCopyWithImpl<$Res>
    extends _$ProjectModelCopyWithImpl<$Res, _$ProjectModelIdeaImpl>
    implements _$$ProjectModelIdeaImplCopyWith<$Res> {
  __$$ProjectModelIdeaImplCopyWithImpl(_$ProjectModelIdeaImpl _value,
      $Res Function(_$ProjectModelIdeaImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? title = null,
    Object? type = null,
    Object? archivedAt = freezed,
    Object? answers = null,
  }) {
    return _then(_$ProjectModelIdeaImpl(
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
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ProjectTypes,
      archivedAt: freezed == archivedAt
          ? _value.archivedAt
          : archivedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      answers: null == answers
          ? _value._answers
          : answers // ignore: cast_nullable_to_non_nullable
              as List<IdeaProjectAnswerModel>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProjectModelIdeaImpl extends ProjectModelIdea {
  const _$ProjectModelIdeaImpl(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      this.title = '',
      this.type = ProjectTypes.idea,
      this.archivedAt,
      final List<IdeaProjectAnswerModel> answers = const [],
      final String? $type})
      : _answers = answers,
        $type = $type ?? 'idea',
        super._();

  factory _$ProjectModelIdeaImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProjectModelIdeaImplFromJson(json);

  @override
  final ProjectModelId id;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  @JsonKey()
  final String title;
  @override
  @JsonKey()
  final ProjectTypes type;
  @override
  final DateTime? archivedAt;
  final List<IdeaProjectAnswerModel> _answers;
  @override
  @JsonKey()
  List<IdeaProjectAnswerModel> get answers {
    if (_answers is EqualUnmodifiableListView) return _answers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_answers);
  }

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'ProjectModel.idea(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, title: $title, type: $type, archivedAt: $archivedAt, answers: $answers)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProjectModelIdeaImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.archivedAt, archivedAt) ||
                other.archivedAt == archivedAt) &&
            const DeepCollectionEquality().equals(other._answers, _answers));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, createdAt, updatedAt, title,
      type, archivedAt, const DeepCollectionEquality().hash(_answers));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ProjectModelIdeaImplCopyWith<_$ProjectModelIdeaImpl> get copyWith =>
      __$$ProjectModelIdeaImplCopyWithImpl<_$ProjectModelIdeaImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            ProjectModelId id,
            DateTime createdAt,
            DateTime updatedAt,
            String title,
            ProjectTypes type,
            DateTime? archivedAt,
            List<IdeaProjectAnswerModel> answers)
        idea,
    required TResult Function(
            ProjectModelId id,
            DateTime createdAt,
            DateTime updatedAt,
            String note,
            ProjectTypes type,
            int charactersLimit,
            DateTime? archivedAt)
        note,
  }) {
    return idea(id, createdAt, updatedAt, title, type, archivedAt, answers);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            ProjectModelId id,
            DateTime createdAt,
            DateTime updatedAt,
            String title,
            ProjectTypes type,
            DateTime? archivedAt,
            List<IdeaProjectAnswerModel> answers)?
        idea,
    TResult? Function(
            ProjectModelId id,
            DateTime createdAt,
            DateTime updatedAt,
            String note,
            ProjectTypes type,
            int charactersLimit,
            DateTime? archivedAt)?
        note,
  }) {
    return idea?.call(
        id, createdAt, updatedAt, title, type, archivedAt, answers);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            ProjectModelId id,
            DateTime createdAt,
            DateTime updatedAt,
            String title,
            ProjectTypes type,
            DateTime? archivedAt,
            List<IdeaProjectAnswerModel> answers)?
        idea,
    TResult Function(
            ProjectModelId id,
            DateTime createdAt,
            DateTime updatedAt,
            String note,
            ProjectTypes type,
            int charactersLimit,
            DateTime? archivedAt)?
        note,
    required TResult orElse(),
  }) {
    if (idea != null) {
      return idea(id, createdAt, updatedAt, title, type, archivedAt, answers);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ProjectModelIdea value) idea,
    required TResult Function(ProjectModelNote value) note,
  }) {
    return idea(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ProjectModelIdea value)? idea,
    TResult? Function(ProjectModelNote value)? note,
  }) {
    return idea?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ProjectModelIdea value)? idea,
    TResult Function(ProjectModelNote value)? note,
    required TResult orElse(),
  }) {
    if (idea != null) {
      return idea(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ProjectModelIdeaImplToJson(
      this,
    );
  }
}

abstract class ProjectModelIdea extends ProjectModel
    implements Archivable, Sharable {
  const factory ProjectModelIdea(
      {required final ProjectModelId id,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      final String title,
      final ProjectTypes type,
      final DateTime? archivedAt,
      final List<IdeaProjectAnswerModel> answers}) = _$ProjectModelIdeaImpl;
  const ProjectModelIdea._() : super._();

  factory ProjectModelIdea.fromJson(Map<String, dynamic> json) =
      _$ProjectModelIdeaImpl.fromJson;

  @override
  ProjectModelId get id;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  String get title;
  @override
  ProjectTypes get type;
  @override
  DateTime? get archivedAt;
  List<IdeaProjectAnswerModel> get answers;
  @override
  @JsonKey(ignore: true)
  _$$ProjectModelIdeaImplCopyWith<_$ProjectModelIdeaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ProjectModelNoteImplCopyWith<$Res>
    implements $ProjectModelCopyWith<$Res> {
  factory _$$ProjectModelNoteImplCopyWith(_$ProjectModelNoteImpl value,
          $Res Function(_$ProjectModelNoteImpl) then) =
      __$$ProjectModelNoteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {ProjectModelId id,
      DateTime createdAt,
      DateTime updatedAt,
      String note,
      ProjectTypes type,
      int charactersLimit,
      DateTime? archivedAt});

  @override
  $ProjectModelIdCopyWith<$Res> get id;
}

/// @nodoc
class __$$ProjectModelNoteImplCopyWithImpl<$Res>
    extends _$ProjectModelCopyWithImpl<$Res, _$ProjectModelNoteImpl>
    implements _$$ProjectModelNoteImplCopyWith<$Res> {
  __$$ProjectModelNoteImplCopyWithImpl(_$ProjectModelNoteImpl _value,
      $Res Function(_$ProjectModelNoteImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? note = null,
    Object? type = null,
    Object? charactersLimit = null,
    Object? archivedAt = freezed,
  }) {
    return _then(_$ProjectModelNoteImpl(
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
      note: null == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ProjectTypes,
      charactersLimit: null == charactersLimit
          ? _value.charactersLimit
          : charactersLimit // ignore: cast_nullable_to_non_nullable
              as int,
      archivedAt: freezed == archivedAt
          ? _value.archivedAt
          : archivedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProjectModelNoteImpl extends ProjectModelNote {
  const _$ProjectModelNoteImpl(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      this.note = '',
      this.type = ProjectTypes.note,
      this.charactersLimit = 0,
      this.archivedAt,
      final String? $type})
      : $type = $type ?? 'note',
        super._();

  factory _$ProjectModelNoteImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProjectModelNoteImplFromJson(json);

  @override
  final ProjectModelId id;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  @JsonKey()
  final String note;
  @override
  @JsonKey()
  final ProjectTypes type;
  @override
  @JsonKey()
  final int charactersLimit;
  @override
  final DateTime? archivedAt;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'ProjectModel.note(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, note: $note, type: $type, charactersLimit: $charactersLimit, archivedAt: $archivedAt)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProjectModelNoteImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.charactersLimit, charactersLimit) ||
                other.charactersLimit == charactersLimit) &&
            (identical(other.archivedAt, archivedAt) ||
                other.archivedAt == archivedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, createdAt, updatedAt, note,
      type, charactersLimit, archivedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ProjectModelNoteImplCopyWith<_$ProjectModelNoteImpl> get copyWith =>
      __$$ProjectModelNoteImplCopyWithImpl<_$ProjectModelNoteImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            ProjectModelId id,
            DateTime createdAt,
            DateTime updatedAt,
            String title,
            ProjectTypes type,
            DateTime? archivedAt,
            List<IdeaProjectAnswerModel> answers)
        idea,
    required TResult Function(
            ProjectModelId id,
            DateTime createdAt,
            DateTime updatedAt,
            String note,
            ProjectTypes type,
            int charactersLimit,
            DateTime? archivedAt)
        note,
  }) {
    return note(
        id, createdAt, updatedAt, this.note, type, charactersLimit, archivedAt);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            ProjectModelId id,
            DateTime createdAt,
            DateTime updatedAt,
            String title,
            ProjectTypes type,
            DateTime? archivedAt,
            List<IdeaProjectAnswerModel> answers)?
        idea,
    TResult? Function(
            ProjectModelId id,
            DateTime createdAt,
            DateTime updatedAt,
            String note,
            ProjectTypes type,
            int charactersLimit,
            DateTime? archivedAt)?
        note,
  }) {
    return note?.call(
        id, createdAt, updatedAt, this.note, type, charactersLimit, archivedAt);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            ProjectModelId id,
            DateTime createdAt,
            DateTime updatedAt,
            String title,
            ProjectTypes type,
            DateTime? archivedAt,
            List<IdeaProjectAnswerModel> answers)?
        idea,
    TResult Function(
            ProjectModelId id,
            DateTime createdAt,
            DateTime updatedAt,
            String note,
            ProjectTypes type,
            int charactersLimit,
            DateTime? archivedAt)?
        note,
    required TResult orElse(),
  }) {
    if (note != null) {
      return note(id, createdAt, updatedAt, this.note, type, charactersLimit,
          archivedAt);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ProjectModelIdea value) idea,
    required TResult Function(ProjectModelNote value) note,
  }) {
    return note(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ProjectModelIdea value)? idea,
    TResult? Function(ProjectModelNote value)? note,
  }) {
    return note?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ProjectModelIdea value)? idea,
    TResult Function(ProjectModelNote value)? note,
    required TResult orElse(),
  }) {
    if (note != null) {
      return note(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ProjectModelNoteImplToJson(
      this,
    );
  }
}

abstract class ProjectModelNote extends ProjectModel
    implements Archivable, Sharable {
  const factory ProjectModelNote(
      {required final ProjectModelId id,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      final String note,
      final ProjectTypes type,
      final int charactersLimit,
      final DateTime? archivedAt}) = _$ProjectModelNoteImpl;
  const ProjectModelNote._() : super._();

  factory ProjectModelNote.fromJson(Map<String, dynamic> json) =
      _$ProjectModelNoteImpl.fromJson;

  @override
  ProjectModelId get id;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  String get note;
  @override
  ProjectTypes get type;
  int get charactersLimit;
  @override
  DateTime? get archivedAt;
  @override
  @JsonKey(ignore: true)
  _$$ProjectModelNoteImplCopyWith<_$ProjectModelNoteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$IdeaProjectAnswerModelId {
  String get value => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $IdeaProjectAnswerModelIdCopyWith<IdeaProjectAnswerModelId> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IdeaProjectAnswerModelIdCopyWith<$Res> {
  factory $IdeaProjectAnswerModelIdCopyWith(IdeaProjectAnswerModelId value,
          $Res Function(IdeaProjectAnswerModelId) then) =
      _$IdeaProjectAnswerModelIdCopyWithImpl<$Res, IdeaProjectAnswerModelId>;
  @useResult
  $Res call({String value});
}

/// @nodoc
class _$IdeaProjectAnswerModelIdCopyWithImpl<$Res,
        $Val extends IdeaProjectAnswerModelId>
    implements $IdeaProjectAnswerModelIdCopyWith<$Res> {
  _$IdeaProjectAnswerModelIdCopyWithImpl(this._value, this._then);

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
abstract class _$$IdeaProjectAnswerModelIdImplCopyWith<$Res>
    implements $IdeaProjectAnswerModelIdCopyWith<$Res> {
  factory _$$IdeaProjectAnswerModelIdImplCopyWith(
          _$IdeaProjectAnswerModelIdImpl value,
          $Res Function(_$IdeaProjectAnswerModelIdImpl) then) =
      __$$IdeaProjectAnswerModelIdImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String value});
}

/// @nodoc
class __$$IdeaProjectAnswerModelIdImplCopyWithImpl<$Res>
    extends _$IdeaProjectAnswerModelIdCopyWithImpl<$Res,
        _$IdeaProjectAnswerModelIdImpl>
    implements _$$IdeaProjectAnswerModelIdImplCopyWith<$Res> {
  __$$IdeaProjectAnswerModelIdImplCopyWithImpl(
      _$IdeaProjectAnswerModelIdImpl _value,
      $Res Function(_$IdeaProjectAnswerModelIdImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
  }) {
    return _then(_$IdeaProjectAnswerModelIdImpl(
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$IdeaProjectAnswerModelIdImpl extends _IdeaProjectAnswerModelId {
  const _$IdeaProjectAnswerModelIdImpl({required this.value}) : super._();

  @override
  final String value;

  @override
  String toString() {
    return 'IdeaProjectAnswerModelId(value: $value)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IdeaProjectAnswerModelIdImpl &&
            (identical(other.value, value) || other.value == value));
  }

  @override
  int get hashCode => Object.hash(runtimeType, value);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$IdeaProjectAnswerModelIdImplCopyWith<_$IdeaProjectAnswerModelIdImpl>
      get copyWith => __$$IdeaProjectAnswerModelIdImplCopyWithImpl<
          _$IdeaProjectAnswerModelIdImpl>(this, _$identity);
}

abstract class _IdeaProjectAnswerModelId extends IdeaProjectAnswerModelId {
  const factory _IdeaProjectAnswerModelId({required final String value}) =
      _$IdeaProjectAnswerModelIdImpl;
  const _IdeaProjectAnswerModelId._() : super._();

  @override
  String get value;
  @override
  @JsonKey(ignore: true)
  _$$IdeaProjectAnswerModelIdImplCopyWith<_$IdeaProjectAnswerModelIdImpl>
      get copyWith => throw _privateConstructorUsedError;
}

IdeaProjectAnswerModel _$IdeaProjectAnswerModelFromJson(
    Map<String, dynamic> json) {
  return _IdeaProjectAnswerModel.fromJson(json);
}

/// @nodoc
mixin _$IdeaProjectAnswerModel {
  IdeaProjectAnswerModelId get id => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  IdeaProjectQuestionModel get question => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;

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
      {IdeaProjectAnswerModelId id,
      DateTime createdAt,
      IdeaProjectQuestionModel question,
      String text});

  $IdeaProjectAnswerModelIdCopyWith<$Res> get id;
  $IdeaProjectQuestionModelCopyWith<$Res> get question;
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
    Object? createdAt = null,
    Object? question = null,
    Object? text = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as IdeaProjectAnswerModelId,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      question: null == question
          ? _value.question
          : question // ignore: cast_nullable_to_non_nullable
              as IdeaProjectQuestionModel,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $IdeaProjectAnswerModelIdCopyWith<$Res> get id {
    return $IdeaProjectAnswerModelIdCopyWith<$Res>(_value.id, (value) {
      return _then(_value.copyWith(id: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $IdeaProjectQuestionModelCopyWith<$Res> get question {
    return $IdeaProjectQuestionModelCopyWith<$Res>(_value.question, (value) {
      return _then(_value.copyWith(question: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$IdeaProjectAnswerModelImplCopyWith<$Res>
    implements $IdeaProjectAnswerModelCopyWith<$Res> {
  factory _$$IdeaProjectAnswerModelImplCopyWith(
          _$IdeaProjectAnswerModelImpl value,
          $Res Function(_$IdeaProjectAnswerModelImpl) then) =
      __$$IdeaProjectAnswerModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {IdeaProjectAnswerModelId id,
      DateTime createdAt,
      IdeaProjectQuestionModel question,
      String text});

  @override
  $IdeaProjectAnswerModelIdCopyWith<$Res> get id;
  @override
  $IdeaProjectQuestionModelCopyWith<$Res> get question;
}

/// @nodoc
class __$$IdeaProjectAnswerModelImplCopyWithImpl<$Res>
    extends _$IdeaProjectAnswerModelCopyWithImpl<$Res,
        _$IdeaProjectAnswerModelImpl>
    implements _$$IdeaProjectAnswerModelImplCopyWith<$Res> {
  __$$IdeaProjectAnswerModelImplCopyWithImpl(
      _$IdeaProjectAnswerModelImpl _value,
      $Res Function(_$IdeaProjectAnswerModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? question = null,
    Object? text = null,
  }) {
    return _then(_$IdeaProjectAnswerModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as IdeaProjectAnswerModelId,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      question: null == question
          ? _value.question
          : question // ignore: cast_nullable_to_non_nullable
              as IdeaProjectQuestionModel,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$IdeaProjectAnswerModelImpl extends _IdeaProjectAnswerModel {
  const _$IdeaProjectAnswerModelImpl(
      {required this.id,
      required this.createdAt,
      required this.question,
      this.text = ''})
      : super._();

  factory _$IdeaProjectAnswerModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$IdeaProjectAnswerModelImplFromJson(json);

  @override
  final IdeaProjectAnswerModelId id;
  @override
  final DateTime createdAt;
  @override
  final IdeaProjectQuestionModel question;
  @override
  @JsonKey()
  final String text;

  @override
  String toString() {
    return 'IdeaProjectAnswerModel(id: $id, createdAt: $createdAt, question: $question, text: $text)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IdeaProjectAnswerModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.question, question) ||
                other.question == question) &&
            (identical(other.text, text) || other.text == text));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, createdAt, question, text);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$IdeaProjectAnswerModelImplCopyWith<_$IdeaProjectAnswerModelImpl>
      get copyWith => __$$IdeaProjectAnswerModelImplCopyWithImpl<
          _$IdeaProjectAnswerModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$IdeaProjectAnswerModelImplToJson(
      this,
    );
  }
}

abstract class _IdeaProjectAnswerModel extends IdeaProjectAnswerModel {
  const factory _IdeaProjectAnswerModel(
      {required final IdeaProjectAnswerModelId id,
      required final DateTime createdAt,
      required final IdeaProjectQuestionModel question,
      final String text}) = _$IdeaProjectAnswerModelImpl;
  const _IdeaProjectAnswerModel._() : super._();

  factory _IdeaProjectAnswerModel.fromJson(Map<String, dynamic> json) =
      _$IdeaProjectAnswerModelImpl.fromJson;

  @override
  IdeaProjectAnswerModelId get id;
  @override
  DateTime get createdAt;
  @override
  IdeaProjectQuestionModel get question;
  @override
  String get text;
  @override
  @JsonKey(ignore: true)
  _$$IdeaProjectAnswerModelImplCopyWith<_$IdeaProjectAnswerModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$IdeaProjectQuestionModelId {
  String get value => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $IdeaProjectQuestionModelIdCopyWith<IdeaProjectQuestionModelId>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IdeaProjectQuestionModelIdCopyWith<$Res> {
  factory $IdeaProjectQuestionModelIdCopyWith(IdeaProjectQuestionModelId value,
          $Res Function(IdeaProjectQuestionModelId) then) =
      _$IdeaProjectQuestionModelIdCopyWithImpl<$Res,
          IdeaProjectQuestionModelId>;
  @useResult
  $Res call({String value});
}

/// @nodoc
class _$IdeaProjectQuestionModelIdCopyWithImpl<$Res,
        $Val extends IdeaProjectQuestionModelId>
    implements $IdeaProjectQuestionModelIdCopyWith<$Res> {
  _$IdeaProjectQuestionModelIdCopyWithImpl(this._value, this._then);

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
abstract class _$$IdeaProjectQuestionModelIdImplCopyWith<$Res>
    implements $IdeaProjectQuestionModelIdCopyWith<$Res> {
  factory _$$IdeaProjectQuestionModelIdImplCopyWith(
          _$IdeaProjectQuestionModelIdImpl value,
          $Res Function(_$IdeaProjectQuestionModelIdImpl) then) =
      __$$IdeaProjectQuestionModelIdImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String value});
}

/// @nodoc
class __$$IdeaProjectQuestionModelIdImplCopyWithImpl<$Res>
    extends _$IdeaProjectQuestionModelIdCopyWithImpl<$Res,
        _$IdeaProjectQuestionModelIdImpl>
    implements _$$IdeaProjectQuestionModelIdImplCopyWith<$Res> {
  __$$IdeaProjectQuestionModelIdImplCopyWithImpl(
      _$IdeaProjectQuestionModelIdImpl _value,
      $Res Function(_$IdeaProjectQuestionModelIdImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
  }) {
    return _then(_$IdeaProjectQuestionModelIdImpl(
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$IdeaProjectQuestionModelIdImpl extends _IdeaProjectQuestionModelId {
  const _$IdeaProjectQuestionModelIdImpl({required this.value}) : super._();

  @override
  final String value;

  @override
  String toString() {
    return 'IdeaProjectQuestionModelId(value: $value)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IdeaProjectQuestionModelIdImpl &&
            (identical(other.value, value) || other.value == value));
  }

  @override
  int get hashCode => Object.hash(runtimeType, value);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$IdeaProjectQuestionModelIdImplCopyWith<_$IdeaProjectQuestionModelIdImpl>
      get copyWith => __$$IdeaProjectQuestionModelIdImplCopyWithImpl<
          _$IdeaProjectQuestionModelIdImpl>(this, _$identity);
}

abstract class _IdeaProjectQuestionModelId extends IdeaProjectQuestionModelId {
  const factory _IdeaProjectQuestionModelId({required final String value}) =
      _$IdeaProjectQuestionModelIdImpl;
  const _IdeaProjectQuestionModelId._() : super._();

  @override
  String get value;
  @override
  @JsonKey(ignore: true)
  _$$IdeaProjectQuestionModelIdImplCopyWith<_$IdeaProjectQuestionModelIdImpl>
      get copyWith => throw _privateConstructorUsedError;
}

IdeaProjectQuestionModel _$IdeaProjectQuestionModelFromJson(
    Map<String, dynamic> json) {
  return _IdeaProjectQuestionModel.fromJson(json);
}

/// @nodoc
mixin _$IdeaProjectQuestionModel {
  IdeaProjectQuestionModelId get id => throw _privateConstructorUsedError;
  LocalizedTextModel get title => throw _privateConstructorUsedError;

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
  $Res call({IdeaProjectQuestionModelId id, LocalizedTextModel title});

  $IdeaProjectQuestionModelIdCopyWith<$Res> get id;
  $LocalizedTextModelCopyWith<$Res> get title;
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
              as IdeaProjectQuestionModelId,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as LocalizedTextModel,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $IdeaProjectQuestionModelIdCopyWith<$Res> get id {
    return $IdeaProjectQuestionModelIdCopyWith<$Res>(_value.id, (value) {
      return _then(_value.copyWith(id: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $LocalizedTextModelCopyWith<$Res> get title {
    return $LocalizedTextModelCopyWith<$Res>(_value.title, (value) {
      return _then(_value.copyWith(title: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$IdeaProjectQuestionModelImplCopyWith<$Res>
    implements $IdeaProjectQuestionModelCopyWith<$Res> {
  factory _$$IdeaProjectQuestionModelImplCopyWith(
          _$IdeaProjectQuestionModelImpl value,
          $Res Function(_$IdeaProjectQuestionModelImpl) then) =
      __$$IdeaProjectQuestionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({IdeaProjectQuestionModelId id, LocalizedTextModel title});

  @override
  $IdeaProjectQuestionModelIdCopyWith<$Res> get id;
  @override
  $LocalizedTextModelCopyWith<$Res> get title;
}

/// @nodoc
class __$$IdeaProjectQuestionModelImplCopyWithImpl<$Res>
    extends _$IdeaProjectQuestionModelCopyWithImpl<$Res,
        _$IdeaProjectQuestionModelImpl>
    implements _$$IdeaProjectQuestionModelImplCopyWith<$Res> {
  __$$IdeaProjectQuestionModelImplCopyWithImpl(
      _$IdeaProjectQuestionModelImpl _value,
      $Res Function(_$IdeaProjectQuestionModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
  }) {
    return _then(_$IdeaProjectQuestionModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as IdeaProjectQuestionModelId,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as LocalizedTextModel,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$IdeaProjectQuestionModelImpl extends _IdeaProjectQuestionModel {
  const _$IdeaProjectQuestionModelImpl({required this.id, required this.title})
      : super._();

  factory _$IdeaProjectQuestionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$IdeaProjectQuestionModelImplFromJson(json);

  @override
  final IdeaProjectQuestionModelId id;
  @override
  final LocalizedTextModel title;

  @override
  String toString() {
    return 'IdeaProjectQuestionModel(id: $id, title: $title)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IdeaProjectQuestionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, title);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$IdeaProjectQuestionModelImplCopyWith<_$IdeaProjectQuestionModelImpl>
      get copyWith => __$$IdeaProjectQuestionModelImplCopyWithImpl<
          _$IdeaProjectQuestionModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$IdeaProjectQuestionModelImplToJson(
      this,
    );
  }
}

abstract class _IdeaProjectQuestionModel extends IdeaProjectQuestionModel {
  const factory _IdeaProjectQuestionModel(
          {required final IdeaProjectQuestionModelId id,
          required final LocalizedTextModel title}) =
      _$IdeaProjectQuestionModelImpl;
  const _IdeaProjectQuestionModel._() : super._();

  factory _IdeaProjectQuestionModel.fromJson(Map<String, dynamic> json) =
      _$IdeaProjectQuestionModelImpl.fromJson;

  @override
  IdeaProjectQuestionModelId get id;
  @override
  LocalizedTextModel get title;
  @override
  @JsonKey(ignore: true)
  _$$IdeaProjectQuestionModelImplCopyWith<_$IdeaProjectQuestionModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

LocalizedTextModel _$LocalizedTextModelFromJson(Map<String, dynamic> json) {
  return _LocalizedTextModel.fromJson(json);
}

/// @nodoc
mixin _$LocalizedTextModel {
  String get ru => throw _privateConstructorUsedError;
  String get en => throw _privateConstructorUsedError;
  String get it => throw _privateConstructorUsedError;
  String get ga => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LocalizedTextModelCopyWith<LocalizedTextModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocalizedTextModelCopyWith<$Res> {
  factory $LocalizedTextModelCopyWith(
          LocalizedTextModel value, $Res Function(LocalizedTextModel) then) =
      _$LocalizedTextModelCopyWithImpl<$Res, LocalizedTextModel>;
  @useResult
  $Res call({String ru, String en, String it, String ga});
}

/// @nodoc
class _$LocalizedTextModelCopyWithImpl<$Res, $Val extends LocalizedTextModel>
    implements $LocalizedTextModelCopyWith<$Res> {
  _$LocalizedTextModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ru = null,
    Object? en = null,
    Object? it = null,
    Object? ga = null,
  }) {
    return _then(_value.copyWith(
      ru: null == ru
          ? _value.ru
          : ru // ignore: cast_nullable_to_non_nullable
              as String,
      en: null == en
          ? _value.en
          : en // ignore: cast_nullable_to_non_nullable
              as String,
      it: null == it
          ? _value.it
          : it // ignore: cast_nullable_to_non_nullable
              as String,
      ga: null == ga
          ? _value.ga
          : ga // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LocalizedTextModelImplCopyWith<$Res>
    implements $LocalizedTextModelCopyWith<$Res> {
  factory _$$LocalizedTextModelImplCopyWith(_$LocalizedTextModelImpl value,
          $Res Function(_$LocalizedTextModelImpl) then) =
      __$$LocalizedTextModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String ru, String en, String it, String ga});
}

/// @nodoc
class __$$LocalizedTextModelImplCopyWithImpl<$Res>
    extends _$LocalizedTextModelCopyWithImpl<$Res, _$LocalizedTextModelImpl>
    implements _$$LocalizedTextModelImplCopyWith<$Res> {
  __$$LocalizedTextModelImplCopyWithImpl(_$LocalizedTextModelImpl _value,
      $Res Function(_$LocalizedTextModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ru = null,
    Object? en = null,
    Object? it = null,
    Object? ga = null,
  }) {
    return _then(_$LocalizedTextModelImpl(
      ru: null == ru
          ? _value.ru
          : ru // ignore: cast_nullable_to_non_nullable
              as String,
      en: null == en
          ? _value.en
          : en // ignore: cast_nullable_to_non_nullable
              as String,
      it: null == it
          ? _value.it
          : it // ignore: cast_nullable_to_non_nullable
              as String,
      ga: null == ga
          ? _value.ga
          : ga // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LocalizedTextModelImpl extends _LocalizedTextModel {
  const _$LocalizedTextModelImpl(
      {required this.ru, required this.en, this.it = '', this.ga = ''})
      : super._();

  factory _$LocalizedTextModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LocalizedTextModelImplFromJson(json);

  @override
  final String ru;
  @override
  final String en;
  @override
  @JsonKey()
  final String it;
  @override
  @JsonKey()
  final String ga;

  @override
  String toString() {
    return 'LocalizedTextModel(ru: $ru, en: $en, it: $it, ga: $ga)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocalizedTextModelImpl &&
            (identical(other.ru, ru) || other.ru == ru) &&
            (identical(other.en, en) || other.en == en) &&
            (identical(other.it, it) || other.it == it) &&
            (identical(other.ga, ga) || other.ga == ga));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, ru, en, it, ga);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LocalizedTextModelImplCopyWith<_$LocalizedTextModelImpl> get copyWith =>
      __$$LocalizedTextModelImplCopyWithImpl<_$LocalizedTextModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LocalizedTextModelImplToJson(
      this,
    );
  }
}

abstract class _LocalizedTextModel extends LocalizedTextModel {
  const factory _LocalizedTextModel(
      {required final String ru,
      required final String en,
      final String it,
      final String ga}) = _$LocalizedTextModelImpl;
  const _LocalizedTextModel._() : super._();

  factory _LocalizedTextModel.fromJson(Map<String, dynamic> json) =
      _$LocalizedTextModelImpl.fromJson;

  @override
  String get ru;
  @override
  String get en;
  @override
  String get it;
  @override
  String get ga;
  @override
  @JsonKey(ignore: true)
  _$$LocalizedTextModelImplCopyWith<_$LocalizedTextModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AppSettingsModel _$AppSettingsModelFromJson(Map<String, dynamic> json) {
  return _AppSettingsModel.fromJson(json);
}

/// @nodoc
mixin _$AppSettingsModel {
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppSettingsModelCopyWith<$Res> {
  factory $AppSettingsModelCopyWith(
          AppSettingsModel value, $Res Function(AppSettingsModel) then) =
      _$AppSettingsModelCopyWithImpl<$Res, AppSettingsModel>;
}

/// @nodoc
class _$AppSettingsModelCopyWithImpl<$Res, $Val extends AppSettingsModel>
    implements $AppSettingsModelCopyWith<$Res> {
  _$AppSettingsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$AppSettingsModelImplCopyWith<$Res> {
  factory _$$AppSettingsModelImplCopyWith(_$AppSettingsModelImpl value,
          $Res Function(_$AppSettingsModelImpl) then) =
      __$$AppSettingsModelImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$AppSettingsModelImplCopyWithImpl<$Res>
    extends _$AppSettingsModelCopyWithImpl<$Res, _$AppSettingsModelImpl>
    implements _$$AppSettingsModelImplCopyWith<$Res> {
  __$$AppSettingsModelImplCopyWithImpl(_$AppSettingsModelImpl _value,
      $Res Function(_$AppSettingsModelImpl) _then)
      : super(_value, _then);
}

/// @nodoc
@JsonSerializable()
class _$AppSettingsModelImpl implements _AppSettingsModel {
  const _$AppSettingsModelImpl();

  factory _$AppSettingsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppSettingsModelImplFromJson(json);

  @override
  String toString() {
    return 'AppSettingsModel()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$AppSettingsModelImpl);
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => runtimeType.hashCode;

  @override
  Map<String, dynamic> toJson() {
    return _$$AppSettingsModelImplToJson(
      this,
    );
  }
}

abstract class _AppSettingsModel implements AppSettingsModel {
  const factory _AppSettingsModel() = _$AppSettingsModelImpl;

  factory _AppSettingsModel.fromJson(Map<String, dynamic> json) =
      _$AppSettingsModelImpl.fromJson;
}

/// @nodoc
mixin _$UserModelId {
  String get value => throw _privateConstructorUsedError;

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
abstract class _$$UserModelIdImplCopyWith<$Res>
    implements $UserModelIdCopyWith<$Res> {
  factory _$$UserModelIdImplCopyWith(
          _$UserModelIdImpl value, $Res Function(_$UserModelIdImpl) then) =
      __$$UserModelIdImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String value});
}

/// @nodoc
class __$$UserModelIdImplCopyWithImpl<$Res>
    extends _$UserModelIdCopyWithImpl<$Res, _$UserModelIdImpl>
    implements _$$UserModelIdImplCopyWith<$Res> {
  __$$UserModelIdImplCopyWithImpl(
      _$UserModelIdImpl _value, $Res Function(_$UserModelIdImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
  }) {
    return _then(_$UserModelIdImpl(
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$UserModelIdImpl extends _UserModelId {
  const _$UserModelIdImpl({required this.value}) : super._();

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
            other is _$UserModelIdImpl &&
            (identical(other.value, value) || other.value == value));
  }

  @override
  int get hashCode => Object.hash(runtimeType, value);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserModelIdImplCopyWith<_$UserModelIdImpl> get copyWith =>
      __$$UserModelIdImplCopyWithImpl<_$UserModelIdImpl>(this, _$identity);
}

abstract class _UserModelId extends UserModelId {
  const factory _UserModelId({required final String value}) = _$UserModelIdImpl;
  const _UserModelId._() : super._();

  @override
  String get value;
  @override
  @JsonKey(ignore: true)
  _$$UserModelIdImplCopyWith<_$UserModelIdImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return _UserModel.fromJson(json);
}

/// @nodoc
mixin _$UserModel {
  UserSettingsModel get settings => throw _privateConstructorUsedError;
  LocalDbVersion get localDbVersion => throw _privateConstructorUsedError;

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
  $Res call({UserSettingsModel settings, LocalDbVersion localDbVersion});

  $UserSettingsModelCopyWith<$Res> get settings;
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
    Object? settings = null,
    Object? localDbVersion = null,
  }) {
    return _then(_value.copyWith(
      settings: null == settings
          ? _value.settings
          : settings // ignore: cast_nullable_to_non_nullable
              as UserSettingsModel,
      localDbVersion: null == localDbVersion
          ? _value.localDbVersion
          : localDbVersion // ignore: cast_nullable_to_non_nullable
              as LocalDbVersion,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $UserSettingsModelCopyWith<$Res> get settings {
    return $UserSettingsModelCopyWith<$Res>(_value.settings, (value) {
      return _then(_value.copyWith(settings: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UserModelImplCopyWith<$Res>
    implements $UserModelCopyWith<$Res> {
  factory _$$UserModelImplCopyWith(
          _$UserModelImpl value, $Res Function(_$UserModelImpl) then) =
      __$$UserModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({UserSettingsModel settings, LocalDbVersion localDbVersion});

  @override
  $UserSettingsModelCopyWith<$Res> get settings;
}

/// @nodoc
class __$$UserModelImplCopyWithImpl<$Res>
    extends _$UserModelCopyWithImpl<$Res, _$UserModelImpl>
    implements _$$UserModelImplCopyWith<$Res> {
  __$$UserModelImplCopyWithImpl(
      _$UserModelImpl _value, $Res Function(_$UserModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? settings = null,
    Object? localDbVersion = null,
  }) {
    return _then(_$UserModelImpl(
      settings: null == settings
          ? _value.settings
          : settings // ignore: cast_nullable_to_non_nullable
              as UserSettingsModel,
      localDbVersion: null == localDbVersion
          ? _value.localDbVersion
          : localDbVersion // ignore: cast_nullable_to_non_nullable
              as LocalDbVersion,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserModelImpl implements _UserModel {
  const _$UserModelImpl(
      {this.settings = UserSettingsModel.initial,
      this.localDbVersion = LocalDbVersion.v3_16});

  factory _$UserModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserModelImplFromJson(json);

  @override
  @JsonKey()
  final UserSettingsModel settings;
  @override
  @JsonKey()
  final LocalDbVersion localDbVersion;

  @override
  String toString() {
    return 'UserModel(settings: $settings, localDbVersion: $localDbVersion)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserModelImpl &&
            (identical(other.settings, settings) ||
                other.settings == settings) &&
            (identical(other.localDbVersion, localDbVersion) ||
                other.localDbVersion == localDbVersion));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, settings, localDbVersion);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      __$$UserModelImplCopyWithImpl<_$UserModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserModelImplToJson(
      this,
    );
  }
}

abstract class _UserModel implements UserModel {
  const factory _UserModel(
      {final UserSettingsModel settings,
      final LocalDbVersion localDbVersion}) = _$UserModelImpl;

  factory _UserModel.fromJson(Map<String, dynamic> json) =
      _$UserModelImpl.fromJson;

  @override
  UserSettingsModel get settings;
  @override
  LocalDbVersion get localDbVersion;
  @override
  @JsonKey(ignore: true)
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserSettingsModel _$UserSettingsModelFromJson(Map<String, dynamic> json) {
  return _UserSettingsModel.fromJson(json);
}

/// @nodoc
mixin _$UserSettingsModel {
  @JsonKey(fromJson: _themeModeFromJson, toJson: _themeModeToJson)
  ThemeMode get themeMode => throw _privateConstructorUsedError;
  bool get isProjectsListReversed => throw _privateConstructorUsedError;
  int get charactersLimitForNewNotes => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _localeFromJson, toJson: _localeToJson)
  Locale? get locale => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserSettingsModelCopyWith<UserSettingsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserSettingsModelCopyWith<$Res> {
  factory $UserSettingsModelCopyWith(
          UserSettingsModel value, $Res Function(UserSettingsModel) then) =
      _$UserSettingsModelCopyWithImpl<$Res, UserSettingsModel>;
  @useResult
  $Res call(
      {@JsonKey(fromJson: _themeModeFromJson, toJson: _themeModeToJson)
      ThemeMode themeMode,
      bool isProjectsListReversed,
      int charactersLimitForNewNotes,
      @JsonKey(fromJson: _localeFromJson, toJson: _localeToJson)
      Locale? locale});
}

/// @nodoc
class _$UserSettingsModelCopyWithImpl<$Res, $Val extends UserSettingsModel>
    implements $UserSettingsModelCopyWith<$Res> {
  _$UserSettingsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? themeMode = null,
    Object? isProjectsListReversed = null,
    Object? charactersLimitForNewNotes = null,
    Object? locale = freezed,
  }) {
    return _then(_value.copyWith(
      themeMode: null == themeMode
          ? _value.themeMode
          : themeMode // ignore: cast_nullable_to_non_nullable
              as ThemeMode,
      isProjectsListReversed: null == isProjectsListReversed
          ? _value.isProjectsListReversed
          : isProjectsListReversed // ignore: cast_nullable_to_non_nullable
              as bool,
      charactersLimitForNewNotes: null == charactersLimitForNewNotes
          ? _value.charactersLimitForNewNotes
          : charactersLimitForNewNotes // ignore: cast_nullable_to_non_nullable
              as int,
      locale: freezed == locale
          ? _value.locale
          : locale // ignore: cast_nullable_to_non_nullable
              as Locale?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserSettingsModelImplCopyWith<$Res>
    implements $UserSettingsModelCopyWith<$Res> {
  factory _$$UserSettingsModelImplCopyWith(_$UserSettingsModelImpl value,
          $Res Function(_$UserSettingsModelImpl) then) =
      __$$UserSettingsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(fromJson: _themeModeFromJson, toJson: _themeModeToJson)
      ThemeMode themeMode,
      bool isProjectsListReversed,
      int charactersLimitForNewNotes,
      @JsonKey(fromJson: _localeFromJson, toJson: _localeToJson)
      Locale? locale});
}

/// @nodoc
class __$$UserSettingsModelImplCopyWithImpl<$Res>
    extends _$UserSettingsModelCopyWithImpl<$Res, _$UserSettingsModelImpl>
    implements _$$UserSettingsModelImplCopyWith<$Res> {
  __$$UserSettingsModelImplCopyWithImpl(_$UserSettingsModelImpl _value,
      $Res Function(_$UserSettingsModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? themeMode = null,
    Object? isProjectsListReversed = null,
    Object? charactersLimitForNewNotes = null,
    Object? locale = freezed,
  }) {
    return _then(_$UserSettingsModelImpl(
      themeMode: null == themeMode
          ? _value.themeMode
          : themeMode // ignore: cast_nullable_to_non_nullable
              as ThemeMode,
      isProjectsListReversed: null == isProjectsListReversed
          ? _value.isProjectsListReversed
          : isProjectsListReversed // ignore: cast_nullable_to_non_nullable
              as bool,
      charactersLimitForNewNotes: null == charactersLimitForNewNotes
          ? _value.charactersLimitForNewNotes
          : charactersLimitForNewNotes // ignore: cast_nullable_to_non_nullable
              as int,
      locale: freezed == locale
          ? _value.locale
          : locale // ignore: cast_nullable_to_non_nullable
              as Locale?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserSettingsModelImpl implements _UserSettingsModel {
  const _$UserSettingsModelImpl(
      {@JsonKey(fromJson: _themeModeFromJson, toJson: _themeModeToJson)
      this.themeMode = ThemeMode.system,
      this.isProjectsListReversed = false,
      this.charactersLimitForNewNotes = 0,
      @JsonKey(fromJson: _localeFromJson, toJson: _localeToJson) this.locale});

  factory _$UserSettingsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserSettingsModelImplFromJson(json);

  @override
  @JsonKey(fromJson: _themeModeFromJson, toJson: _themeModeToJson)
  final ThemeMode themeMode;
  @override
  @JsonKey()
  final bool isProjectsListReversed;
  @override
  @JsonKey()
  final int charactersLimitForNewNotes;
  @override
  @JsonKey(fromJson: _localeFromJson, toJson: _localeToJson)
  final Locale? locale;

  @override
  String toString() {
    return 'UserSettingsModel(themeMode: $themeMode, isProjectsListReversed: $isProjectsListReversed, charactersLimitForNewNotes: $charactersLimitForNewNotes, locale: $locale)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserSettingsModelImpl &&
            (identical(other.themeMode, themeMode) ||
                other.themeMode == themeMode) &&
            (identical(other.isProjectsListReversed, isProjectsListReversed) ||
                other.isProjectsListReversed == isProjectsListReversed) &&
            (identical(other.charactersLimitForNewNotes,
                    charactersLimitForNewNotes) ||
                other.charactersLimitForNewNotes ==
                    charactersLimitForNewNotes) &&
            (identical(other.locale, locale) || other.locale == locale));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, themeMode,
      isProjectsListReversed, charactersLimitForNewNotes, locale);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserSettingsModelImplCopyWith<_$UserSettingsModelImpl> get copyWith =>
      __$$UserSettingsModelImplCopyWithImpl<_$UserSettingsModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserSettingsModelImplToJson(
      this,
    );
  }
}

abstract class _UserSettingsModel implements UserSettingsModel {
  const factory _UserSettingsModel(
      {@JsonKey(fromJson: _themeModeFromJson, toJson: _themeModeToJson)
      final ThemeMode themeMode,
      final bool isProjectsListReversed,
      final int charactersLimitForNewNotes,
      @JsonKey(fromJson: _localeFromJson, toJson: _localeToJson)
      final Locale? locale}) = _$UserSettingsModelImpl;

  factory _UserSettingsModel.fromJson(Map<String, dynamic> json) =
      _$UserSettingsModelImpl.fromJson;

  @override
  @JsonKey(fromJson: _themeModeFromJson, toJson: _themeModeToJson)
  ThemeMode get themeMode;
  @override
  bool get isProjectsListReversed;
  @override
  int get charactersLimitForNewNotes;
  @override
  @JsonKey(fromJson: _localeFromJson, toJson: _localeToJson)
  Locale? get locale;
  @override
  @JsonKey(ignore: true)
  _$$UserSettingsModelImplCopyWith<_$UserSettingsModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
