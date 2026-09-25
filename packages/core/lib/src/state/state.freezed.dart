// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppFeaturesModel implements DiagnosticableTreeMixin {

 bool get isRemoteServicesEnabled;
/// Create a copy of AppFeaturesModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppFeaturesModelCopyWith<AppFeaturesModel> get copyWith => _$AppFeaturesModelCopyWithImpl<AppFeaturesModel>(this as AppFeaturesModel, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'AppFeaturesModel'))
    ..add(DiagnosticsProperty('isRemoteServicesEnabled', isRemoteServicesEnabled));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppFeaturesModel&&(identical(other.isRemoteServicesEnabled, isRemoteServicesEnabled) || other.isRemoteServicesEnabled == isRemoteServicesEnabled));
}


@override
int get hashCode => Object.hash(runtimeType,isRemoteServicesEnabled);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'AppFeaturesModel(isRemoteServicesEnabled: $isRemoteServicesEnabled)';
}


}

/// @nodoc
abstract mixin class $AppFeaturesModelCopyWith<$Res>  {
  factory $AppFeaturesModelCopyWith(AppFeaturesModel value, $Res Function(AppFeaturesModel) _then) = _$AppFeaturesModelCopyWithImpl;
@useResult
$Res call({
 bool isRemoteServicesEnabled
});




}
/// @nodoc
class _$AppFeaturesModelCopyWithImpl<$Res>
    implements $AppFeaturesModelCopyWith<$Res> {
  _$AppFeaturesModelCopyWithImpl(this._self, this._then);

  final AppFeaturesModel _self;
  final $Res Function(AppFeaturesModel) _then;

/// Create a copy of AppFeaturesModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isRemoteServicesEnabled = null,}) {
  return _then(AppFeaturesModel(
isRemoteServicesEnabled: null == isRemoteServicesEnabled ? _self.isRemoteServicesEnabled : isRemoteServicesEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AppFeaturesModel].
extension AppFeaturesModelPatterns on AppFeaturesModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppFeaturesModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppFeaturesModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppFeaturesModel value)  $default,){
final _that = this;
switch (_that) {
case _AppFeaturesModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppFeaturesModel value)?  $default,){
final _that = this;
switch (_that) {
case _AppFeaturesModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isRemoteServicesEnabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppFeaturesModel() when $default != null:
return $default(_that.isRemoteServicesEnabled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isRemoteServicesEnabled)  $default,) {final _that = this;
switch (_that) {
case _AppFeaturesModel():
return $default(_that.isRemoteServicesEnabled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isRemoteServicesEnabled)?  $default,) {final _that = this;
switch (_that) {
case _AppFeaturesModel() when $default != null:
return $default(_that.isRemoteServicesEnabled);case _:
  return null;

}
}

}

/// @nodoc


class _AppFeaturesModel with DiagnosticableTreeMixin implements AppFeaturesModel {
  const _AppFeaturesModel({this.isRemoteServicesEnabled = false});
  

@override@JsonKey() final  bool isRemoteServicesEnabled;

/// Create a copy of AppFeaturesModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppFeaturesModelCopyWith<_AppFeaturesModel> get copyWith => __$AppFeaturesModelCopyWithImpl<_AppFeaturesModel>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'AppFeaturesModel'))
    ..add(DiagnosticsProperty('isRemoteServicesEnabled', isRemoteServicesEnabled));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppFeaturesModel&&(identical(other.isRemoteServicesEnabled, isRemoteServicesEnabled) || other.isRemoteServicesEnabled == isRemoteServicesEnabled));
}


@override
int get hashCode => Object.hash(runtimeType,isRemoteServicesEnabled);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'AppFeaturesModel(isRemoteServicesEnabled: $isRemoteServicesEnabled)';
}


}

