// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notifications_notifier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
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

// dart format on
