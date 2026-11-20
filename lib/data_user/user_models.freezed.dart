// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserModel implements DiagnosticableTreeMixin {

 UserSettingsModel get settings; LocalDbVersion get localDbVersion; bool get hasCompletedOnboarding;
/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserModelCopyWith<UserModel> get copyWith => _$UserModelCopyWithImpl<UserModel>(this as UserModel, _$identity);

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'UserModel'))
    ..add(DiagnosticsProperty('settings', settings))..add(DiagnosticsProperty('localDbVersion', localDbVersion))..add(DiagnosticsProperty('hasCompletedOnboarding', hasCompletedOnboarding));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserModel&&(identical(other.settings, settings) || other.settings == settings)&&(identical(other.localDbVersion, localDbVersion) || other.localDbVersion == localDbVersion)&&(identical(other.hasCompletedOnboarding, hasCompletedOnboarding) || other.hasCompletedOnboarding == hasCompletedOnboarding));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,settings,localDbVersion,hasCompletedOnboarding);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'UserModel(settings: $settings, localDbVersion: $localDbVersion, hasCompletedOnboarding: $hasCompletedOnboarding)';
}


}

/// @nodoc
abstract mixin class $UserModelCopyWith<$Res>  {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) _then) = _$UserModelCopyWithImpl;
@useResult
$Res call({
 UserSettingsModel settings, LocalDbVersion localDbVersion, bool hasCompletedOnboarding
});


$UserSettingsModelCopyWith<$Res> get settings;

}
/// @nodoc
class _$UserModelCopyWithImpl<$Res>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._self, this._then);

  final UserModel _self;
  final $Res Function(UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? settings = null,Object? localDbVersion = null,Object? hasCompletedOnboarding = null,}) {
  return _then(UserModel(
settings: null == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as UserSettingsModel,localDbVersion: null == localDbVersion ? _self.localDbVersion : localDbVersion // ignore: cast_nullable_to_non_nullable
as LocalDbVersion,hasCompletedOnboarding: null == hasCompletedOnboarding ? _self.hasCompletedOnboarding : hasCompletedOnboarding // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserSettingsModelCopyWith<$Res> get settings {
  
  return $UserSettingsModelCopyWith<$Res>(_self.settings, (value) {
    return _then(_self.copyWith(settings: value));
  });
}
}


/// Adds pattern-matching-related methods to [UserModel].
extension UserModelPatterns on UserModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserModel value)  $default,){
final _that = this;
switch (_that) {
case _UserModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserModel value)?  $default,){
final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( UserSettingsModel settings,  LocalDbVersion localDbVersion,  bool hasCompletedOnboarding)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that.settings,_that.localDbVersion,_that.hasCompletedOnboarding);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( UserSettingsModel settings,  LocalDbVersion localDbVersion,  bool hasCompletedOnboarding)  $default,) {final _that = this;
switch (_that) {
case _UserModel():
return $default(_that.settings,_that.localDbVersion,_that.hasCompletedOnboarding);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( UserSettingsModel settings,  LocalDbVersion localDbVersion,  bool hasCompletedOnboarding)?  $default,) {final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that.settings,_that.localDbVersion,_that.hasCompletedOnboarding);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserModel with DiagnosticableTreeMixin implements UserModel {
  const _UserModel({this.settings = UserSettingsModel.initial, this.localDbVersion = LocalDbVersion.newestVersion, this.hasCompletedOnboarding = false});
  factory _UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

@override@JsonKey() final  UserSettingsModel settings;
@override@JsonKey() final  LocalDbVersion localDbVersion;
@override@JsonKey() final  bool hasCompletedOnboarding;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserModelCopyWith<_UserModel> get copyWith => __$UserModelCopyWithImpl<_UserModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserModelToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'UserModel'))
    ..add(DiagnosticsProperty('settings', settings))..add(DiagnosticsProperty('localDbVersion', localDbVersion))..add(DiagnosticsProperty('hasCompletedOnboarding', hasCompletedOnboarding));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserModel&&(identical(other.settings, settings) || other.settings == settings)&&(identical(other.localDbVersion, localDbVersion) || other.localDbVersion == localDbVersion)&&(identical(other.hasCompletedOnboarding, hasCompletedOnboarding) || other.hasCompletedOnboarding == hasCompletedOnboarding));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,settings,localDbVersion,hasCompletedOnboarding);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'UserModel(settings: $settings, localDbVersion: $localDbVersion, hasCompletedOnboarding: $hasCompletedOnboarding)';
}


}