/// @nodoc
abstract mixin class _$AppFeaturesModelCopyWith<$Res> implements $AppFeaturesModelCopyWith<$Res> {
  factory _$AppFeaturesModelCopyWith(_AppFeaturesModel value, $Res Function(_AppFeaturesModel) _then) = __$AppFeaturesModelCopyWithImpl;
@override @useResult
$Res call({
 bool isRemoteServicesEnabled
});




}
/// @nodoc
class __$AppFeaturesModelCopyWithImpl<$Res>
    implements _$AppFeaturesModelCopyWith<$Res> {
  __$AppFeaturesModelCopyWithImpl(this._self, this._then);

  final _AppFeaturesModel _self;
  final $Res Function(_AppFeaturesModel) _then;

/// Create a copy of AppFeaturesModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isRemoteServicesEnabled = null,}) {
  return _then(_AppFeaturesModel(
isRemoteServicesEnabled: null == isRemoteServicesEnabled ? _self.isRemoteServicesEnabled : isRemoteServicesEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$AppNotifierState implements DiagnosticableTreeMixin {

 AppStatus get status;
/// Create a copy of AppNotifierState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppNotifierStateCopyWith<AppNotifierState> get copyWith => _$AppNotifierStateCopyWithImpl<AppNotifierState>(this as AppNotifierState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'AppNotifierState'))
    ..add(DiagnosticsProperty('status', status));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppNotifierState&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,status);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'AppNotifierState(status: $status)';
}


}

/// @nodoc
abstract mixin class $AppNotifierStateCopyWith<$Res>  {
  factory $AppNotifierStateCopyWith(AppNotifierState value, $Res Function(AppNotifierState) _then) = _$AppNotifierStateCopyWithImpl;
@useResult
$Res call({
 AppStatus status
});




}
/// @nodoc
class _$AppNotifierStateCopyWithImpl<$Res>
    implements $AppNotifierStateCopyWith<$Res> {
  _$AppNotifierStateCopyWithImpl(this._self, this._then);

  final AppNotifierState _self;
  final $Res Function(AppNotifierState) _then;

/// Create a copy of AppNotifierState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,}) {
  return _then(AppNotifierState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AppStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [AppNotifierState].
extension AppNotifierStatePatterns on AppNotifierState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppNotifierState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppNotifierState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppNotifierState value)  $default,){
final _that = this;
switch (_that) {
case _AppNotifierState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppNotifierState value)?  $default,){
final _that = this;
switch (_that) {
case _AppNotifierState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AppStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppNotifierState() when $default != null:
return $default(_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AppStatus status)  $default,) {final _that = this;
switch (_that) {
case _AppNotifierState():
return $default(_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AppStatus status)?  $default,) {final _that = this;
switch (_that) {
case _AppNotifierState() when $default != null:
return $default(_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _AppNotifierState with DiagnosticableTreeMixin implements AppNotifierState {
  const _AppNotifierState({this.status = AppStatus.loading});
  

@override@JsonKey() final  AppStatus status;

/// Create a copy of AppNotifierState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppNotifierStateCopyWith<_AppNotifierState> get copyWith => __$AppNotifierStateCopyWithImpl<_AppNotifierState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'AppNotifierState'))
    ..add(DiagnosticsProperty('status', status));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppNotifierState&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,status);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'AppNotifierState(status: $status)';
}


}

/// @nodoc
abstract mixin class _$AppNotifierStateCopyWith<$Res> implements $AppNotifierStateCopyWith<$Res> {
  factory _$AppNotifierStateCopyWith(_AppNotifierState value, $Res Function(_AppNotifierState) _then) = __$AppNotifierStateCopyWithImpl;
@override @useResult
$Res call({
 AppStatus status
});




}
/// @nodoc
class __$AppNotifierStateCopyWithImpl<$Res>
    implements _$AppNotifierStateCopyWith<$Res> {
  __$AppNotifierStateCopyWithImpl(this._self, this._then);

  final _AppNotifierState _self;
  final $Res Function(_AppNotifierState) _then;

/// Create a copy of AppNotifierState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,}) {
  return _then(_AppNotifierState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AppStatus,
  ));
}


}

/// @nodoc
mixin _$NotificationsNotifierState implements DiagnosticableTreeMixin {

/// Should be ordered from newest to oldest and never be
 List<NotificationMessageModel> get updates; bool get hasUnreadUpdates;
/// Create a copy of NotificationsNotifierState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationsNotifierStateCopyWith<NotificationsNotifierState> get copyWith => _$NotificationsNotifierStateCopyWithImpl<NotificationsNotifierState>(this as NotificationsNotifierState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'NotificationsNotifierState'))
    ..add(DiagnosticsProperty('updates', updates))..add(DiagnosticsProperty('hasUnreadUpdates', hasUnreadUpdates));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationsNotifierState&&const DeepCollectionEquality().equals(other.updates, updates)&&(identical(other.hasUnreadUpdates, hasUnreadUpdates) || other.hasUnreadUpdates == hasUnreadUpdates));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(updates),hasUnreadUpdates);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'NotificationsNotifierState(updates: $updates, hasUnreadUpdates: $hasUnreadUpdates)';
}


}

