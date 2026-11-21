// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UserModelId {

 String get value;
/// Create a copy of UserModelId
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserModelIdCopyWith<UserModelId> get copyWith => _$UserModelIdCopyWithImpl<UserModelId>(this as UserModelId, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserModelId&&(identical(other.value, value) || other.value == value));
}


@override
int get hashCode => Object.hash(runtimeType,value);

@override
String toString() {
  return 'UserModelId(value: $value)';
}


}

/// @nodoc
abstract mixin class $UserModelIdCopyWith<$Res>  {
  factory $UserModelIdCopyWith(UserModelId value, $Res Function(UserModelId) _then) = _$UserModelIdCopyWithImpl;
@useResult
$Res call({
 String value
});




}
/// @nodoc
class _$UserModelIdCopyWithImpl<$Res>
    implements $UserModelIdCopyWith<$Res> {
  _$UserModelIdCopyWithImpl(this._self, this._then);

  final UserModelId _self;
  final $Res Function(UserModelId) _then;

/// Create a copy of UserModelId
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,}) {
  return _then(UserModelId(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [UserModelId].
extension UserModelIdPatterns on UserModelId {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserModelId value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserModelId() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserModelId value)  $default,){
final _that = this;
switch (_that) {
case _UserModelId():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserModelId value)?  $default,){
final _that = this;
switch (_that) {
case _UserModelId() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String value)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserModelId() when $default != null:
return $default(_that.value);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String value)  $default,) {final _that = this;
switch (_that) {
case _UserModelId():
return $default(_that.value);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String value)?  $default,) {final _that = this;
switch (_that) {
case _UserModelId() when $default != null:
return $default(_that.value);case _:
  return null;

}
}

}

/// @nodoc


class _UserModelId extends UserModelId {
  const _UserModelId({required this.value}): super._();
  

@override final  String value;

/// Create a copy of UserModelId
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserModelIdCopyWith<_UserModelId> get copyWith => __$UserModelIdCopyWithImpl<_UserModelId>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserModelId&&(identical(other.value, value) || other.value == value));
}


@override
int get hashCode => Object.hash(runtimeType,value);

@override
String toString() {
  return 'UserModelId(value: $value)';
}


}

/// @nodoc
abstract mixin class _$UserModelIdCopyWith<$Res> implements $UserModelIdCopyWith<$Res> {
  factory _$UserModelIdCopyWith(_UserModelId value, $Res Function(_UserModelId) _then) = __$UserModelIdCopyWithImpl;
@override @useResult
$Res call({
 String value
});




}
/// @nodoc
class __$UserModelIdCopyWithImpl<$Res>
    implements _$UserModelIdCopyWith<$Res> {
  __$UserModelIdCopyWithImpl(this._self, this._then);

  final _UserModelId _self;
  final $Res Function(_UserModelId) _then;

/// Create a copy of UserModelId
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,}) {
  return _then(_UserModelId(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$RemoteUserModel {

 UserModelId get id;
/// Create a copy of RemoteUserModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RemoteUserModelCopyWith<RemoteUserModel> get copyWith => _$RemoteUserModelCopyWithImpl<RemoteUserModel>(this as RemoteUserModel, _$identity);

  /// Serializes this RemoteUserModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RemoteUserModel&&(identical(other.id, id) || other.id == id));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id);

@override
String toString() {
  return 'RemoteUserModel(id: $id)';
}


}

/// @nodoc
abstract mixin class $RemoteUserModelCopyWith<$Res>  {
  factory $RemoteUserModelCopyWith(RemoteUserModel value, $Res Function(RemoteUserModel) _then) = _$RemoteUserModelCopyWithImpl;
@useResult
$Res call({
 UserModelId id
});


$UserModelIdCopyWith<$Res> get id;

}
/// @nodoc
class _$RemoteUserModelCopyWithImpl<$Res>
    implements $RemoteUserModelCopyWith<$Res> {
  _$RemoteUserModelCopyWithImpl(this._self, this._then);

  final RemoteUserModel _self;
  final $Res Function(RemoteUserModel) _then;

/// Create a copy of RemoteUserModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,}) {
  return _then(RemoteUserModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as UserModelId,
  ));
}
/// Create a copy of RemoteUserModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserModelIdCopyWith<$Res> get id {
  
  return $UserModelIdCopyWith<$Res>(_self.id, (value) {
    return _then(_self.copyWith(id: value));
  });
}
}


/// Adds pattern-matching-related methods to [RemoteUserModel].
extension RemoteUserModelPatterns on RemoteUserModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RemoteUserModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RemoteUserModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RemoteUserModel value)  $default,){
final _that = this;
switch (_that) {
case _RemoteUserModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RemoteUserModel value)?  $default,){
final _that = this;
switch (_that) {
case _RemoteUserModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( UserModelId id)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RemoteUserModel() when $default != null:
return $default(_that.id);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( UserModelId id)  $default,) {final _that = this;
switch (_that) {
case _RemoteUserModel():
return $default(_that.id);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( UserModelId id)?  $default,) {final _that = this;
switch (_that) {
case _RemoteUserModel() when $default != null:
return $default(_that.id);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _RemoteUserModel extends RemoteUserModel {
  const _RemoteUserModel({this.id = UserModelId.empty}): super._();
  factory _RemoteUserModel.fromJson(Map<String, dynamic> json) => _$RemoteUserModelFromJson(json);

@override@JsonKey() final  UserModelId id;

/// Create a copy of RemoteUserModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RemoteUserModelCopyWith<_RemoteUserModel> get copyWith => __$RemoteUserModelCopyWithImpl<_RemoteUserModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RemoteUserModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RemoteUserModel&&(identical(other.id, id) || other.id == id));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id);

@override
String toString() {
  return 'RemoteUserModel(id: $id)';
}


}

/// @nodoc
abstract mixin class _$RemoteUserModelCopyWith<$Res> implements $RemoteUserModelCopyWith<$Res> {
  factory _$RemoteUserModelCopyWith(_RemoteUserModel value, $Res Function(_RemoteUserModel) _then) = __$RemoteUserModelCopyWithImpl;
@override @useResult
$Res call({
 UserModelId id
});


@override $UserModelIdCopyWith<$Res> get id;

}
/// @nodoc
class __$RemoteUserModelCopyWithImpl<$Res>
    implements _$RemoteUserModelCopyWith<$Res> {
  __$RemoteUserModelCopyWithImpl(this._self, this._then);

  final _RemoteUserModel _self;
  final $Res Function(_RemoteUserModel) _then;

/// Create a copy of RemoteUserModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,}) {
  return _then(_RemoteUserModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as UserModelId,
  ));
}

/// Create a copy of RemoteUserModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserModelIdCopyWith<$Res> get id {
  
  return $UserModelIdCopyWith<$Res>(_self.id, (value) {
    return _then(_self.copyWith(id: value));
  });
}
}

// dart format on
