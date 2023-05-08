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

/// @nodoc
mixin _$BlocProvidersModel {
  Create<AuthCubit> get authCubit => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $BlocProvidersModelCopyWith<BlocProvidersModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BlocProvidersModelCopyWith<$Res> {
  factory $BlocProvidersModelCopyWith(
          BlocProvidersModel value, $Res Function(BlocProvidersModel) then) =
      _$BlocProvidersModelCopyWithImpl<$Res, BlocProvidersModel>;
  @useResult
  $Res call({Create<AuthCubit> authCubit});
}

/// @nodoc
class _$BlocProvidersModelCopyWithImpl<$Res, $Val extends BlocProvidersModel>
    implements $BlocProvidersModelCopyWith<$Res> {
  _$BlocProvidersModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? authCubit = null,
  }) {
    return _then(_value.copyWith(
      authCubit: null == authCubit
          ? _value.authCubit
          : authCubit // ignore: cast_nullable_to_non_nullable
              as Create<AuthCubit>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_BlocProvidersModelCopyWith<$Res>
    implements $BlocProvidersModelCopyWith<$Res> {
  factory _$$_BlocProvidersModelCopyWith(_$_BlocProvidersModel value,
          $Res Function(_$_BlocProvidersModel) then) =
      __$$_BlocProvidersModelCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Create<AuthCubit> authCubit});
}

/// @nodoc
class __$$_BlocProvidersModelCopyWithImpl<$Res>
    extends _$BlocProvidersModelCopyWithImpl<$Res, _$_BlocProvidersModel>
    implements _$$_BlocProvidersModelCopyWith<$Res> {
  __$$_BlocProvidersModelCopyWithImpl(
      _$_BlocProvidersModel _value, $Res Function(_$_BlocProvidersModel) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? authCubit = null,
  }) {
    return _then(_$_BlocProvidersModel(
      authCubit: null == authCubit
          ? _value.authCubit
          : authCubit // ignore: cast_nullable_to_non_nullable
              as Create<AuthCubit>,
    ));
  }
}

/// @nodoc

class _$_BlocProvidersModel implements _BlocProvidersModel {
  const _$_BlocProvidersModel({required this.authCubit});

  @override
  final Create<AuthCubit> authCubit;

  @override
  String toString() {
    return 'BlocProvidersModel(authCubit: $authCubit)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_BlocProvidersModel &&
            (identical(other.authCubit, authCubit) ||
                other.authCubit == authCubit));
  }

  @override
  int get hashCode => Object.hash(runtimeType, authCubit);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_BlocProvidersModelCopyWith<_$_BlocProvidersModel> get copyWith =>
      __$$_BlocProvidersModelCopyWithImpl<_$_BlocProvidersModel>(
          this, _$identity);
}

abstract class _BlocProvidersModel implements BlocProvidersModel {
  const factory _BlocProvidersModel(
      {required final Create<AuthCubit> authCubit}) = _$_BlocProvidersModel;