/// @nodoc
abstract mixin class $NotificationsNotifierStateCopyWith<$Res>  {
  factory $NotificationsNotifierStateCopyWith(NotificationsNotifierState value, $Res Function(NotificationsNotifierState) _then) = _$NotificationsNotifierStateCopyWithImpl;
@useResult
$Res call({
 List<NotificationMessageModel> updates, bool hasUnreadUpdates
});




}
/// @nodoc
class _$NotificationsNotifierStateCopyWithImpl<$Res>
    implements $NotificationsNotifierStateCopyWith<$Res> {
  _$NotificationsNotifierStateCopyWithImpl(this._self, this._then);

  final NotificationsNotifierState _self;
  final $Res Function(NotificationsNotifierState) _then;

/// Create a copy of NotificationsNotifierState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? updates = null,Object? hasUnreadUpdates = null,}) {
  return _then(NotificationsNotifierState(
updates: null == updates ? _self.updates : updates // ignore: cast_nullable_to_non_nullable
as List<NotificationMessageModel>,hasUnreadUpdates: null == hasUnreadUpdates ? _self.hasUnreadUpdates : hasUnreadUpdates // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationsNotifierState].
extension NotificationsNotifierStatePatterns on NotificationsNotifierState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationsNotifierState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationsNotifierState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationsNotifierState value)  $default,){
final _that = this;
switch (_that) {
case _NotificationsNotifierState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationsNotifierState value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationsNotifierState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<NotificationMessageModel> updates,  bool hasUnreadUpdates)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationsNotifierState() when $default != null:
return $default(_that.updates,_that.hasUnreadUpdates);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<NotificationMessageModel> updates,  bool hasUnreadUpdates)  $default,) {final _that = this;
switch (_that) {
case _NotificationsNotifierState():
return $default(_that.updates,_that.hasUnreadUpdates);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<NotificationMessageModel> updates,  bool hasUnreadUpdates)?  $default,) {final _that = this;
switch (_that) {
case _NotificationsNotifierState() when $default != null:
return $default(_that.updates,_that.hasUnreadUpdates);case _:
  return null;

}
}

}

/// @nodoc


class _NotificationsNotifierState with DiagnosticableTreeMixin implements NotificationsNotifierState {
  const _NotificationsNotifierState({ List<NotificationMessageModel> updates = const [], this.hasUnreadUpdates = false}): _updates = updates;
  

/// Should be ordered from newest to oldest and never be
 final  List<NotificationMessageModel> _updates;
/// Should be ordered from newest to oldest and never be
@override@JsonKey() List<NotificationMessageModel> get updates {
  if (_updates is EqualUnmodifiableListView) return _updates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_updates);
}

@override@JsonKey() final  bool hasUnreadUpdates;

/// Create a copy of NotificationsNotifierState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationsNotifierStateCopyWith<_NotificationsNotifierState> get copyWith => __$NotificationsNotifierStateCopyWithImpl<_NotificationsNotifierState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'NotificationsNotifierState'))
    ..add(DiagnosticsProperty('updates', updates))..add(DiagnosticsProperty('hasUnreadUpdates', hasUnreadUpdates));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationsNotifierState&&const DeepCollectionEquality().equals(other._updates, _updates)&&(identical(other.hasUnreadUpdates, hasUnreadUpdates) || other.hasUnreadUpdates == hasUnreadUpdates));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_updates),hasUnreadUpdates);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'NotificationsNotifierState(updates: $updates, hasUnreadUpdates: $hasUnreadUpdates)';
}


}

