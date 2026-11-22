// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_notifier.dart';

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

// dart format on