  @override
  Create<AuthCubit> get authCubit;
  @override
  @JsonKey(ignore: true)
  _$$_BlocProvidersModelCopyWith<_$_BlocProvidersModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$RootProvidersModel {
  Create<RepositoriesCollection> get repositories =>
      throw _privateConstructorUsedError;
  Create<AnalyticsService> get analyticsService =>
      throw _privateConstructorUsedError;
  Create<RemoteApiServices> get remoteApiServices =>
      throw _privateConstructorUsedError;
  Create<LocalApiServices> get localApiServices =>
      throw _privateConstructorUsedError;
  Create<UserNotifier> get userNotifier => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $RootProvidersModelCopyWith<RootProvidersModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RootProvidersModelCopyWith<$Res> {
  factory $RootProvidersModelCopyWith(
          RootProvidersModel value, $Res Function(RootProvidersModel) then) =
      _$RootProvidersModelCopyWithImpl<$Res, RootProvidersModel>;
  @useResult
  $Res call(
      {Create<RepositoriesCollection> repositories,
      Create<AnalyticsService> analyticsService,
      Create<RemoteApiServices> remoteApiServices,
      Create<LocalApiServices> localApiServices,
      Create<UserNotifier> userNotifier});
}

/// @nodoc
class _$RootProvidersModelCopyWithImpl<$Res, $Val extends RootProvidersModel>
    implements $RootProvidersModelCopyWith<$Res> {
  _$RootProvidersModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? repositories = null,
    Object? analyticsService = null,
    Object? remoteApiServices = null,
    Object? localApiServices = null,
    Object? userNotifier = null,
  }) {
    return _then(_value.copyWith(
      repositories: null == repositories
          ? _value.repositories
          : repositories // ignore: cast_nullable_to_non_nullable
              as Create<RepositoriesCollection>,
      analyticsService: null == analyticsService
          ? _value.analyticsService
          : analyticsService // ignore: cast_nullable_to_non_nullable
              as Create<AnalyticsService>,
      remoteApiServices: null == remoteApiServices
          ? _value.remoteApiServices
          : remoteApiServices // ignore: cast_nullable_to_non_nullable
              as Create<RemoteApiServices>,
      localApiServices: null == localApiServices
          ? _value.localApiServices
          : localApiServices // ignore: cast_nullable_to_non_nullable
              as Create<LocalApiServices>,
      userNotifier: null == userNotifier
          ? _value.userNotifier
          : userNotifier // ignore: cast_nullable_to_non_nullable
              as Create<UserNotifier>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_RootProvidersModelCopyWith<$Res>
    implements $RootProvidersModelCopyWith<$Res> {
  factory _$$_RootProvidersModelCopyWith(_$_RootProvidersModel value,
          $Res Function(_$_RootProvidersModel) then) =
      __$$_RootProvidersModelCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Create<RepositoriesCollection> repositories,
      Create<AnalyticsService> analyticsService,
      Create<RemoteApiServices> remoteApiServices,
      Create<LocalApiServices> localApiServices,
      Create<UserNotifier> userNotifier});
}

/// @nodoc
class __$$_RootProvidersModelCopyWithImpl<$Res>
    extends _$RootProvidersModelCopyWithImpl<$Res, _$_RootProvidersModel>
    implements _$$_RootProvidersModelCopyWith<$Res> {
  __$$_RootProvidersModelCopyWithImpl(
      _$_RootProvidersModel _value, $Res Function(_$_RootProvidersModel) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? repositories = null,
    Object? analyticsService = null,
    Object? remoteApiServices = null,
    Object? localApiServices = null,
    Object? userNotifier = null,
  }) {
    return _then(_$_RootProvidersModel(
      repositories: null == repositories
          ? _value.repositories
          : repositories // ignore: cast_nullable_to_non_nullable
              as Create<RepositoriesCollection>,
      analyticsService: null == analyticsService
          ? _value.analyticsService
          : analyticsService // ignore: cast_nullable_to_non_nullable
              as Create<AnalyticsService>,
      remoteApiServices: null == remoteApiServices
          ? _value.remoteApiServices
          : remoteApiServices // ignore: cast_nullable_to_non_nullable
              as Create<RemoteApiServices>,
      localApiServices: null == localApiServices
          ? _value.localApiServices
          : localApiServices // ignore: cast_nullable_to_non_nullable
              as Create<LocalApiServices>,
      userNotifier: null == userNotifier
          ? _value.userNotifier
          : userNotifier // ignore: cast_nullable_to_non_nullable
              as Create<UserNotifier>,
    ));
  }
}

/// @nodoc

class _$_RootProvidersModel implements _RootProvidersModel {
  const _$_RootProvidersModel(
      {required this.repositories,
      required this.analyticsService,
      required this.remoteApiServices,
      required this.localApiServices,
      required this.userNotifier});

  @override
  final Create<RepositoriesCollection> repositories;
  @override
  final Create<AnalyticsService> analyticsService;
  @override
  final Create<RemoteApiServices> remoteApiServices;
  @override
  final Create<LocalApiServices> localApiServices;
  @override
  final Create<UserNotifier> userNotifier;

  @override
  String toString() {
    return 'RootProvidersModel(repositories: $repositories, analyticsService: $analyticsService, remoteApiServices: $remoteApiServices, localApiServices: $localApiServices, userNotifier: $userNotifier)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_RootProvidersModel &&
            (identical(other.repositories, repositories) ||
                other.repositories == repositories) &&
            (identical(other.analyticsService, analyticsService) ||
                other.analyticsService == analyticsService) &&
            (identical(other.remoteApiServices, remoteApiServices) ||
                other.remoteApiServices == remoteApiServices) &&
            (identical(other.localApiServices, localApiServices) ||
                other.localApiServices == localApiServices) &&
            (identical(other.userNotifier, userNotifier) ||
                other.userNotifier == userNotifier));
  }

  @override
  int get hashCode => Object.hash(runtimeType, repositories, analyticsService,
      remoteApiServices, localApiServices, userNotifier);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_RootProvidersModelCopyWith<_$_RootProvidersModel> get copyWith =>
      __$$_RootProvidersModelCopyWithImpl<_$_RootProvidersModel>(
          this, _$identity);
}

abstract class _RootProvidersModel implements RootProvidersModel {
  const factory _RootProvidersModel(
          {required final Create<RepositoriesCollection> repositories,
          required final Create<AnalyticsService> analyticsService,
          required final Create<RemoteApiServices> remoteApiServices,
          required final Create<LocalApiServices> localApiServices,
          required final Create<UserNotifier> userNotifier}) =
      _$_RootProvidersModel;

  @override
  Create<RepositoriesCollection> get repositories;
  @override
  Create<AnalyticsService> get analyticsService;
  @override
  Create<RemoteApiServices> get remoteApiServices;
  @override
  Create<LocalApiServices> get localApiServices;
  @override
  Create<UserNotifier> get userNotifier;
  @override
  @JsonKey(ignore: true)
  _$$_RootProvidersModelCopyWith<_$_RootProvidersModel> get copyWith =>
      throw _privateConstructorUsedError;
}
