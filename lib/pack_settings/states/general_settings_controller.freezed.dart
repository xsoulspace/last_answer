// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'general_settings_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$GeneralSettingsControllerState {
  ThemeMode get themeMode => throw _privateConstructorUsedError;
  bool get isProjectsListReversed => throw _privateConstructorUsedError;
  int get charactersLimitForNewNotes => throw _privateConstructorUsedError;
  Locale? get locale =>
      throw _privateConstructorUsedError; // TODO(arenukvern): move to independent notifier,
  AppStateLoadingStatuses? get loadingStatus =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $GeneralSettingsControllerStateCopyWith<GeneralSettingsControllerState>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GeneralSettingsControllerStateCopyWith<$Res> {
  factory $GeneralSettingsControllerStateCopyWith(
          GeneralSettingsControllerState value,
          $Res Function(GeneralSettingsControllerState) then) =
      _$GeneralSettingsControllerStateCopyWithImpl<$Res,
          GeneralSettingsControllerState>;
  @useResult
  $Res call(
      {ThemeMode themeMode,
      bool isProjectsListReversed,
      int charactersLimitForNewNotes,
      Locale? locale,
      AppStateLoadingStatuses? loadingStatus});
}

/// @nodoc
class _$GeneralSettingsControllerStateCopyWithImpl<$Res,
        $Val extends GeneralSettingsControllerState>
    implements $GeneralSettingsControllerStateCopyWith<$Res> {
  _$GeneralSettingsControllerStateCopyWithImpl(this._value, this._then);

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
    Object? loadingStatus = freezed,
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
      loadingStatus: freezed == loadingStatus
          ? _value.loadingStatus
          : loadingStatus // ignore: cast_nullable_to_non_nullable
              as AppStateLoadingStatuses?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GeneralSettingsControllerStateImplCopyWith<$Res>
    implements $GeneralSettingsControllerStateCopyWith<$Res> {
  factory _$$GeneralSettingsControllerStateImplCopyWith(
          _$GeneralSettingsControllerStateImpl value,
          $Res Function(_$GeneralSettingsControllerStateImpl) then) =
      __$$GeneralSettingsControllerStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {ThemeMode themeMode,
      bool isProjectsListReversed,
      int charactersLimitForNewNotes,
      Locale? locale,
      AppStateLoadingStatuses? loadingStatus});
}

/// @nodoc
class __$$GeneralSettingsControllerStateImplCopyWithImpl<$Res>
    extends _$GeneralSettingsControllerStateCopyWithImpl<$Res,
        _$GeneralSettingsControllerStateImpl>
    implements _$$GeneralSettingsControllerStateImplCopyWith<$Res> {
  __$$GeneralSettingsControllerStateImplCopyWithImpl(
      _$GeneralSettingsControllerStateImpl _value,
      $Res Function(_$GeneralSettingsControllerStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? themeMode = null,
    Object? isProjectsListReversed = null,
    Object? charactersLimitForNewNotes = null,
    Object? locale = freezed,
    Object? loadingStatus = freezed,
  }) {
    return _then(_$GeneralSettingsControllerStateImpl(
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
      loadingStatus: freezed == loadingStatus
          ? _value.loadingStatus
          : loadingStatus // ignore: cast_nullable_to_non_nullable
              as AppStateLoadingStatuses?,
    ));
  }
}

/// @nodoc

class _$GeneralSettingsControllerStateImpl
    implements _GeneralSettingsControllerState {
  const _$GeneralSettingsControllerStateImpl(
      {this.themeMode = ThemeMode.system,
      this.isProjectsListReversed = false,
      this.charactersLimitForNewNotes = 0,
      this.locale,
      this.loadingStatus});

  @override
  @JsonKey()
  final ThemeMode themeMode;
  @override
  @JsonKey()
  final bool isProjectsListReversed;
  @override
  @JsonKey()
  final int charactersLimitForNewNotes;
  @override
  final Locale? locale;
// TODO(arenukvern): move to independent notifier,
  @override
  final AppStateLoadingStatuses? loadingStatus;

  @override
  String toString() {
    return 'GeneralSettingsControllerState(themeMode: $themeMode, isProjectsListReversed: $isProjectsListReversed, charactersLimitForNewNotes: $charactersLimitForNewNotes, locale: $locale, loadingStatus: $loadingStatus)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GeneralSettingsControllerStateImpl &&
            (identical(other.themeMode, themeMode) ||
                other.themeMode == themeMode) &&
            (identical(other.isProjectsListReversed, isProjectsListReversed) ||
                other.isProjectsListReversed == isProjectsListReversed) &&
            (identical(other.charactersLimitForNewNotes,
                    charactersLimitForNewNotes) ||
                other.charactersLimitForNewNotes ==
                    charactersLimitForNewNotes) &&
            (identical(other.locale, locale) || other.locale == locale) &&
            (identical(other.loadingStatus, loadingStatus) ||
                other.loadingStatus == loadingStatus));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      themeMode,
      isProjectsListReversed,
      charactersLimitForNewNotes,
      locale,
      loadingStatus);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GeneralSettingsControllerStateImplCopyWith<
          _$GeneralSettingsControllerStateImpl>
      get copyWith => __$$GeneralSettingsControllerStateImplCopyWithImpl<
          _$GeneralSettingsControllerStateImpl>(this, _$identity);
}

abstract class _GeneralSettingsControllerState
    implements GeneralSettingsControllerState {
  const factory _GeneralSettingsControllerState(
          {final ThemeMode themeMode,
          final bool isProjectsListReversed,
          final int charactersLimitForNewNotes,
          final Locale? locale,
          final AppStateLoadingStatuses? loadingStatus}) =
      _$GeneralSettingsControllerStateImpl;

  @override
  ThemeMode get themeMode;
  @override
  bool get isProjectsListReversed;
  @override
  int get charactersLimitForNewNotes;
  @override
  Locale? get locale;
  @override // TODO(arenukvern): move to independent notifier,
  AppStateLoadingStatuses? get loadingStatus;
  @override
  @JsonKey(ignore: true)
  _$$GeneralSettingsControllerStateImplCopyWith<
          _$GeneralSettingsControllerStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