/// @nodoc
abstract mixin class _$UserModelCopyWith<$Res> implements $UserModelCopyWith<$Res> {
  factory _$UserModelCopyWith(_UserModel value, $Res Function(_UserModel) _then) = __$UserModelCopyWithImpl;
@override @useResult
$Res call({
 UserSettingsModel settings, LocalDbVersion localDbVersion, bool hasCompletedOnboarding
});


@override $UserSettingsModelCopyWith<$Res> get settings;

}
/// @nodoc
class __$UserModelCopyWithImpl<$Res>
    implements _$UserModelCopyWith<$Res> {
  __$UserModelCopyWithImpl(this._self, this._then);

  final _UserModel _self;
  final $Res Function(_UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? settings = null,Object? localDbVersion = null,Object? hasCompletedOnboarding = null,}) {
  return _then(_UserModel(
settings: null == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as UserSettingsModel,localDbVersion: null == localDbVersion ? _self.localDbVersion : localDbVersion // ignore: cast_nullable_to_non_nullable
as LocalDbVersion,hasCompletedOnboarding: null == hasCompletedOnboarding ? _self.hasCompletedOnboarding : hasCompletedOnboarding // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserSettingsModelCopyWith<$Res> get settings {
  
  return $UserSettingsModelCopyWith<$Res>(_self.settings, (value) {
    return _then(_self.copyWith(settings: value));
  });
}
}


/// @nodoc
mixin _$UserSettingsModel implements DiagnosticableTreeMixin {

@JsonKey(fromJson: _themeModeFromJson, toJson: _themeModeToJson) ThemeMode get themeMode; bool get isProjectsListReversed; int get charactersLimitForNewNotes;@JsonKey(fromJson: _localeFromJson, toJson: _localeToJson) Locale? get locale; bool get useTimestampForBackupFilename; bool get isSocialNetworksRestricted;
/// Create a copy of UserSettingsModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserSettingsModelCopyWith<UserSettingsModel> get copyWith => _$UserSettingsModelCopyWithImpl<UserSettingsModel>(this as UserSettingsModel, _$identity);

  /// Serializes this UserSettingsModel to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'UserSettingsModel'))
    ..add(DiagnosticsProperty('themeMode', themeMode))..add(DiagnosticsProperty('isProjectsListReversed', isProjectsListReversed))..add(DiagnosticsProperty('charactersLimitForNewNotes', charactersLimitForNewNotes))..add(DiagnosticsProperty('locale', locale))..add(DiagnosticsProperty('useTimestampForBackupFilename', useTimestampForBackupFilename))..add(DiagnosticsProperty('isSocialNetworksRestricted', isSocialNetworksRestricted));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserSettingsModel&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.isProjectsListReversed, isProjectsListReversed) || other.isProjectsListReversed == isProjectsListReversed)&&(identical(other.charactersLimitForNewNotes, charactersLimitForNewNotes) || other.charactersLimitForNewNotes == charactersLimitForNewNotes)&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.useTimestampForBackupFilename, useTimestampForBackupFilename) || other.useTimestampForBackupFilename == useTimestampForBackupFilename)&&(identical(other.isSocialNetworksRestricted, isSocialNetworksRestricted) || other.isSocialNetworksRestricted == isSocialNetworksRestricted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,themeMode,isProjectsListReversed,charactersLimitForNewNotes,locale,useTimestampForBackupFilename,isSocialNetworksRestricted);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'UserSettingsModel(themeMode: $themeMode, isProjectsListReversed: $isProjectsListReversed, charactersLimitForNewNotes: $charactersLimitForNewNotes, locale: $locale, useTimestampForBackupFilename: $useTimestampForBackupFilename, isSocialNetworksRestricted: $isSocialNetworksRestricted)';
}


}