/// @nodoc
abstract mixin class _$NotificationsNotifierStateCopyWith<$Res> implements $NotificationsNotifierStateCopyWith<$Res> {
  factory _$NotificationsNotifierStateCopyWith(_NotificationsNotifierState value, $Res Function(_NotificationsNotifierState) _then) = __$NotificationsNotifierStateCopyWithImpl;
@override @useResult
$Res call({
 List<NotificationMessageModel> updates, bool hasUnreadUpdates
});




}
/// @nodoc
class __$NotificationsNotifierStateCopyWithImpl<$Res>
    implements _$NotificationsNotifierStateCopyWith<$Res> {
  __$NotificationsNotifierStateCopyWithImpl(this._self, this._then);

  final _NotificationsNotifierState _self;
  final $Res Function(_NotificationsNotifierState) _then;

/// Create a copy of NotificationsNotifierState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? updates = null,Object? hasUnreadUpdates = null,}) {
  return _then(_NotificationsNotifierState(
updates: null == updates ? _self._updates : updates // ignore: cast_nullable_to_non_nullable
as List<NotificationMessageModel>,hasUnreadUpdates: null == hasUnreadUpdates ? _self.hasUnreadUpdates : hasUnreadUpdates // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$ProjectsNotifierState implements DiagnosticableTreeMixin {

 RequestProjectsDto get requestProjectsDto; bool get isAllProjectsFileLoading;
/// Create a copy of ProjectsNotifierState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectsNotifierStateCopyWith<ProjectsNotifierState> get copyWith => _$ProjectsNotifierStateCopyWithImpl<ProjectsNotifierState>(this as ProjectsNotifierState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'ProjectsNotifierState'))
    ..add(DiagnosticsProperty('requestProjectsDto', requestProjectsDto))..add(DiagnosticsProperty('isAllProjectsFileLoading', isAllProjectsFileLoading));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectsNotifierState&&(identical(other.requestProjectsDto, requestProjectsDto) || other.requestProjectsDto == requestProjectsDto)&&(identical(other.isAllProjectsFileLoading, isAllProjectsFileLoading) || other.isAllProjectsFileLoading == isAllProjectsFileLoading));
}


@override
int get hashCode => Object.hash(runtimeType,requestProjectsDto,isAllProjectsFileLoading);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'ProjectsNotifierState(requestProjectsDto: $requestProjectsDto, isAllProjectsFileLoading: $isAllProjectsFileLoading)';
}


}

/// @nodoc
abstract mixin class $ProjectsNotifierStateCopyWith<$Res>  {
  factory $ProjectsNotifierStateCopyWith(ProjectsNotifierState value, $Res Function(ProjectsNotifierState) _then) = _$ProjectsNotifierStateCopyWithImpl;
@useResult
$Res call({
 RequestProjectsDto requestProjectsDto, bool isAllProjectsFileLoading
});


$RequestProjectsDtoCopyWith<$Res> get requestProjectsDto;

}
/// @nodoc
class _$ProjectsNotifierStateCopyWithImpl<$Res>
    implements $ProjectsNotifierStateCopyWith<$Res> {
  _$ProjectsNotifierStateCopyWithImpl(this._self, this._then);

  final ProjectsNotifierState _self;
  final $Res Function(ProjectsNotifierState) _then;

/// Create a copy of ProjectsNotifierState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? requestProjectsDto = null,Object? isAllProjectsFileLoading = null,}) {
  return _then(ProjectsNotifierState(
requestProjectsDto: null == requestProjectsDto ? _self.requestProjectsDto : requestProjectsDto // ignore: cast_nullable_to_non_nullable
as RequestProjectsDto,isAllProjectsFileLoading: null == isAllProjectsFileLoading ? _self.isAllProjectsFileLoading : isAllProjectsFileLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of ProjectsNotifierState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RequestProjectsDtoCopyWith<$Res> get requestProjectsDto {
  
  return $RequestProjectsDtoCopyWith<$Res>(_self.requestProjectsDto, (value) {
    return _then(_self.copyWith(requestProjectsDto: value));
  });
}
}


/// Adds pattern-matching-related methods to [ProjectsNotifierState].
extension ProjectsNotifierStatePatterns on ProjectsNotifierState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProjectsNotifierState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProjectsNotifierState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProjectsNotifierState value)  $default,){
final _that = this;
switch (_that) {
case _ProjectsNotifierState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProjectsNotifierState value)?  $default,){
final _that = this;
switch (_that) {
case _ProjectsNotifierState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RequestProjectsDto requestProjectsDto,  bool isAllProjectsFileLoading)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProjectsNotifierState() when $default != null:
return $default(_that.requestProjectsDto,_that.isAllProjectsFileLoading);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RequestProjectsDto requestProjectsDto,  bool isAllProjectsFileLoading)  $default,) {final _that = this;
switch (_that) {
case _ProjectsNotifierState():
return $default(_that.requestProjectsDto,_that.isAllProjectsFileLoading);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RequestProjectsDto requestProjectsDto,  bool isAllProjectsFileLoading)?  $default,) {final _that = this;
switch (_that) {
case _ProjectsNotifierState() when $default != null:
return $default(_that.requestProjectsDto,_that.isAllProjectsFileLoading);case _:
  return null;

}
}

}

