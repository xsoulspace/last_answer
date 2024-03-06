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

ProjectModel _$ProjectModelFromJson(Map<String, dynamic> json) {
  switch (json['runtimeType']) {
    case 'idea':
      return ProjectModelIdea.fromJson(json);
    case 'note':
      return ProjectModelNote.fromJson(json);
    case 'changelog':
      return ProjectModelChangelog.fromJson(json);

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
  List<ProjectTagModelId> get tagsIds => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            ProjectModelId id,
            DateTime createdAt,
            DateTime updatedAt,
            String title,
            ProjectTypes type,
            DateTime? archivedAt,
            List<IdeaProjectAnswerModel> answers,
            IdeaProjectAnswerModel? draftAnswer,
            List<ProjectTagModelId> tagsIds)
        idea,
    required TResult Function(
            ProjectModelId id,
            DateTime createdAt,
            DateTime updatedAt,
            String note,
            ProjectTypes type,
            int charactersLimit,
            DateTime? archivedAt,
            List<ProjectTagModelId> tagsIds)
        note,
    required TResult Function(
            DateTime createdAt,
            DateTime updatedAt,
            LocalizedTextModel title,
            ProjectModelId id,
            ProjectTypes type,
            List<ProjectTagModelId> tagsIds)
        changelog,
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
            List<IdeaProjectAnswerModel> answers,
            IdeaProjectAnswerModel? draftAnswer,
            List<ProjectTagModelId> tagsIds)?
        idea,
    TResult? Function(
            ProjectModelId id,
            DateTime createdAt,
            DateTime updatedAt,
            String note,
            ProjectTypes type,
            int charactersLimit,
            DateTime? archivedAt,
            List<ProjectTagModelId> tagsIds)?
        note,
    TResult? Function(
            DateTime createdAt,
            DateTime updatedAt,
            LocalizedTextModel title,
            ProjectModelId id,
            ProjectTypes type,
            List<ProjectTagModelId> tagsIds)?
        changelog,
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
            List<IdeaProjectAnswerModel> answers,
            IdeaProjectAnswerModel? draftAnswer,
            List<ProjectTagModelId> tagsIds)?
        idea,
    TResult Function(
            ProjectModelId id,
            DateTime createdAt,
            DateTime updatedAt,
            String note,
            ProjectTypes type,
            int charactersLimit,
            DateTime? archivedAt,
            List<ProjectTagModelId> tagsIds)?
        note,
    TResult Function(
            DateTime createdAt,
            DateTime updatedAt,
            LocalizedTextModel title,
            ProjectModelId id,
            ProjectTypes type,
            List<ProjectTagModelId> tagsIds)?
        changelog,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ProjectModelIdea value) idea,
    required TResult Function(ProjectModelNote value) note,
    required TResult Function(ProjectModelChangelog value) changelog,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ProjectModelIdea value)? idea,
    TResult? Function(ProjectModelNote value)? note,
    TResult? Function(ProjectModelChangelog value)? changelog,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ProjectModelIdea value)? idea,
    TResult Function(ProjectModelNote value)? note,
    TResult Function(ProjectModelChangelog value)? changelog,
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
      List<ProjectTagModelId> tagsIds});
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
    Object? tagsIds = null,
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
      tagsIds: null == tagsIds
          ? _value.tagsIds
          : tagsIds // ignore: cast_nullable_to_non_nullable
              as List<ProjectTagModelId>,
    ) as $Val);
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
      List<IdeaProjectAnswerModel> answers,
      IdeaProjectAnswerModel? draftAnswer,
      List<ProjectTagModelId> tagsIds});

  $IdeaProjectAnswerModelCopyWith<$Res>? get draftAnswer;
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
    Object? draftAnswer = freezed,
    Object? tagsIds = null,
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
      draftAnswer: freezed == draftAnswer
          ? _value.draftAnswer
          : draftAnswer // ignore: cast_nullable_to_non_nullable
              as IdeaProjectAnswerModel?,
      tagsIds: null == tagsIds
          ? _value._tagsIds
          : tagsIds // ignore: cast_nullable_to_non_nullable
              as List<ProjectTagModelId>,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $IdeaProjectAnswerModelCopyWith<$Res>? get draftAnswer {
    if (_value.draftAnswer == null) {
      return null;
    }

    return $IdeaProjectAnswerModelCopyWith<$Res>(_value.draftAnswer!, (value) {
      return _then(_value.copyWith(draftAnswer: value));
    });
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
      this.draftAnswer,
      final List<ProjectTagModelId> tagsIds = const [],
      final String? $type})
      : _answers = answers,
        _tagsIds = tagsIds,
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

  @override
  final IdeaProjectAnswerModel? draftAnswer;
  final List<ProjectTagModelId> _tagsIds;
  @override
  @JsonKey()
  List<ProjectTagModelId> get tagsIds {
    if (_tagsIds is EqualUnmodifiableListView) return _tagsIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tagsIds);
  }

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'ProjectModel.idea(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, title: $title, type: $type, archivedAt: $archivedAt, answers: $answers, draftAnswer: $draftAnswer, tagsIds: $tagsIds)';
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
            const DeepCollectionEquality().equals(other._answers, _answers) &&
            (identical(other.draftAnswer, draftAnswer) ||
                other.draftAnswer == draftAnswer) &&
            const DeepCollectionEquality().equals(other._tagsIds, _tagsIds));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      createdAt,
      updatedAt,
      title,
      type,
      archivedAt,
      const DeepCollectionEquality().hash(_answers),
      draftAnswer,
      const DeepCollectionEquality().hash(_tagsIds));

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
            List<IdeaProjectAnswerModel> answers,
            IdeaProjectAnswerModel? draftAnswer,
            List<ProjectTagModelId> tagsIds)
        idea,
    required TResult Function(
            ProjectModelId id,
            DateTime createdAt,
            DateTime updatedAt,
            String note,
            ProjectTypes type,
            int charactersLimit,
            DateTime? archivedAt,
            List<ProjectTagModelId> tagsIds)
        note,
    required TResult Function(
            DateTime createdAt,
            DateTime updatedAt,
            LocalizedTextModel title,
            ProjectModelId id,
            ProjectTypes type,
            List<ProjectTagModelId> tagsIds)
        changelog,
  }) {
    return idea(id, createdAt, updatedAt, title, type, archivedAt, answers,
        draftAnswer, tagsIds);
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
            List<IdeaProjectAnswerModel> answers,
            IdeaProjectAnswerModel? draftAnswer,
            List<ProjectTagModelId> tagsIds)?
        idea,
    TResult? Function(
            ProjectModelId id,
            DateTime createdAt,
            DateTime updatedAt,
            String note,
            ProjectTypes type,
            int charactersLimit,
            DateTime? archivedAt,
            List<ProjectTagModelId> tagsIds)?
        note,
    TResult? Function(
            DateTime createdAt,
            DateTime updatedAt,
            LocalizedTextModel title,
            ProjectModelId id,
            ProjectTypes type,
            List<ProjectTagModelId> tagsIds)?
        changelog,
  }) {
    return idea?.call(id, createdAt, updatedAt, title, type, archivedAt,
        answers, draftAnswer, tagsIds);
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
            List<IdeaProjectAnswerModel> answers,
            IdeaProjectAnswerModel? draftAnswer,
            List<ProjectTagModelId> tagsIds)?
        idea,
    TResult Function(
            ProjectModelId id,
            DateTime createdAt,
            DateTime updatedAt,
            String note,
            ProjectTypes type,
            int charactersLimit,
            DateTime? archivedAt,
            List<ProjectTagModelId> tagsIds)?
        note,
    TResult Function(
            DateTime createdAt,
            DateTime updatedAt,
            LocalizedTextModel title,
            ProjectModelId id,
            ProjectTypes type,
            List<ProjectTagModelId> tagsIds)?
        changelog,
    required TResult orElse(),
  }) {
    if (idea != null) {
      return idea(id, createdAt, updatedAt, title, type, archivedAt, answers,
          draftAnswer, tagsIds);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ProjectModelIdea value) idea,
    required TResult Function(ProjectModelNote value) note,
    required TResult Function(ProjectModelChangelog value) changelog,
  }) {
    return idea(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ProjectModelIdea value)? idea,
    TResult? Function(ProjectModelNote value)? note,
    TResult? Function(ProjectModelChangelog value)? changelog,
  }) {
    return idea?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ProjectModelIdea value)? idea,
    TResult Function(ProjectModelNote value)? note,
    TResult Function(ProjectModelChangelog value)? changelog,
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
      final List<IdeaProjectAnswerModel> answers,
      final IdeaProjectAnswerModel? draftAnswer,
      final List<ProjectTagModelId> tagsIds}) = _$ProjectModelIdeaImpl;
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
  DateTime? get archivedAt;
  List<IdeaProjectAnswerModel> get answers;
  IdeaProjectAnswerModel? get draftAnswer;
  @override
  List<ProjectTagModelId> get tagsIds;
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
      DateTime? archivedAt,
      List<ProjectTagModelId> tagsIds});
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
    Object? tagsIds = null,
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
      tagsIds: null == tagsIds
          ? _value._tagsIds
          : tagsIds // ignore: cast_nullable_to_non_nullable
              as List<ProjectTagModelId>,
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
      final List<ProjectTagModelId> tagsIds = const [],
      final String? $type})
      : _tagsIds = tagsIds,
        $type = $type ?? 'note',
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
  final List<ProjectTagModelId> _tagsIds;
  @override
  @JsonKey()
  List<ProjectTagModelId> get tagsIds {
    if (_tagsIds is EqualUnmodifiableListView) return _tagsIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tagsIds);
  }

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'ProjectModel.note(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, note: $note, type: $type, charactersLimit: $charactersLimit, archivedAt: $archivedAt, tagsIds: $tagsIds)';
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
                other.archivedAt == archivedAt) &&
            const DeepCollectionEquality().equals(other._tagsIds, _tagsIds));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      createdAt,
      updatedAt,
      note,
      type,
      charactersLimit,
      archivedAt,
      const DeepCollectionEquality().hash(_tagsIds));

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
            List<IdeaProjectAnswerModel> answers,
            IdeaProjectAnswerModel? draftAnswer,
            List<ProjectTagModelId> tagsIds)
        idea,
    required TResult Function(
            ProjectModelId id,
            DateTime createdAt,
            DateTime updatedAt,
            String note,
            ProjectTypes type,
            int charactersLimit,
            DateTime? archivedAt,
            List<ProjectTagModelId> tagsIds)
        note,
    required TResult Function(
            DateTime createdAt,
            DateTime updatedAt,
            LocalizedTextModel title,
            ProjectModelId id,
            ProjectTypes type,
            List<ProjectTagModelId> tagsIds)
        changelog,
  }) {
    return note(id, createdAt, updatedAt, this.note, type, charactersLimit,
        archivedAt, tagsIds);
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
            List<IdeaProjectAnswerModel> answers,
            IdeaProjectAnswerModel? draftAnswer,
            List<ProjectTagModelId> tagsIds)?
        idea,
    TResult? Function(
            ProjectModelId id,
            DateTime createdAt,
            DateTime updatedAt,
            String note,
            ProjectTypes type,
            int charactersLimit,
            DateTime? archivedAt,
            List<ProjectTagModelId> tagsIds)?
        note,
    TResult? Function(
            DateTime createdAt,
            DateTime updatedAt,
            LocalizedTextModel title,
            ProjectModelId id,
            ProjectTypes type,
            List<ProjectTagModelId> tagsIds)?
        changelog,
  }) {
    return note?.call(id, createdAt, updatedAt, this.note, type,
        charactersLimit, archivedAt, tagsIds);
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
            List<IdeaProjectAnswerModel> answers,
            IdeaProjectAnswerModel? draftAnswer,
            List<ProjectTagModelId> tagsIds)?
        idea,
    TResult Function(
            ProjectModelId id,
            DateTime createdAt,
            DateTime updatedAt,
            String note,
            ProjectTypes type,
            int charactersLimit,
            DateTime? archivedAt,
            List<ProjectTagModelId> tagsIds)?
        note,
    TResult Function(
            DateTime createdAt,
            DateTime updatedAt,
            LocalizedTextModel title,
            ProjectModelId id,
            ProjectTypes type,
            List<ProjectTagModelId> tagsIds)?
        changelog,
    required TResult orElse(),
  }) {
    if (note != null) {
      return note(id, createdAt, updatedAt, this.note, type, charactersLimit,
          archivedAt, tagsIds);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ProjectModelIdea value) idea,
    required TResult Function(ProjectModelNote value) note,
    required TResult Function(ProjectModelChangelog value) changelog,
  }) {
    return note(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ProjectModelIdea value)? idea,
    TResult? Function(ProjectModelNote value)? note,
    TResult? Function(ProjectModelChangelog value)? changelog,
  }) {
    return note?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ProjectModelIdea value)? idea,
    TResult Function(ProjectModelNote value)? note,
    TResult Function(ProjectModelChangelog value)? changelog,
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
      final DateTime? archivedAt,
      final List<ProjectTagModelId> tagsIds}) = _$ProjectModelNoteImpl;
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
  DateTime? get archivedAt;
  @override
  List<ProjectTagModelId> get tagsIds;
  @override
  @JsonKey(ignore: true)
  _$$ProjectModelNoteImplCopyWith<_$ProjectModelNoteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ProjectModelChangelogImplCopyWith<$Res>
    implements $ProjectModelCopyWith<$Res> {
  factory _$$ProjectModelChangelogImplCopyWith(
          _$ProjectModelChangelogImpl value,
          $Res Function(_$ProjectModelChangelogImpl) then) =
      __$$ProjectModelChangelogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime createdAt,
      DateTime updatedAt,
      LocalizedTextModel title,
      ProjectModelId id,
      ProjectTypes type,
      List<ProjectTagModelId> tagsIds});

  $LocalizedTextModelCopyWith<$Res> get title;
}