/// @nodoc
abstract mixin class $UserSettingsModelCopyWith<$Res>  {
  factory $UserSettingsModelCopyWith(UserSettingsModel value, $Res Function(UserSettingsModel) _then) = _$UserSettingsModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: _themeModeFromJson, toJson: _themeModeToJson) ThemeMode themeMode, bool isProjectsListReversed, int charactersLimitForNewNotes,@JsonKey(fromJson: _localeFromJson, toJson: _localeToJson) Locale? locale, bool useTimestampForBackupFilename, bool isSocialNetworksRestricted
});




}
/// @nodoc
class _$UserSettingsModelCopyWithImpl<$Res>
    implements $UserSettingsModelCopyWith<$Res> {
  _$UserSettingsModelCopyWithImpl(this._self, this._then);

  final UserSettingsModel _self;
  final $Res Function(UserSettingsModel) _then;

/// Create a copy of UserSettingsModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? themeMode = null,Object? isProjectsListReversed = null,Object? charactersLimitForNewNotes = null,Object? locale = freezed,Object? useTimestampForBackupFilename = null,Object? isSocialNetworksRestricted = null,}) {
  return _then(UserSettingsModel(
themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as ThemeMode,isProjectsListReversed: null == isProjectsListReversed ? _self.isProjectsListReversed : isProjectsListReversed // ignore: cast_nullable_to_non_nullable
as bool,charactersLimitForNewNotes: null == charactersLimitForNewNotes ? _self.charactersLimitForNewNotes : charactersLimitForNewNotes // ignore: cast_nullable_to_non_nullable
as int,locale: freezed == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as Locale?,useTimestampForBackupFilename: null == useTimestampForBackupFilename ? _self.useTimestampForBackupFilename : useTimestampForBackupFilename // ignore: cast_nullable_to_non_nullable
as bool,isSocialNetworksRestricted: null == isSocialNetworksRestricted ? _self.isSocialNetworksRestricted : isSocialNetworksRestricted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [UserSettingsModel].
extension UserSettingsModelPatterns on UserSettingsModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserSettingsModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserSettingsModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserSettingsModel value)  $default,){
final _that = this;
switch (_that) {
case _UserSettingsModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserSettingsModel value)?  $default,){
final _that = this;
switch (_that) {
case _UserSettingsModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _themeModeFromJson, toJson: _themeModeToJson)  ThemeMode themeMode,  bool isProjectsListReversed,  int charactersLimitForNewNotes, @JsonKey(fromJson: _localeFromJson, toJson: _localeToJson)  Locale? locale,  bool useTimestampForBackupFilename,  bool isSocialNetworksRestricted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserSettingsModel() when $default != null:
return $default(_that.themeMode,_that.isProjectsListReversed,_that.charactersLimitForNewNotes,_that.locale,_that.useTimestampForBackupFilename,_that.isSocialNetworksRestricted);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _themeModeFromJson, toJson: _themeModeToJson)  ThemeMode themeMode,  bool isProjectsListReversed,  int charactersLimitForNewNotes, @JsonKey(fromJson: _localeFromJson, toJson: _localeToJson)  Locale? locale,  bool useTimestampForBackupFilename,  bool isSocialNetworksRestricted)  $default,) {final _that = this;
switch (_that) {
case _UserSettingsModel():
return $default(_that.themeMode,_that.isProjectsListReversed,_that.charactersLimitForNewNotes,_that.locale,_that.useTimestampForBackupFilename,_that.isSocialNetworksRestricted);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: _themeModeFromJson, toJson: _themeModeToJson)  ThemeMode themeMode,  bool isProjectsListReversed,  int charactersLimitForNewNotes, @JsonKey(fromJson: _localeFromJson, toJson: _localeToJson)  Locale? locale,  bool useTimestampForBackupFilename,  bool isSocialNetworksRestricted)?  $default,) {final _that = this;
switch (_that) {
case _UserSettingsModel() when $default != null:
return $default(_that.themeMode,_that.isProjectsListReversed,_that.charactersLimitForNewNotes,_that.locale,_that.useTimestampForBackupFilename,_that.isSocialNetworksRestricted);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserSettingsModel with DiagnosticableTreeMixin implements UserSettingsModel {
  const _UserSettingsModel({@JsonKey(fromJson: _themeModeFromJson, toJson: _themeModeToJson) this.themeMode = ThemeMode.system, this.isProjectsListReversed = true, this.charactersLimitForNewNotes = 0, @JsonKey(fromJson: _localeFromJson, toJson: _localeToJson) this.locale, this.useTimestampForBackupFilename = true, this.isSocialNetworksRestricted = true});
  factory _UserSettingsModel.fromJson(Map<String, dynamic> json) => _$UserSettingsModelFromJson(json);

@override@JsonKey(fromJson: _themeModeFromJson, toJson: _themeModeToJson) final  ThemeMode themeMode;
@override@JsonKey() final  bool isProjectsListReversed;
@override@JsonKey() final  int charactersLimitForNewNotes;
@override@JsonKey(fromJson: _localeFromJson, toJson: _localeToJson) final  Locale? locale;
@override@JsonKey() final  bool useTimestampForBackupFilename;
@override@JsonKey() final  bool isSocialNetworksRestricted;

/// Create a copy of UserSettingsModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserSettingsModelCopyWith<_UserSettingsModel> get copyWith => __$UserSettingsModelCopyWithImpl<_UserSettingsModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserSettingsModelToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'UserSettingsModel'))
    ..add(DiagnosticsProperty('themeMode', themeMode))..add(DiagnosticsProperty('isProjectsListReversed', isProjectsListReversed))..add(DiagnosticsProperty('charactersLimitForNewNotes', charactersLimitForNewNotes))..add(DiagnosticsProperty('locale', locale))..add(DiagnosticsProperty('useTimestampForBackupFilename', useTimestampForBackupFilename))..add(DiagnosticsProperty('isSocialNetworksRestricted', isSocialNetworksRestricted));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserSettingsModel&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.isProjectsListReversed, isProjectsListReversed) || other.isProjectsListReversed == isProjectsListReversed)&&(identical(other.charactersLimitForNewNotes, charactersLimitForNewNotes) || other.charactersLimitForNewNotes == charactersLimitForNewNotes)&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.useTimestampForBackupFilename, useTimestampForBackupFilename) || other.useTimestampForBackupFilename == useTimestampForBackupFilename)&&(identical(other.isSocialNetworksRestricted, isSocialNetworksRestricted) || other.isSocialNetworksRestricted == isSocialNetworksRestricted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,themeMode,isProjectsListReversed,charactersLimitForNewNotes,locale,useTimestampForBackupFilename,isSocialNetworksRestricted);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'UserSettingsModel(themeMode: $themeMode, isProjectsListReversed: $isProjectsListReversed, charactersLimitForNewNotes: $charactersLimitForNewNotes, locale: $locale, useTimestampForBackupFilename: $useTimestampForBackupFilename, isSocialNetworksRestricted: $isSocialNetworksRestricted)';
}


}

