// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$AppFeaturesModel {
  bool get isRemoteServicesEnabled => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $AppFeaturesModelCopyWith<AppFeaturesModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppFeaturesModelCopyWith<$Res> {
  factory $AppFeaturesModelCopyWith(
          AppFeaturesModel value, $Res Function(AppFeaturesModel) then) =
      _$AppFeaturesModelCopyWithImpl<$Res, AppFeaturesModel>;
  @useResult
  $Res call({bool isRemoteServicesEnabled});
}

/// @nodoc
class _$AppFeaturesModelCopyWithImpl<$Res, $Val extends AppFeaturesModel>
    implements $AppFeaturesModelCopyWith<$Res> {
  _$AppFeaturesModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isRemoteServicesEnabled = null,
  }) {
    return _then(_value.copyWith(
      isRemoteServicesEnabled: null == isRemoteServicesEnabled
          ? _value.isRemoteServicesEnabled
          : isRemoteServicesEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AppFeaturesModelImplCopyWith<$Res>
    implements $AppFeaturesModelCopyWith<$Res> {
  factory _$$AppFeaturesModelImplCopyWith(_$AppFeaturesModelImpl value,
          $Res Function(_$AppFeaturesModelImpl) then) =
      __$$AppFeaturesModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool isRemoteServicesEnabled});
}

/// @nodoc
class __$$AppFeaturesModelImplCopyWithImpl<$Res>
    extends _$AppFeaturesModelCopyWithImpl<$Res, _$AppFeaturesModelImpl>
    implements _$$AppFeaturesModelImplCopyWith<$Res> {
  __$$AppFeaturesModelImplCopyWithImpl(_$AppFeaturesModelImpl _value,
      $Res Function(_$AppFeaturesModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isRemoteServicesEnabled = null,
  }) {
    return _then(_$AppFeaturesModelImpl(
      isRemoteServicesEnabled: null == isRemoteServicesEnabled
          ? _value.isRemoteServicesEnabled
          : isRemoteServicesEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$AppFeaturesModelImpl
    with DiagnosticableTreeMixin
    implements _AppFeaturesModel {
  const _$AppFeaturesModelImpl({this.isRemoteServicesEnabled = false});

  @override
  @JsonKey()
  final bool isRemoteServicesEnabled;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'AppFeaturesModel(isRemoteServicesEnabled: $isRemoteServicesEnabled)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'AppFeaturesModel'))
      ..add(DiagnosticsProperty(
          'isRemoteServicesEnabled', isRemoteServicesEnabled));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppFeaturesModelImpl &&
            (identical(
                    other.isRemoteServicesEnabled, isRemoteServicesEnabled) ||
                other.isRemoteServicesEnabled == isRemoteServicesEnabled));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isRemoteServicesEnabled);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AppFeaturesModelImplCopyWith<_$AppFeaturesModelImpl> get copyWith =>
      __$$AppFeaturesModelImplCopyWithImpl<_$AppFeaturesModelImpl>(
          this, _$identity);
}

abstract class _AppFeaturesModel implements AppFeaturesModel {
  const factory _AppFeaturesModel({final bool isRemoteServicesEnabled}) =
      _$AppFeaturesModelImpl;

  @override
  bool get isRemoteServicesEnabled;
  @override
  @JsonKey(ignore: true)
  _$$AppFeaturesModelImplCopyWith<_$AppFeaturesModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AppNotifierState {
  AppStatus get status => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $AppNotifierStateCopyWith<AppNotifierState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppNotifierStateCopyWith<$Res> {
  factory $AppNotifierStateCopyWith(
          AppNotifierState value, $Res Function(AppNotifierState) then) =
      _$AppNotifierStateCopyWithImpl<$Res, AppNotifierState>;
  @useResult
  $Res call({AppStatus status});
}

/// @nodoc
class _$AppNotifierStateCopyWithImpl<$Res, $Val extends AppNotifierState>
    implements $AppNotifierStateCopyWith<$Res> {
  _$AppNotifierStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
  }) {
    return _then(_value.copyWith(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as AppStatus,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AppNotifierStateImplCopyWith<$Res>
    implements $AppNotifierStateCopyWith<$Res> {
  factory _$$AppNotifierStateImplCopyWith(_$AppNotifierStateImpl value,
          $Res Function(_$AppNotifierStateImpl) then) =
      __$$AppNotifierStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({AppStatus status});
}

/// @nodoc
class __$$AppNotifierStateImplCopyWithImpl<$Res>
    extends _$AppNotifierStateCopyWithImpl<$Res, _$AppNotifierStateImpl>
    implements _$$AppNotifierStateImplCopyWith<$Res> {
  __$$AppNotifierStateImplCopyWithImpl(_$AppNotifierStateImpl _value,
      $Res Function(_$AppNotifierStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
  }) {
    return _then(_$AppNotifierStateImpl(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as AppStatus,
    ));
  }
}

/// @nodoc

class _$AppNotifierStateImpl
    with DiagnosticableTreeMixin
    implements _AppNotifierState {
  const _$AppNotifierStateImpl({this.status = AppStatus.loading});

  @override
  @JsonKey()
  final AppStatus status;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'AppNotifierState(status: $status)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'AppNotifierState'))
      ..add(DiagnosticsProperty('status', status));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppNotifierStateImpl &&
            (identical(other.status, status) || other.status == status));
  }

  @override
  int get hashCode => Object.hash(runtimeType, status);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AppNotifierStateImplCopyWith<_$AppNotifierStateImpl> get copyWith =>
      __$$AppNotifierStateImplCopyWithImpl<_$AppNotifierStateImpl>(
          this, _$identity);
}

abstract class _AppNotifierState implements AppNotifierState {
  const factory _AppNotifierState({final AppStatus status}) =
      _$AppNotifierStateImpl;

  @override
  AppStatus get status;
  @override
  @JsonKey(ignore: true)
  _$$AppNotifierStateImplCopyWith<_$AppNotifierStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$NotificationsNotifierState {
  /// Should be ordered from newest to oldest and never be
  List<NotificationMessageModel> get updates =>
      throw _privateConstructorUsedError;
  bool get hasUnreadUpdates => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $NotificationsNotifierStateCopyWith<NotificationsNotifierState>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationsNotifierStateCopyWith<$Res> {
  factory $NotificationsNotifierStateCopyWith(NotificationsNotifierState value,
          $Res Function(NotificationsNotifierState) then) =
      _$NotificationsNotifierStateCopyWithImpl<$Res,
          NotificationsNotifierState>;
  @useResult
  $Res call({List<NotificationMessageModel> updates, bool hasUnreadUpdates});
}

/// @nodoc
class _$NotificationsNotifierStateCopyWithImpl<$Res,
        $Val extends NotificationsNotifierState>
    implements $NotificationsNotifierStateCopyWith<$Res> {
  _$NotificationsNotifierStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? updates = null,
    Object? hasUnreadUpdates = null,
  }) {
    return _then(_value.copyWith(
      updates: null == updates
          ? _value.updates
          : updates // ignore: cast_nullable_to_non_nullable
              as List<NotificationMessageModel>,
      hasUnreadUpdates: null == hasUnreadUpdates
          ? _value.hasUnreadUpdates
          : hasUnreadUpdates // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationsNotifierStateImplCopyWith<$Res>
    implements $NotificationsNotifierStateCopyWith<$Res> {
  factory _$$NotificationsNotifierStateImplCopyWith(
          _$NotificationsNotifierStateImpl value,
          $Res Function(_$NotificationsNotifierStateImpl) then) =
      __$$NotificationsNotifierStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<NotificationMessageModel> updates, bool hasUnreadUpdates});
}

/// @nodoc
class __$$NotificationsNotifierStateImplCopyWithImpl<$Res>
    extends _$NotificationsNotifierStateCopyWithImpl<$Res,
        _$NotificationsNotifierStateImpl>
    implements _$$NotificationsNotifierStateImplCopyWith<$Res> {
  __$$NotificationsNotifierStateImplCopyWithImpl(
      _$NotificationsNotifierStateImpl _value,
      $Res Function(_$NotificationsNotifierStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? updates = null,
    Object? hasUnreadUpdates = null,
  }) {
    return _then(_$NotificationsNotifierStateImpl(
      updates: null == updates
          ? _value._updates
          : updates // ignore: cast_nullable_to_non_nullable
              as List<NotificationMessageModel>,
      hasUnreadUpdates: null == hasUnreadUpdates
          ? _value.hasUnreadUpdates
          : hasUnreadUpdates // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$NotificationsNotifierStateImpl
    with DiagnosticableTreeMixin
    implements _NotificationsNotifierState {
  const _$NotificationsNotifierStateImpl(
      {final List<NotificationMessageModel> updates = const [],
      this.hasUnreadUpdates = false})
      : _updates = updates;

  /// Should be ordered from newest to oldest and never be
  final List<NotificationMessageModel> _updates;

  /// Should be ordered from newest to oldest and never be
  @override
  @JsonKey()
  List<NotificationMessageModel> get updates {
    if (_updates is EqualUnmodifiableListView) return _updates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_updates);
  }

  @override
  @JsonKey()
  final bool hasUnreadUpdates;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'NotificationsNotifierState(updates: $updates, hasUnreadUpdates: $hasUnreadUpdates)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'NotificationsNotifierState'))
      ..add(DiagnosticsProperty('updates', updates))
      ..add(DiagnosticsProperty('hasUnreadUpdates', hasUnreadUpdates));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationsNotifierStateImpl &&
            const DeepCollectionEquality().equals(other._updates, _updates) &&
            (identical(other.hasUnreadUpdates, hasUnreadUpdates) ||
                other.hasUnreadUpdates == hasUnreadUpdates));
  }

  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_updates), hasUnreadUpdates);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationsNotifierStateImplCopyWith<_$NotificationsNotifierStateImpl>
      get copyWith => __$$NotificationsNotifierStateImplCopyWithImpl<
          _$NotificationsNotifierStateImpl>(this, _$identity);
}

abstract class _NotificationsNotifierState
    implements NotificationsNotifierState {
  const factory _NotificationsNotifierState(
      {final List<NotificationMessageModel> updates,
      final bool hasUnreadUpdates}) = _$NotificationsNotifierStateImpl;

  @override

  /// Should be ordered from newest to oldest and never be
  List<NotificationMessageModel> get updates;
  @override
  bool get hasUnreadUpdates;
  @override
  @JsonKey(ignore: true)
  _$$NotificationsNotifierStateImplCopyWith<_$NotificationsNotifierStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ProjectsNotifierState {
  RequestProjectsDto get requestProjectsDto =>
      throw _privateConstructorUsedError;
  bool get isAllProjectsFileLoading => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ProjectsNotifierStateCopyWith<ProjectsNotifierState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProjectsNotifierStateCopyWith<$Res> {
  factory $ProjectsNotifierStateCopyWith(ProjectsNotifierState value,
          $Res Function(ProjectsNotifierState) then) =
      _$ProjectsNotifierStateCopyWithImpl<$Res, ProjectsNotifierState>;
  @useResult
  $Res call(
      {RequestProjectsDto requestProjectsDto, bool isAllProjectsFileLoading});

  $RequestProjectsDtoCopyWith<$Res> get requestProjectsDto;
}

/// @nodoc
class _$ProjectsNotifierStateCopyWithImpl<$Res,
        $Val extends ProjectsNotifierState>
    implements $ProjectsNotifierStateCopyWith<$Res> {
  _$ProjectsNotifierStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? requestProjectsDto = null,
    Object? isAllProjectsFileLoading = null,
  }) {
    return _then(_value.copyWith(
      requestProjectsDto: null == requestProjectsDto
          ? _value.requestProjectsDto
          : requestProjectsDto // ignore: cast_nullable_to_non_nullable
              as RequestProjectsDto,
      isAllProjectsFileLoading: null == isAllProjectsFileLoading
          ? _value.isAllProjectsFileLoading
          : isAllProjectsFileLoading // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $RequestProjectsDtoCopyWith<$Res> get requestProjectsDto {
    return $RequestProjectsDtoCopyWith<$Res>(_value.requestProjectsDto,
        (value) {
      return _then(_value.copyWith(requestProjectsDto: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ProjectsNotifierStateImplCopyWith<$Res>
    implements $ProjectsNotifierStateCopyWith<$Res> {
  factory _$$ProjectsNotifierStateImplCopyWith(
          _$ProjectsNotifierStateImpl value,
          $Res Function(_$ProjectsNotifierStateImpl) then) =
      __$$ProjectsNotifierStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {RequestProjectsDto requestProjectsDto, bool isAllProjectsFileLoading});

  @override
  $RequestProjectsDtoCopyWith<$Res> get requestProjectsDto;
}

/// @nodoc
class __$$ProjectsNotifierStateImplCopyWithImpl<$Res>
    extends _$ProjectsNotifierStateCopyWithImpl<$Res,
        _$ProjectsNotifierStateImpl>
    implements _$$ProjectsNotifierStateImplCopyWith<$Res> {
  __$$ProjectsNotifierStateImplCopyWithImpl(_$ProjectsNotifierStateImpl _value,
      $Res Function(_$ProjectsNotifierStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? requestProjectsDto = null,
    Object? isAllProjectsFileLoading = null,
  }) {
    return _then(_$ProjectsNotifierStateImpl(
      requestProjectsDto: null == requestProjectsDto
          ? _value.requestProjectsDto
          : requestProjectsDto // ignore: cast_nullable_to_non_nullable
              as RequestProjectsDto,
      isAllProjectsFileLoading: null == isAllProjectsFileLoading
          ? _value.isAllProjectsFileLoading
          : isAllProjectsFileLoading // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$ProjectsNotifierStateImpl
    with DiagnosticableTreeMixin
    implements _ProjectsNotifierState {
  const _$ProjectsNotifierStateImpl(
      {this.requestProjectsDto = RequestProjectsDto.empty,
      this.isAllProjectsFileLoading = false});

  @override
  @JsonKey()
  final RequestProjectsDto requestProjectsDto;
  @override
  @JsonKey()
  final bool isAllProjectsFileLoading;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ProjectsNotifierState(requestProjectsDto: $requestProjectsDto, isAllProjectsFileLoading: $isAllProjectsFileLoading)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ProjectsNotifierState'))
      ..add(DiagnosticsProperty('requestProjectsDto', requestProjectsDto))
      ..add(DiagnosticsProperty(
          'isAllProjectsFileLoading', isAllProjectsFileLoading));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProjectsNotifierStateImpl &&
            (identical(other.requestProjectsDto, requestProjectsDto) ||
                other.requestProjectsDto == requestProjectsDto) &&
            (identical(
                    other.isAllProjectsFileLoading, isAllProjectsFileLoading) ||
                other.isAllProjectsFileLoading == isAllProjectsFileLoading));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, requestProjectsDto, isAllProjectsFileLoading);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ProjectsNotifierStateImplCopyWith<_$ProjectsNotifierStateImpl>
      get copyWith => __$$ProjectsNotifierStateImplCopyWithImpl<
          _$ProjectsNotifierStateImpl>(this, _$identity);
}

abstract class _ProjectsNotifierState implements ProjectsNotifierState {
  const factory _ProjectsNotifierState(
      {final RequestProjectsDto requestProjectsDto,
      final bool isAllProjectsFileLoading}) = _$ProjectsNotifierStateImpl;

  @override
  RequestProjectsDto get requestProjectsDto;
  @override
  bool get isAllProjectsFileLoading;
  @override
  @JsonKey(ignore: true)
  _$$ProjectsNotifierStateImplCopyWith<_$ProjectsNotifierStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$RequestProjectsDto {
  String get search => throw _privateConstructorUsedError;
  List<ProjectTypes> get types => throw _privateConstructorUsedError;
  bool get isReversed => throw _privateConstructorUsedError;
  ProjectTagModelId get tagId => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $RequestProjectsDtoCopyWith<RequestProjectsDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RequestProjectsDtoCopyWith<$Res> {
  factory $RequestProjectsDtoCopyWith(
          RequestProjectsDto value, $Res Function(RequestProjectsDto) then) =
      _$RequestProjectsDtoCopyWithImpl<$Res, RequestProjectsDto>;
  @useResult
  $Res call(
      {String search,
      List<ProjectTypes> types,
      bool isReversed,
      ProjectTagModelId tagId});
}

/// @nodoc
class _$RequestProjectsDtoCopyWithImpl<$Res, $Val extends RequestProjectsDto>
    implements $RequestProjectsDtoCopyWith<$Res> {
  _$RequestProjectsDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? search = null,
    Object? types = null,
    Object? isReversed = null,
    Object? tagId = null,
  }) {
    return _then(_value.copyWith(
      search: null == search
          ? _value.search
          : search // ignore: cast_nullable_to_non_nullable
              as String,
      types: null == types
          ? _value.types
          : types // ignore: cast_nullable_to_non_nullable
              as List<ProjectTypes>,
      isReversed: null == isReversed
          ? _value.isReversed
          : isReversed // ignore: cast_nullable_to_non_nullable
              as bool,
      tagId: null == tagId
          ? _value.tagId
          : tagId // ignore: cast_nullable_to_non_nullable
              as ProjectTagModelId,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RequestProjectsDtoImplCopyWith<$Res>
    implements $RequestProjectsDtoCopyWith<$Res> {
  factory _$$RequestProjectsDtoImplCopyWith(_$RequestProjectsDtoImpl value,
          $Res Function(_$RequestProjectsDtoImpl) then) =
      __$$RequestProjectsDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String search,
      List<ProjectTypes> types,
      bool isReversed,
      ProjectTagModelId tagId});
}

/// @nodoc
class __$$RequestProjectsDtoImplCopyWithImpl<$Res>
    extends _$RequestProjectsDtoCopyWithImpl<$Res, _$RequestProjectsDtoImpl>
    implements _$$RequestProjectsDtoImplCopyWith<$Res> {
  __$$RequestProjectsDtoImplCopyWithImpl(_$RequestProjectsDtoImpl _value,
      $Res Function(_$RequestProjectsDtoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? search = null,
    Object? types = null,
    Object? isReversed = null,
    Object? tagId = null,
  }) {
    return _then(_$RequestProjectsDtoImpl(
      search: null == search
          ? _value.search
          : search // ignore: cast_nullable_to_non_nullable
              as String,
      types: null == types
          ? _value._types
          : types // ignore: cast_nullable_to_non_nullable
              as List<ProjectTypes>,
      isReversed: null == isReversed
          ? _value.isReversed
          : isReversed // ignore: cast_nullable_to_non_nullable
              as bool,
      tagId: null == tagId
          ? _value.tagId
          : tagId // ignore: cast_nullable_to_non_nullable
              as ProjectTagModelId,
    ));
  }
}

/// @nodoc

class _$RequestProjectsDtoImpl extends _RequestProjectsDto
    with DiagnosticableTreeMixin {
  const _$RequestProjectsDtoImpl(
      {this.search = '',
      final List<ProjectTypes> types = const [],
      this.isReversed = false,
      this.tagId = ProjectTagModelId.empty})
      : _types = types,
        super._();

  @override
  @JsonKey()
  final String search;
  final List<ProjectTypes> _types;
  @override
  @JsonKey()
  List<ProjectTypes> get types {
    if (_types is EqualUnmodifiableListView) return _types;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_types);
  }

  @override
  @JsonKey()
  final bool isReversed;
  @override
  @JsonKey()
  final ProjectTagModelId tagId;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'RequestProjectsDto(search: $search, types: $types, isReversed: $isReversed, tagId: $tagId)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'RequestProjectsDto'))
      ..add(DiagnosticsProperty('search', search))
      ..add(DiagnosticsProperty('types', types))
      ..add(DiagnosticsProperty('isReversed', isReversed))
      ..add(DiagnosticsProperty('tagId', tagId));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RequestProjectsDtoImpl &&
            (identical(other.search, search) || other.search == search) &&
            const DeepCollectionEquality().equals(other._types, _types) &&
            (identical(other.isReversed, isReversed) ||
                other.isReversed == isReversed) &&
            (identical(other.tagId, tagId) || other.tagId == tagId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, search,
      const DeepCollectionEquality().hash(_types), isReversed, tagId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RequestProjectsDtoImplCopyWith<_$RequestProjectsDtoImpl> get copyWith =>
      __$$RequestProjectsDtoImplCopyWithImpl<_$RequestProjectsDtoImpl>(
          this, _$identity);
}

abstract class _RequestProjectsDto extends RequestProjectsDto {
  const factory _RequestProjectsDto(
      {final String search,
      final List<ProjectTypes> types,
      final bool isReversed,
      final ProjectTagModelId tagId}) = _$RequestProjectsDtoImpl;
  const _RequestProjectsDto._() : super._();

  @override
  String get search;
  @override
  List<ProjectTypes> get types;
  @override
  bool get isReversed;
  @override
  ProjectTagModelId get tagId;
  @override
  @JsonKey(ignore: true)
  _$$RequestProjectsDtoImplCopyWith<_$RequestProjectsDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