/// @nodoc
class __$$ProjectModelChangelogImplCopyWithImpl<$Res>
    extends _$ProjectModelCopyWithImpl<$Res, _$ProjectModelChangelogImpl>
    implements _$$ProjectModelChangelogImplCopyWith<$Res> {
  __$$ProjectModelChangelogImplCopyWithImpl(_$ProjectModelChangelogImpl _value,
      $Res Function(_$ProjectModelChangelogImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? title = null,
    Object? id = null,
    Object? type = null,
    Object? tagsIds = null,
  }) {
    return _then(_$ProjectModelChangelogImpl(
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
              as LocalizedTextModel,
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as ProjectModelId,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ProjectTypes,
      tagsIds: null == tagsIds
          ? _value._tagsIds
          : tagsIds // ignore: cast_nullable_to_non_nullable
              as List<ProjectTagModelId>,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $LocalizedTextModelCopyWith<$Res> get title {
    return $LocalizedTextModelCopyWith<$Res>(_value.title, (value) {
      return _then(_value.copyWith(title: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _$ProjectModelChangelogImpl extends ProjectModelChangelog {
  const _$ProjectModelChangelogImpl(
      {required this.createdAt,
      required this.updatedAt,
      this.title = LocalizedTextModel.empty,
      this.id = ProjectModelId.systemChangelog,
      this.type = ProjectTypes.systemChangelog,
      final List<ProjectTagModelId> tagsIds = const [],
      final String? $type})
      : _tagsIds = tagsIds,
        $type = $type ?? 'changelog',
        super._();

  factory _$ProjectModelChangelogImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProjectModelChangelogImplFromJson(json);

  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  @JsonKey()
  final LocalizedTextModel title;
  @override
  @JsonKey()
  final ProjectModelId id;
  @override
  @JsonKey()
  final ProjectTypes type;
  final List<ProjectTagModelId> _tagsIds;
  @override
  @JsonKey()
  List<ProjectTagModelId> get tagsIds {
    if (_tagsIds is EqualUnmodifiableListView) return _tagsIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tagsIds);
  }

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'ProjectModel.changelog(createdAt: $createdAt, updatedAt: $updatedAt, title: $title, id: $id, type: $type, tagsIds: $tagsIds)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProjectModelChangelogImpl &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other._tagsIds, _tagsIds));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, createdAt, updatedAt, title, id,
      type, const DeepCollectionEquality().hash(_tagsIds));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ProjectModelChangelogImplCopyWith<_$ProjectModelChangelogImpl>
      get copyWith => __$$ProjectModelChangelogImplCopyWithImpl<
          _$ProjectModelChangelogImpl>(this, _$identity);

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
            List<IdeaProjectAnswerModel> answers,
            IdeaProjectAnswerModel? draftAnswer,
            List<ProjectTagModelId> tagsIds)
        idea,
    required TResult Function(
            ProjectModelId id,
            DateTime createdAt,
            DateTime updatedAt,
            String note,
            ProjectTypes type,
            int charactersLimit,
            DateTime? archivedAt,
            List<ProjectTagModelId> tagsIds)
        note,
    required TResult Function(
            DateTime createdAt,
            DateTime updatedAt,
            LocalizedTextModel title,
            ProjectModelId id,
            ProjectTypes type,
            List<ProjectTagModelId> tagsIds)
        changelog,
  }) {
    return changelog(createdAt, updatedAt, title, id, type, tagsIds);
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
            List<IdeaProjectAnswerModel> answers,
            IdeaProjectAnswerModel? draftAnswer,
            List<ProjectTagModelId> tagsIds)?
        idea,
    TResult? Function(
            ProjectModelId id,
            DateTime createdAt,
            DateTime updatedAt,
            String note,
            ProjectTypes type,
            int charactersLimit,
            DateTime? archivedAt,
            List<ProjectTagModelId> tagsIds)?
        note,
    TResult? Function(
            DateTime createdAt,
            DateTime updatedAt,
            LocalizedTextModel title,
            ProjectModelId id,
            ProjectTypes type,
            List<ProjectTagModelId> tagsIds)?
        changelog,
  }) {
    return changelog?.call(createdAt, updatedAt, title, id, type, tagsIds);
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
            List<IdeaProjectAnswerModel> answers,
            IdeaProjectAnswerModel? draftAnswer,
            List<ProjectTagModelId> tagsIds)?
        idea,
    TResult Function(
            ProjectModelId id,
            DateTime createdAt,
            DateTime updatedAt,
            String note,
            ProjectTypes type,
            int charactersLimit,
            DateTime? archivedAt,
            List<ProjectTagModelId> tagsIds)?
        note,
    TResult Function(
            DateTime createdAt,
            DateTime updatedAt,
            LocalizedTextModel title,
            ProjectModelId id,
            ProjectTypes type,
            List<ProjectTagModelId> tagsIds)?
        changelog,
    required TResult orElse(),
  }) {
    if (changelog != null) {
      return changelog(createdAt, updatedAt, title, id, type, tagsIds);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ProjectModelIdea value) idea,
    required TResult Function(ProjectModelNote value) note,
    required TResult Function(ProjectModelChangelog value) changelog,
  }) {
    return changelog(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ProjectModelIdea value)? idea,
    TResult? Function(ProjectModelNote value)? note,
    TResult? Function(ProjectModelChangelog value)? changelog,
  }) {
    return changelog?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ProjectModelIdea value)? idea,
    TResult Function(ProjectModelNote value)? note,
    TResult Function(ProjectModelChangelog value)? changelog,
    required TResult orElse(),
  }) {
    if (changelog != null) {
      return changelog(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ProjectModelChangelogImplToJson(
      this,
    );
  }
}

abstract class ProjectModelChangelog extends ProjectModel implements Sharable {
  const factory ProjectModelChangelog(
      {required final DateTime createdAt,
      required final DateTime updatedAt,
      final LocalizedTextModel title,
      final ProjectModelId id,
      final ProjectTypes type,
      final List<ProjectTagModelId> tagsIds}) = _$ProjectModelChangelogImpl;
  const ProjectModelChangelog._() : super._();

  factory ProjectModelChangelog.fromJson(Map<String, dynamic> json) =
      _$ProjectModelChangelogImpl.fromJson;

  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  LocalizedTextModel get title;
  @override
  ProjectModelId get id;
  @override
  ProjectTypes get type;
  @override
  List<ProjectTagModelId> get tagsIds;
  @override
  @JsonKey(ignore: true)
  _$$ProjectModelChangelogImplCopyWith<_$ProjectModelChangelogImpl>
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

ProjectTagModel _$ProjectTagModelFromJson(Map<String, dynamic> json) {
  return _ProjectTagModel.fromJson(json);
}

/// @nodoc
mixin _$ProjectTagModel {
  ProjectTagModelId get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ProjectTagModelCopyWith<ProjectTagModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProjectTagModelCopyWith<$Res> {
  factory $ProjectTagModelCopyWith(
          ProjectTagModel value, $Res Function(ProjectTagModel) then) =
      _$ProjectTagModelCopyWithImpl<$Res, ProjectTagModel>;
  @useResult
  $Res call({ProjectTagModelId id, String title});
}

/// @nodoc
class _$ProjectTagModelCopyWithImpl<$Res, $Val extends ProjectTagModel>
    implements $ProjectTagModelCopyWith<$Res> {
  _$ProjectTagModelCopyWithImpl(this._value, this._then);

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
              as ProjectTagModelId,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProjectTagModelImplCopyWith<$Res>
    implements $ProjectTagModelCopyWith<$Res> {
  factory _$$ProjectTagModelImplCopyWith(_$ProjectTagModelImpl value,
          $Res Function(_$ProjectTagModelImpl) then) =
      __$$ProjectTagModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({ProjectTagModelId id, String title});
}

/// @nodoc
class __$$ProjectTagModelImplCopyWithImpl<$Res>
    extends _$ProjectTagModelCopyWithImpl<$Res, _$ProjectTagModelImpl>
    implements _$$ProjectTagModelImplCopyWith<$Res> {
  __$$ProjectTagModelImplCopyWithImpl(
      _$ProjectTagModelImpl _value, $Res Function(_$ProjectTagModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
  }) {
    return _then(_$ProjectTagModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as ProjectTagModelId,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProjectTagModelImpl extends _ProjectTagModel {
  const _$ProjectTagModelImpl({required this.id, this.title = ''}) : super._();

  factory _$ProjectTagModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProjectTagModelImplFromJson(json);

  @override
  final ProjectTagModelId id;
  @override
  @JsonKey()
  final String title;

  @override
  String toString() {
    return 'ProjectTagModel(id: $id, title: $title)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProjectTagModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, title);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ProjectTagModelImplCopyWith<_$ProjectTagModelImpl> get copyWith =>
      __$$ProjectTagModelImplCopyWithImpl<_$ProjectTagModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProjectTagModelImplToJson(
      this,
    );
  }
}

abstract class _ProjectTagModel extends ProjectTagModel {
  const factory _ProjectTagModel(
      {required final ProjectTagModelId id,
      final String title}) = _$ProjectTagModelImpl;
  const _ProjectTagModel._() : super._();

  factory _ProjectTagModel.fromJson(Map<String, dynamic> json) =
      _$ProjectTagModelImpl.fromJson;

  @override
  ProjectTagModelId get id;
  @override
  String get title;
  @override
  @JsonKey(ignore: true)
  _$$ProjectTagModelImplCopyWith<_$ProjectTagModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DbSaveModel _$DbSaveModelFromJson(Map<String, dynamic> json) {
  return _DbSaveModel.fromJson(json);
}

/// @nodoc
mixin _$DbSaveModel {
  DbSaveVersion get version => throw _privateConstructorUsedError;
  List<ProjectModel> get projects => throw _privateConstructorUsedError;
  List<ProjectTagModel> get tags => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DbSaveModelCopyWith<DbSaveModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DbSaveModelCopyWith<$Res> {
  factory $DbSaveModelCopyWith(
          DbSaveModel value, $Res Function(DbSaveModel) then) =
      _$DbSaveModelCopyWithImpl<$Res, DbSaveModel>;
  @useResult
  $Res call(
      {DbSaveVersion version,
      List<ProjectModel> projects,
      List<ProjectTagModel> tags});
}

/// @nodoc
class _$DbSaveModelCopyWithImpl<$Res, $Val extends DbSaveModel>
    implements $DbSaveModelCopyWith<$Res> {
  _$DbSaveModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? version = null,
    Object? projects = null,
    Object? tags = null,
  }) {
    return _then(_value.copyWith(
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as DbSaveVersion,
      projects: null == projects
          ? _value.projects
          : projects // ignore: cast_nullable_to_non_nullable
              as List<ProjectModel>,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<ProjectTagModel>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DbSaveModelImplCopyWith<$Res>
    implements $DbSaveModelCopyWith<$Res> {
  factory _$$DbSaveModelImplCopyWith(
          _$DbSaveModelImpl value, $Res Function(_$DbSaveModelImpl) then) =
      __$$DbSaveModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DbSaveVersion version,
      List<ProjectModel> projects,
      List<ProjectTagModel> tags});
}

/// @nodoc
class __$$DbSaveModelImplCopyWithImpl<$Res>
    extends _$DbSaveModelCopyWithImpl<$Res, _$DbSaveModelImpl>
    implements _$$DbSaveModelImplCopyWith<$Res> {
  __$$DbSaveModelImplCopyWithImpl(
      _$DbSaveModelImpl _value, $Res Function(_$DbSaveModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? version = null,
    Object? projects = null,
    Object? tags = null,
  }) {
    return _then(_$DbSaveModelImpl(
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as DbSaveVersion,
      projects: null == projects
          ? _value._projects
          : projects // ignore: cast_nullable_to_non_nullable
              as List<ProjectModel>,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<ProjectTagModel>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DbSaveModelImpl extends _DbSaveModel {
  const _$DbSaveModelImpl(
      {this.version = DbSaveVersion.v1,
      final List<ProjectModel> projects = const [],
      final List<ProjectTagModel> tags = const []})
      : _projects = projects,
        _tags = tags,
        super._();

  factory _$DbSaveModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DbSaveModelImplFromJson(json);

  @override
  @JsonKey()
  final DbSaveVersion version;
  final List<ProjectModel> _projects;
  @override
  @JsonKey()
  List<ProjectModel> get projects {
    if (_projects is EqualUnmodifiableListView) return _projects;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_projects);
  }

  final List<ProjectTagModel> _tags;
  @override
  @JsonKey()
  List<ProjectTagModel> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  String toString() {
    return 'DbSaveModel(version: $version, projects: $projects, tags: $tags)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DbSaveModelImpl &&
            (identical(other.version, version) || other.version == version) &&
            const DeepCollectionEquality().equals(other._projects, _projects) &&
            const DeepCollectionEquality().equals(other._tags, _tags));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      version,
      const DeepCollectionEquality().hash(_projects),
      const DeepCollectionEquality().hash(_tags));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DbSaveModelImplCopyWith<_$DbSaveModelImpl> get copyWith =>
      __$$DbSaveModelImplCopyWithImpl<_$DbSaveModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DbSaveModelImplToJson(
      this,
    );
  }
}

abstract class _DbSaveModel extends DbSaveModel {
  const factory _DbSaveModel(
      {final DbSaveVersion version,
      final List<ProjectModel> projects,
      final List<ProjectTagModel> tags}) = _$DbSaveModelImpl;
  const _DbSaveModel._() : super._();

  factory _DbSaveModel.fromJson(Map<String, dynamic> json) =
      _$DbSaveModelImpl.fromJson;

  @override
  DbSaveVersion get version;
  @override
  List<ProjectModel> get projects;
  @override
  List<ProjectTagModel> get tags;
  @override
  @JsonKey(ignore: true)
  _$$DbSaveModelImplCopyWith<_$DbSaveModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return _UserModel.fromJson(json);
}

/// @nodoc
mixin _$UserModel {
  UserSettingsModel get settings => throw _privateConstructorUsedError;
  LocalDbVersion get localDbVersion => throw _privateConstructorUsedError;
  bool get hasCompletedOnboarding => throw _privateConstructorUsedError;

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
      {UserSettingsModel settings,
      LocalDbVersion localDbVersion,
      bool hasCompletedOnboarding});

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
    Object? hasCompletedOnboarding = null,
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
      hasCompletedOnboarding: null == hasCompletedOnboarding
          ? _value.hasCompletedOnboarding
          : hasCompletedOnboarding // ignore: cast_nullable_to_non_nullable
              as bool,
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
  $Res call(
      {UserSettingsModel settings,
      LocalDbVersion localDbVersion,
      bool hasCompletedOnboarding});

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
    Object? hasCompletedOnboarding = null,
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
      hasCompletedOnboarding: null == hasCompletedOnboarding
          ? _value.hasCompletedOnboarding
          : hasCompletedOnboarding // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserModelImpl implements _UserModel {
  const _$UserModelImpl(
      {this.settings = UserSettingsModel.initial,
      this.localDbVersion = LocalDbVersion.newestVersion,
      this.hasCompletedOnboarding = false});

  factory _$UserModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserModelImplFromJson(json);

  @override
  @JsonKey()
  final UserSettingsModel settings;
  @override
  @JsonKey()
  final LocalDbVersion localDbVersion;
  @override
  @JsonKey()
  final bool hasCompletedOnboarding;

  @override
  String toString() {
    return 'UserModel(settings: $settings, localDbVersion: $localDbVersion, hasCompletedOnboarding: $hasCompletedOnboarding)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserModelImpl &&
            (identical(other.settings, settings) ||
                other.settings == settings) &&
            (identical(other.localDbVersion, localDbVersion) ||
                other.localDbVersion == localDbVersion) &&
            (identical(other.hasCompletedOnboarding, hasCompletedOnboarding) ||
                other.hasCompletedOnboarding == hasCompletedOnboarding));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, settings, localDbVersion, hasCompletedOnboarding);

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
      final LocalDbVersion localDbVersion,
      final bool hasCompletedOnboarding}) = _$UserModelImpl;

  factory _UserModel.fromJson(Map<String, dynamic> json) =
      _$UserModelImpl.fromJson;

  @override
  UserSettingsModel get settings;
  @override
  LocalDbVersion get localDbVersion;
  @override
  bool get hasCompletedOnboarding;
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
  bool get useTimestampForBackupFilename => throw _privateConstructorUsedError;

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
      @JsonKey(fromJson: _localeFromJson, toJson: _localeToJson) Locale? locale,
      bool useTimestampForBackupFilename});
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
    Object? useTimestampForBackupFilename = null,
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
      useTimestampForBackupFilename: null == useTimestampForBackupFilename
          ? _value.useTimestampForBackupFilename
          : useTimestampForBackupFilename // ignore: cast_nullable_to_non_nullable
              as bool,
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
      @JsonKey(fromJson: _localeFromJson, toJson: _localeToJson) Locale? locale,
      bool useTimestampForBackupFilename});
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
    Object? useTimestampForBackupFilename = null,
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
      useTimestampForBackupFilename: null == useTimestampForBackupFilename
          ? _value.useTimestampForBackupFilename
          : useTimestampForBackupFilename // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserSettingsModelImpl implements _UserSettingsModel {
  const _$UserSettingsModelImpl(
      {@JsonKey(fromJson: _themeModeFromJson, toJson: _themeModeToJson)
      this.themeMode = ThemeMode.system,
      this.isProjectsListReversed = true,
      this.charactersLimitForNewNotes = 0,
      @JsonKey(fromJson: _localeFromJson, toJson: _localeToJson) this.locale,
      this.useTimestampForBackupFilename = true});

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
  @JsonKey()
  final bool useTimestampForBackupFilename;

  @override
  String toString() {
    return 'UserSettingsModel(themeMode: $themeMode, isProjectsListReversed: $isProjectsListReversed, charactersLimitForNewNotes: $charactersLimitForNewNotes, locale: $locale, useTimestampForBackupFilename: $useTimestampForBackupFilename)';
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
            (identical(other.locale, locale) || other.locale == locale) &&
            (identical(other.useTimestampForBackupFilename,
                    useTimestampForBackupFilename) ||
                other.useTimestampForBackupFilename ==
                    useTimestampForBackupFilename));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      themeMode,
      isProjectsListReversed,
      charactersLimitForNewNotes,
      locale,
      useTimestampForBackupFilename);

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
      final Locale? locale,
      final bool useTimestampForBackupFilename}) = _$UserSettingsModelImpl;

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
  bool get useTimestampForBackupFilename;
  @override
  @JsonKey(ignore: true)
  _$$UserSettingsModelImplCopyWith<_$UserSettingsModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