/// @nodoc


class _ProjectsNotifierState with DiagnosticableTreeMixin implements ProjectsNotifierState {
  const _ProjectsNotifierState({this.requestProjectsDto = RequestProjectsDto.empty, this.isAllProjectsFileLoading = false});
  

@override@JsonKey() final  RequestProjectsDto requestProjectsDto;
@override@JsonKey() final  bool isAllProjectsFileLoading;

/// Create a copy of ProjectsNotifierState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProjectsNotifierStateCopyWith<_ProjectsNotifierState> get copyWith => __$ProjectsNotifierStateCopyWithImpl<_ProjectsNotifierState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'ProjectsNotifierState'))
    ..add(DiagnosticsProperty('requestProjectsDto', requestProjectsDto))..add(DiagnosticsProperty('isAllProjectsFileLoading', isAllProjectsFileLoading));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProjectsNotifierState&&(identical(other.requestProjectsDto, requestProjectsDto) || other.requestProjectsDto == requestProjectsDto)&&(identical(other.isAllProjectsFileLoading, isAllProjectsFileLoading) || other.isAllProjectsFileLoading == isAllProjectsFileLoading));
}


@override
int get hashCode => Object.hash(runtimeType,requestProjectsDto,isAllProjectsFileLoading);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'ProjectsNotifierState(requestProjectsDto: $requestProjectsDto, isAllProjectsFileLoading: $isAllProjectsFileLoading)';
}


}

