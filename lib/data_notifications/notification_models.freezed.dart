// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotificationMessageModel implements DiagnosticableTreeMixin {

 String get id; LocalizedTextModel get message; LocalizedTextModel get title; DateTime get created;
/// Create a copy of NotificationMessageModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationMessageModelCopyWith<NotificationMessageModel> get copyWith => _$NotificationMessageModelCopyWithImpl<NotificationMessageModel>(this as NotificationMessageModel, _$identity);

  /// Serializes this NotificationMessageModel to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'NotificationMessageModel'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('message', message))..add(DiagnosticsProperty('title', title))..add(DiagnosticsProperty('created', created));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationMessageModel&&(identical(other.id, id) || other.id == id)&&(identical(other.message, message) || other.message == message)&&(identical(other.title, title) || other.title == title)&&(identical(other.created, created) || other.created == created));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,message,title,created);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'NotificationMessageModel(id: $id, message: $message, title: $title, created: $created)';
}


}

/// @nodoc
abstract mixin class $NotificationMessageModelCopyWith<$Res>  {
  factory $NotificationMessageModelCopyWith(NotificationMessageModel value, $Res Function(NotificationMessageModel) _then) = _$NotificationMessageModelCopyWithImpl;
@useResult
$Res call({
 String id, LocalizedTextModel message, LocalizedTextModel title, DateTime created
});


$LocalizedTextModelCopyWith<$Res> get message;$LocalizedTextModelCopyWith<$Res> get title;

}
/// @nodoc
class _$NotificationMessageModelCopyWithImpl<$Res>
    implements $NotificationMessageModelCopyWith<$Res> {
  _$NotificationMessageModelCopyWithImpl(this._self, this._then);

  final NotificationMessageModel _self;
  final $Res Function(NotificationMessageModel) _then;

/// Create a copy of NotificationMessageModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? message = null,Object? title = null,Object? created = null,}) {
  return _then(NotificationMessageModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as LocalizedTextModel,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as LocalizedTextModel,created: null == created ? _self.created : created // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of NotificationMessageModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocalizedTextModelCopyWith<$Res> get message {
  
  return $LocalizedTextModelCopyWith<$Res>(_self.message, (value) {
    return _then(_self.copyWith(message: value));
  });
}/// Create a copy of NotificationMessageModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocalizedTextModelCopyWith<$Res> get title {
  
  return $LocalizedTextModelCopyWith<$Res>(_self.title, (value) {
    return _then(_self.copyWith(title: value));
  });
}
}


/// Adds pattern-matching-related methods to [NotificationMessageModel].
extension NotificationMessageModelPatterns on NotificationMessageModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationMessageModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationMessageModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationMessageModel value)  $default,){
final _that = this;
switch (_that) {
case _NotificationMessageModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationMessageModel value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationMessageModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  LocalizedTextModel message,  LocalizedTextModel title,  DateTime created)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationMessageModel() when $default != null:
return $default(_that.id,_that.message,_that.title,_that.created);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  LocalizedTextModel message,  LocalizedTextModel title,  DateTime created)  $default,) {final _that = this;
switch (_that) {
case _NotificationMessageModel():
return $default(_that.id,_that.message,_that.title,_that.created);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  LocalizedTextModel message,  LocalizedTextModel title,  DateTime created)?  $default,) {final _that = this;
switch (_that) {
case _NotificationMessageModel() when $default != null:
return $default(_that.id,_that.message,_that.title,_that.created);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationMessageModel with DiagnosticableTreeMixin implements NotificationMessageModel {
  const _NotificationMessageModel({required this.id, required this.message, required this.title, required this.created});
  factory _NotificationMessageModel.fromJson(Map<String, dynamic> json) => _$NotificationMessageModelFromJson(json);

@override final  String id;
@override final  LocalizedTextModel message;
@override final  LocalizedTextModel title;
@override final  DateTime created;

/// Create a copy of NotificationMessageModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationMessageModelCopyWith<_NotificationMessageModel> get copyWith => __$NotificationMessageModelCopyWithImpl<_NotificationMessageModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationMessageModelToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'NotificationMessageModel'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('message', message))..add(DiagnosticsProperty('title', title))..add(DiagnosticsProperty('created', created));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationMessageModel&&(identical(other.id, id) || other.id == id)&&(identical(other.message, message) || other.message == message)&&(identical(other.title, title) || other.title == title)&&(identical(other.created, created) || other.created == created));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,message,title,created);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'NotificationMessageModel(id: $id, message: $message, title: $title, created: $created)';
}


}

/// @nodoc
abstract mixin class _$NotificationMessageModelCopyWith<$Res> implements $NotificationMessageModelCopyWith<$Res> {
  factory _$NotificationMessageModelCopyWith(_NotificationMessageModel value, $Res Function(_NotificationMessageModel) _then) = __$NotificationMessageModelCopyWithImpl;
@override @useResult
$Res call({
 String id, LocalizedTextModel message, LocalizedTextModel title, DateTime created
});


@override $LocalizedTextModelCopyWith<$Res> get message;@override $LocalizedTextModelCopyWith<$Res> get title;

}
/// @nodoc
class __$NotificationMessageModelCopyWithImpl<$Res>
    implements _$NotificationMessageModelCopyWith<$Res> {
  __$NotificationMessageModelCopyWithImpl(this._self, this._then);

  final _NotificationMessageModel _self;
  final $Res Function(_NotificationMessageModel) _then;

/// Create a copy of NotificationMessageModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? message = null,Object? title = null,Object? created = null,}) {
  return _then(_NotificationMessageModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as LocalizedTextModel,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as LocalizedTextModel,created: null == created ? _self.created : created // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of NotificationMessageModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocalizedTextModelCopyWith<$Res> get message {
  
  return $LocalizedTextModelCopyWith<$Res>(_self.message, (value) {
    return _then(_self.copyWith(message: value));
  });
}/// Create a copy of NotificationMessageModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocalizedTextModelCopyWith<$Res> get title {
  
  return $LocalizedTextModelCopyWith<$Res>(_self.title, (value) {
    return _then(_self.copyWith(title: value));
  });
}
}

// dart format on
