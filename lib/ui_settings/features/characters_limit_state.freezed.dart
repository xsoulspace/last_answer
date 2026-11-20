// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'characters_limit_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CharacterLimitState {

 String get value; bool get isEditing;
/// Create a copy of CharacterLimitState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CharacterLimitStateCopyWith<CharacterLimitState> get copyWith => _$CharacterLimitStateCopyWithImpl<CharacterLimitState>(this as CharacterLimitState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CharacterLimitState&&(identical(other.value, value) || other.value == value)&&(identical(other.isEditing, isEditing) || other.isEditing == isEditing));
}


@override
int get hashCode => Object.hash(runtimeType,value,isEditing);

@override
String toString() {
  return 'CharacterLimitState(value: $value, isEditing: $isEditing)';
}


}

/// @nodoc
abstract mixin class $CharacterLimitStateCopyWith<$Res>  {
  factory $CharacterLimitStateCopyWith(CharacterLimitState value, $Res Function(CharacterLimitState) _then) = _$CharacterLimitStateCopyWithImpl;
@useResult
$Res call({
 String value, bool isEditing
});




}
/// @nodoc
class _$CharacterLimitStateCopyWithImpl<$Res>
    implements $CharacterLimitStateCopyWith<$Res> {
  _$CharacterLimitStateCopyWithImpl(this._self, this._then);

  final CharacterLimitState _self;
  final $Res Function(CharacterLimitState) _then;

/// Create a copy of CharacterLimitState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,Object? isEditing = null,}) {
  return _then(CharacterLimitState(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,isEditing: null == isEditing ? _self.isEditing : isEditing // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CharacterLimitState].
extension CharacterLimitStatePatterns on CharacterLimitState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CharacterLimitState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CharacterLimitState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CharacterLimitState value)  $default,){
final _that = this;
switch (_that) {
case _CharacterLimitState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CharacterLimitState value)?  $default,){
final _that = this;
switch (_that) {
case _CharacterLimitState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String value,  bool isEditing)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CharacterLimitState() when $default != null:
return $default(_that.value,_that.isEditing);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String value,  bool isEditing)  $default,) {final _that = this;
switch (_that) {
case _CharacterLimitState():
return $default(_that.value,_that.isEditing);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String value,  bool isEditing)?  $default,) {final _that = this;
switch (_that) {
case _CharacterLimitState() when $default != null:
return $default(_that.value,_that.isEditing);case _:
  return null;

}
}

}

/// @nodoc


class _CharacterLimitState implements CharacterLimitState {
  const _CharacterLimitState({this.value = '', this.isEditing = false});
  

@override@JsonKey() final  String value;
@override@JsonKey() final  bool isEditing;

/// Create a copy of CharacterLimitState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CharacterLimitStateCopyWith<_CharacterLimitState> get copyWith => __$CharacterLimitStateCopyWithImpl<_CharacterLimitState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CharacterLimitState&&(identical(other.value, value) || other.value == value)&&(identical(other.isEditing, isEditing) || other.isEditing == isEditing));
}


@override
int get hashCode => Object.hash(runtimeType,value,isEditing);

@override
String toString() {
  return 'CharacterLimitState(value: $value, isEditing: $isEditing)';
}


}

/// @nodoc
abstract mixin class _$CharacterLimitStateCopyWith<$Res> implements $CharacterLimitStateCopyWith<$Res> {
  factory _$CharacterLimitStateCopyWith(_CharacterLimitState value, $Res Function(_CharacterLimitState) _then) = __$CharacterLimitStateCopyWithImpl;
@override @useResult
$Res call({
 String value, bool isEditing
});




}
/// @nodoc
class __$CharacterLimitStateCopyWithImpl<$Res>
    implements _$CharacterLimitStateCopyWith<$Res> {
  __$CharacterLimitStateCopyWithImpl(this._self, this._then);

  final _CharacterLimitState _self;
  final $Res Function(_CharacterLimitState) _then;

/// Create a copy of CharacterLimitState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,Object? isEditing = null,}) {
  return _then(_CharacterLimitState(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,isEditing: null == isEditing ? _self.isEditing : isEditing // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