/// @nodoc
abstract mixin class _$ProjectsNotifierStateCopyWith<$Res> implements $ProjectsNotifierStateCopyWith<$Res> {
  factory _$ProjectsNotifierStateCopyWith(_ProjectsNotifierState value, $Res Function(_ProjectsNotifierState) _then) = __$ProjectsNotifierStateCopyWithImpl;
@override @useResult
$Res call({
 RequestProjectsDto requestProjectsDto, bool isAllProjectsFileLoading
});


@override $RequestProjectsDtoCopyWith<$Res> get requestProjectsDto;

}
/// @nodoc
class __$ProjectsNotifierStateCopyWithImpl<$Res>
    implements _$ProjectsNotifierStateCopyWith<$Res> {
  __$ProjectsNotifierStateCopyWithImpl(this._self, this._then);

  final _ProjectsNotifierState _self;
  final $Res Function(_ProjectsNotifierState) _then;

/// Create a copy of ProjectsNotifierState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? requestProjectsDto = null,Object? isAllProjectsFileLoading = null,}) {
  return _then(_ProjectsNotifierState(
requestProjectsDto: null == requestProjectsDto ? _self.requestProjectsDto : requestProjectsDto // ignore: cast_nullable_to_non_nullable
as RequestProjectsDto,isAllProjectsFileLoading: null == isAllProjectsFileLoading ? _self.isAllProjectsFileLoading : isAllProjectsFileLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of ProjectsNotifierState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RequestProjectsDtoCopyWith<$Res> get requestProjectsDto {
  
  return $RequestProjectsDtoCopyWith<$Res>(_self.requestProjectsDto, (value) {
    return _then(_self.copyWith(requestProjectsDto: value));
  });
}
}

/// @nodoc
mixin _$RequestProjectsDto implements DiagnosticableTreeMixin {

 String get search; List<ProjectTypes> get types; bool get isReversed; ProjectTagModelId get tagId;/// Enabled to include changelog and other system "notes"
 bool get shouldAddChangelog;
/// Create a copy of RequestProjectsDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RequestProjectsDtoCopyWith<RequestProjectsDto> get copyWith => _$RequestProjectsDtoCopyWithImpl<RequestProjectsDto>(this as RequestProjectsDto, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'RequestProjectsDto'))
    ..add(DiagnosticsProperty('search', search))..add(DiagnosticsProperty('types', types))..add(DiagnosticsProperty('isReversed', isReversed))..add(DiagnosticsProperty('tagId', tagId))..add(DiagnosticsProperty('shouldAddChangelog', shouldAddChangelog));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RequestProjectsDto&&(identical(other.search, search) || other.search == search)&&const DeepCollectionEquality().equals(other.types, types)&&(identical(other.isReversed, isReversed) || other.isReversed == isReversed)&&(identical(other.tagId, tagId) || other.tagId == tagId)&&(identical(other.shouldAddChangelog, shouldAddChangelog) || other.shouldAddChangelog == shouldAddChangelog));
}


@override
int get hashCode => Object.hash(runtimeType,search,const DeepCollectionEquality().hash(types),isReversed,tagId,shouldAddChangelog);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'RequestProjectsDto(search: $search, types: $types, isReversed: $isReversed, tagId: $tagId, shouldAddChangelog: $shouldAddChangelog)';
}


}

/// @nodoc
abstract mixin class $RequestProjectsDtoCopyWith<$Res>  {
  factory $RequestProjectsDtoCopyWith(RequestProjectsDto value, $Res Function(RequestProjectsDto) _then) = _$RequestProjectsDtoCopyWithImpl;
@useResult
$Res call({
 String search, List<ProjectTypes> types, bool isReversed, ProjectTagModelId tagId, bool shouldAddChangelog
});




}
/// @nodoc
class _$RequestProjectsDtoCopyWithImpl<$Res>
    implements $RequestProjectsDtoCopyWith<$Res> {
  _$RequestProjectsDtoCopyWithImpl(this._self, this._then);

  final RequestProjectsDto _self;
  final $Res Function(RequestProjectsDto) _then;

/// Create a copy of RequestProjectsDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? search = null,Object? types = null,Object? isReversed = null,Object? tagId = null,Object? shouldAddChangelog = null,}) {
  return _then(RequestProjectsDto(
search: null == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String,types: null == types ? _self.types : types // ignore: cast_nullable_to_non_nullable
as List<ProjectTypes>,isReversed: null == isReversed ? _self.isReversed : isReversed // ignore: cast_nullable_to_non_nullable
as bool,tagId: null == tagId ? _self.tagId : tagId // ignore: cast_nullable_to_non_nullable
as ProjectTagModelId,shouldAddChangelog: null == shouldAddChangelog ? _self.shouldAddChangelog : shouldAddChangelog // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [RequestProjectsDto].
extension RequestProjectsDtoPatterns on RequestProjectsDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RequestProjectsDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RequestProjectsDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RequestProjectsDto value)  $default,){
final _that = this;
switch (_that) {
case _RequestProjectsDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RequestProjectsDto value)?  $default,){
final _that = this;
switch (_that) {
case _RequestProjectsDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String search,  List<ProjectTypes> types,  bool isReversed,  ProjectTagModelId tagId,  bool shouldAddChangelog)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RequestProjectsDto() when $default != null:
return $default(_that.search,_that.types,_that.isReversed,_that.tagId,_that.shouldAddChangelog);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String search,  List<ProjectTypes> types,  bool isReversed,  ProjectTagModelId tagId,  bool shouldAddChangelog)  $default,) {final _that = this;
switch (_that) {
case _RequestProjectsDto():
return $default(_that.search,_that.types,_that.isReversed,_that.tagId,_that.shouldAddChangelog);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String search,  List<ProjectTypes> types,  bool isReversed,  ProjectTagModelId tagId,  bool shouldAddChangelog)?  $default,) {final _that = this;
switch (_that) {
case _RequestProjectsDto() when $default != null:
return $default(_that.search,_that.types,_that.isReversed,_that.tagId,_that.shouldAddChangelog);case _:
  return null;

}
}

}

