// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ads_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AdsStateModel {

 DateTime? get lastDateWhenAdRewardReceived;
/// Create a copy of AdsStateModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdsStateModelCopyWith<AdsStateModel> get copyWith => _$AdsStateModelCopyWithImpl<AdsStateModel>(this as AdsStateModel, _$identity);

  /// Serializes this AdsStateModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdsStateModel&&(identical(other.lastDateWhenAdRewardReceived, lastDateWhenAdRewardReceived) || other.lastDateWhenAdRewardReceived == lastDateWhenAdRewardReceived));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,lastDateWhenAdRewardReceived);

@override
String toString() {
  return 'AdsStateModel(lastDateWhenAdRewardReceived: $lastDateWhenAdRewardReceived)';
}


}

/// @nodoc
abstract mixin class $AdsStateModelCopyWith<$Res>  {
  factory $AdsStateModelCopyWith(AdsStateModel value, $Res Function(AdsStateModel) _then) = _$AdsStateModelCopyWithImpl;
@useResult
$Res call({
 DateTime? lastDateWhenAdRewardReceived
});




}
/// @nodoc
class _$AdsStateModelCopyWithImpl<$Res>
    implements $AdsStateModelCopyWith<$Res> {
  _$AdsStateModelCopyWithImpl(this._self, this._then);

  final AdsStateModel _self;
  final $Res Function(AdsStateModel) _then;

/// Create a copy of AdsStateModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lastDateWhenAdRewardReceived = freezed,}) {
  return _then(AdsStateModel(
lastDateWhenAdRewardReceived: freezed == lastDateWhenAdRewardReceived ? _self.lastDateWhenAdRewardReceived : lastDateWhenAdRewardReceived // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [AdsStateModel].
extension AdsStateModelPatterns on AdsStateModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdsStateModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdsStateModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdsStateModel value)  $default,){
final _that = this;
switch (_that) {
case _AdsStateModel():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdsStateModel value)?  $default,){
final _that = this;
switch (_that) {
case _AdsStateModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime? lastDateWhenAdRewardReceived)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdsStateModel() when $default != null:
return $default(_that.lastDateWhenAdRewardReceived);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime? lastDateWhenAdRewardReceived)  $default,) {final _that = this;
switch (_that) {
case _AdsStateModel():
return $default(_that.lastDateWhenAdRewardReceived);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime? lastDateWhenAdRewardReceived)?  $default,) {final _that = this;
switch (_that) {
case _AdsStateModel() when $default != null:
return $default(_that.lastDateWhenAdRewardReceived);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdsStateModel extends AdsStateModel {
  const _AdsStateModel({this.lastDateWhenAdRewardReceived}): super._();
  factory _AdsStateModel.fromJson(Map<String, dynamic> json) => _$AdsStateModelFromJson(json);

@override final  DateTime? lastDateWhenAdRewardReceived;

/// Create a copy of AdsStateModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdsStateModelCopyWith<_AdsStateModel> get copyWith => __$AdsStateModelCopyWithImpl<_AdsStateModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdsStateModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdsStateModel&&(identical(other.lastDateWhenAdRewardReceived, lastDateWhenAdRewardReceived) || other.lastDateWhenAdRewardReceived == lastDateWhenAdRewardReceived));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,lastDateWhenAdRewardReceived);

@override
String toString() {
  return 'AdsStateModel(lastDateWhenAdRewardReceived: $lastDateWhenAdRewardReceived)';
}


}

/// @nodoc
abstract mixin class _$AdsStateModelCopyWith<$Res> implements $AdsStateModelCopyWith<$Res> {
  factory _$AdsStateModelCopyWith(_AdsStateModel value, $Res Function(_AdsStateModel) _then) = __$AdsStateModelCopyWithImpl;
@override @useResult
$Res call({
 DateTime? lastDateWhenAdRewardReceived
});




}
/// @nodoc
class __$AdsStateModelCopyWithImpl<$Res>
    implements _$AdsStateModelCopyWith<$Res> {
  __$AdsStateModelCopyWithImpl(this._self, this._then);

  final _AdsStateModel _self;
  final $Res Function(_AdsStateModel) _then;

/// Create a copy of AdsStateModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lastDateWhenAdRewardReceived = freezed,}) {
  return _then(_AdsStateModel(
lastDateWhenAdRewardReceived: freezed == lastDateWhenAdRewardReceived ? _self.lastDateWhenAdRewardReceived : lastDateWhenAdRewardReceived // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