/// @nodoc
abstract mixin class _$UserSettingsModelCopyWith<$Res> implements $UserSettingsModelCopyWith<$Res> {
  factory _$UserSettingsModelCopyWith(_UserSettingsModel value, $Res Function(_UserSettingsModel) _then) = __$UserSettingsModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: _themeModeFromJson, toJson: _themeModeToJson) ThemeMode themeMode, bool isProjectsListReversed, int charactersLimitForNewNotes,@JsonKey(fromJson: _localeFromJson, toJson: _localeToJson) Locale? locale, bool useTimestampForBackupFilename, bool isSocialNetworksRestricted
});




}
/// @nodoc
class __$UserSettingsModelCopyWithImpl<$Res>
    implements _$UserSettingsModelCopyWith<$Res> {
  __$UserSettingsModelCopyWithImpl(this._self, this._then);

  final _UserSettingsModel _self;
  final $Res Function(_UserSettingsModel) _then;

/// Create a copy of UserSettingsModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? themeMode = null,Object? isProjectsListReversed = null,Object? charactersLimitForNewNotes = null,Object? locale = freezed,Object? useTimestampForBackupFilename = null,Object? isSocialNetworksRestricted = null,}) {
  return _then(_UserSettingsModel(
themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as ThemeMode,isProjectsListReversed: null == isProjectsListReversed ? _self.isProjectsListReversed : isProjectsListReversed // ignore: cast_nullable_to_non_nullable
as bool,charactersLimitForNewNotes: null == charactersLimitForNewNotes ? _self.charactersLimitForNewNotes : charactersLimitForNewNotes // ignore: cast_nullable_to_non_nullable
as int,locale: freezed == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as Locale?,useTimestampForBackupFilename: null == useTimestampForBackupFilename ? _self.useTimestampForBackupFilename : useTimestampForBackupFilename // ignore: cast_nullable_to_non_nullable
as bool,isSocialNetworksRestricted: null == isSocialNetworksRestricted ? _self.isSocialNetworksRestricted : isSocialNetworksRestricted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