/// @nodoc


class _RequestProjectsDto extends RequestProjectsDto with DiagnosticableTreeMixin {
  const _RequestProjectsDto({this.search = '',  List<ProjectTypes> types = const [], this.isReversed = false, this.tagId = ProjectTagModelId.empty, this.shouldAddChangelog = false}): _types = types,super._();
  

@override@JsonKey() final  String search;
 final  List<ProjectTypes> _types;
@override@JsonKey() List<ProjectTypes> get types {
  if (_types is EqualUnmodifiableListView) return _types;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_types);
}

@override@JsonKey() final  bool isReversed;
@override@JsonKey() final  ProjectTagModelId tagId;
/// Enabled to include changelog and other system "notes"
@override@JsonKey() final  bool shouldAddChangelog;

/// Create a copy of RequestProjectsDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RequestProjectsDtoCopyWith<_RequestProjectsDto> get copyWith => __$RequestProjectsDtoCopyWithImpl<_RequestProjectsDto>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'RequestProjectsDto'))
    ..add(DiagnosticsProperty('search', search))..add(DiagnosticsProperty('types', types))..add(DiagnosticsProperty('isReversed', isReversed))..add(DiagnosticsProperty('tagId', tagId))..add(DiagnosticsProperty('shouldAddChangelog', shouldAddChangelog));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RequestProjectsDto&&(identical(other.search, search) || other.search == search)&&const DeepCollectionEquality().equals(other._types, _types)&&(identical(other.isReversed, isReversed) || other.isReversed == isReversed)&&(identical(other.tagId, tagId) || other.tagId == tagId)&&(identical(other.shouldAddChangelog, shouldAddChangelog) || other.shouldAddChangelog == shouldAddChangelog));
}


@override
int get hashCode => Object.hash(runtimeType,search,const DeepCollectionEquality().hash(_types),isReversed,tagId,shouldAddChangelog);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'RequestProjectsDto(search: $search, types: $types, isReversed: $isReversed, tagId: $tagId, shouldAddChangelog: $shouldAddChangelog)';
}


}

/// @nodoc
abstract mixin class _$RequestProjectsDtoCopyWith<$Res> implements $RequestProjectsDtoCopyWith<$Res> {
  factory _$RequestProjectsDtoCopyWith(_RequestProjectsDto value, $Res Function(_RequestProjectsDto) _then) = __$RequestProjectsDtoCopyWithImpl;
@override @useResult
$Res call({
 String search, List<ProjectTypes> types, bool isReversed, ProjectTagModelId tagId, bool shouldAddChangelog
});




}
/// @nodoc
class __$RequestProjectsDtoCopyWithImpl<$Res>
    implements _$RequestProjectsDtoCopyWith<$Res> {
  __$RequestProjectsDtoCopyWithImpl(this._self, this._then);

  final _RequestProjectsDto _self;
  final $Res Function(_RequestProjectsDto) _then;

/// Create a copy of RequestProjectsDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? search = null,Object? types = null,Object? isReversed = null,Object? tagId = null,Object? shouldAddChangelog = null,}) {
  return _then(_RequestProjectsDto(
search: null == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String,types: null == types ? _self._types : types // ignore: cast_nullable_to_non_nullable
as List<ProjectTypes>,isReversed: null == isReversed ? _self.isReversed : isReversed // ignore: cast_nullable_to_non_nullable
as bool,tagId: null == tagId ? _self.tagId : tagId // ignore: cast_nullable_to_non_nullable
as ProjectTagModelId,shouldAddChangelog: null == shouldAddChangelog ? _self.shouldAddChangelog : shouldAddChangelog // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
