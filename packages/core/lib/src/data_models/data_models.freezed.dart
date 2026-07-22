// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'data_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotificationMessageModel {

 String get id; LocalizedTextModel get message; LocalizedTextModel get title; DateTime get created;
/// Create a copy of NotificationMessageModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationMessageModelCopyWith<NotificationMessageModel> get copyWith => _$NotificationMessageModelCopyWithImpl<NotificationMessageModel>(this as NotificationMessageModel, _$identity);

  /// Serializes this NotificationMessageModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationMessageModel&&(identical(other.id, id) || other.id == id)&&(identical(other.message, message) || other.message == message)&&(identical(other.title, title) || other.title == title)&&(identical(other.created, created) || other.created == created));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,message,title,created);

@override
String toString() {
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

class _NotificationMessageModel implements NotificationMessageModel {
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
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationMessageModel&&(identical(other.id, id) || other.id == id)&&(identical(other.message, message) || other.message == message)&&(identical(other.title, title) || other.title == title)&&(identical(other.created, created) || other.created == created));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,message,title,created);

@override
String toString() {
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


/// @nodoc
mixin _$DocBlockModel {

 DocBlockId get id; DocBlockType get type; String get content; int? get level;
/// Create a copy of DocBlockModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocBlockModelCopyWith<DocBlockModel> get copyWith => _$DocBlockModelCopyWithImpl<DocBlockModel>(this as DocBlockModel, _$identity);

  /// Serializes this DocBlockModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DocBlockModel&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.content, content) || other.content == content)&&(identical(other.level, level) || other.level == level));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,content,level);

@override
String toString() {
  return 'DocBlockModel(id: $id, type: $type, content: $content, level: $level)';
}


}

/// @nodoc
abstract mixin class $DocBlockModelCopyWith<$Res>  {
  factory $DocBlockModelCopyWith(DocBlockModel value, $Res Function(DocBlockModel) _then) = _$DocBlockModelCopyWithImpl;
@useResult
$Res call({
 DocBlockId id, DocBlockType type, String content, int? level
});




}
/// @nodoc
class _$DocBlockModelCopyWithImpl<$Res>
    implements $DocBlockModelCopyWith<$Res> {
  _$DocBlockModelCopyWithImpl(this._self, this._then);

  final DocBlockModel _self;
  final $Res Function(DocBlockModel) _then;

/// Create a copy of DocBlockModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? content = null,Object? level = freezed,}) {
  return _then(DocBlockModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as DocBlockId,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as DocBlockType,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,level: freezed == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [DocBlockModel].
extension DocBlockModelPatterns on DocBlockModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DocBlockModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DocBlockModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DocBlockModel value)  $default,){
final _that = this;
switch (_that) {
case _DocBlockModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DocBlockModel value)?  $default,){
final _that = this;
switch (_that) {
case _DocBlockModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DocBlockId id,  DocBlockType type,  String content,  int? level)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DocBlockModel() when $default != null:
return $default(_that.id,_that.type,_that.content,_that.level);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DocBlockId id,  DocBlockType type,  String content,  int? level)  $default,) {final _that = this;
switch (_that) {
case _DocBlockModel():
return $default(_that.id,_that.type,_that.content,_that.level);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DocBlockId id,  DocBlockType type,  String content,  int? level)?  $default,) {final _that = this;
switch (_that) {
case _DocBlockModel() when $default != null:
return $default(_that.id,_that.type,_that.content,_that.level);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DocBlockModel implements DocBlockModel {
  const _DocBlockModel({required this.id, required this.type, this.content = '', this.level});
  factory _DocBlockModel.fromJson(Map<String, dynamic> json) => _$DocBlockModelFromJson(json);

@override final  DocBlockId id;
@override final  DocBlockType type;
@override@JsonKey() final  String content;
@override final  int? level;

/// Create a copy of DocBlockModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DocBlockModelCopyWith<_DocBlockModel> get copyWith => __$DocBlockModelCopyWithImpl<_DocBlockModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DocBlockModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DocBlockModel&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.content, content) || other.content == content)&&(identical(other.level, level) || other.level == level));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,content,level);

@override
String toString() {
  return 'DocBlockModel(id: $id, type: $type, content: $content, level: $level)';
}


}

/// @nodoc
abstract mixin class _$DocBlockModelCopyWith<$Res> implements $DocBlockModelCopyWith<$Res> {
  factory _$DocBlockModelCopyWith(_DocBlockModel value, $Res Function(_DocBlockModel) _then) = __$DocBlockModelCopyWithImpl;
@override @useResult
$Res call({
 DocBlockId id, DocBlockType type, String content, int? level
});




}
/// @nodoc
class __$DocBlockModelCopyWithImpl<$Res>
    implements _$DocBlockModelCopyWith<$Res> {
  __$DocBlockModelCopyWithImpl(this._self, this._then);

  final _DocBlockModel _self;
  final $Res Function(_DocBlockModel) _then;

/// Create a copy of DocBlockModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? content = null,Object? level = freezed,}) {
  return _then(_DocBlockModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as DocBlockId,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as DocBlockType,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,level: freezed == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$DocThreadMessageModel {

 String get content; DateTime get timestamp; String get authorId; String get authorName;
/// Create a copy of DocThreadMessageModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocThreadMessageModelCopyWith<DocThreadMessageModel> get copyWith => _$DocThreadMessageModelCopyWithImpl<DocThreadMessageModel>(this as DocThreadMessageModel, _$identity);

  /// Serializes this DocThreadMessageModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DocThreadMessageModel&&(identical(other.content, content) || other.content == content)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.authorName, authorName) || other.authorName == authorName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,content,timestamp,authorId,authorName);

@override
String toString() {
  return 'DocThreadMessageModel(content: $content, timestamp: $timestamp, authorId: $authorId, authorName: $authorName)';
}


}

/// @nodoc
abstract mixin class $DocThreadMessageModelCopyWith<$Res>  {
  factory $DocThreadMessageModelCopyWith(DocThreadMessageModel value, $Res Function(DocThreadMessageModel) _then) = _$DocThreadMessageModelCopyWithImpl;
@useResult
$Res call({
 String content, DateTime timestamp, String authorId, String authorName
});




}
/// @nodoc
class _$DocThreadMessageModelCopyWithImpl<$Res>
    implements $DocThreadMessageModelCopyWith<$Res> {
  _$DocThreadMessageModelCopyWithImpl(this._self, this._then);

  final DocThreadMessageModel _self;
  final $Res Function(DocThreadMessageModel) _then;

/// Create a copy of DocThreadMessageModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? content = null,Object? timestamp = null,Object? authorId = null,Object? authorName = null,}) {
  return _then(DocThreadMessageModel(
content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,authorId: null == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as String,authorName: null == authorName ? _self.authorName : authorName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DocThreadMessageModel].
extension DocThreadMessageModelPatterns on DocThreadMessageModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DocThreadMessageModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DocThreadMessageModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DocThreadMessageModel value)  $default,){
final _that = this;
switch (_that) {
case _DocThreadMessageModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DocThreadMessageModel value)?  $default,){
final _that = this;
switch (_that) {
case _DocThreadMessageModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String content,  DateTime timestamp,  String authorId,  String authorName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DocThreadMessageModel() when $default != null:
return $default(_that.content,_that.timestamp,_that.authorId,_that.authorName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String content,  DateTime timestamp,  String authorId,  String authorName)  $default,) {final _that = this;
switch (_that) {
case _DocThreadMessageModel():
return $default(_that.content,_that.timestamp,_that.authorId,_that.authorName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String content,  DateTime timestamp,  String authorId,  String authorName)?  $default,) {final _that = this;
switch (_that) {
case _DocThreadMessageModel() when $default != null:
return $default(_that.content,_that.timestamp,_that.authorId,_that.authorName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DocThreadMessageModel implements DocThreadMessageModel {
  const _DocThreadMessageModel({required this.content, required this.timestamp, this.authorId = '', this.authorName = ''});
  factory _DocThreadMessageModel.fromJson(Map<String, dynamic> json) => _$DocThreadMessageModelFromJson(json);

@override final  String content;
@override final  DateTime timestamp;
@override@JsonKey() final  String authorId;
@override@JsonKey() final  String authorName;

/// Create a copy of DocThreadMessageModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DocThreadMessageModelCopyWith<_DocThreadMessageModel> get copyWith => __$DocThreadMessageModelCopyWithImpl<_DocThreadMessageModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DocThreadMessageModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DocThreadMessageModel&&(identical(other.content, content) || other.content == content)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.authorName, authorName) || other.authorName == authorName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,content,timestamp,authorId,authorName);

@override
String toString() {
  return 'DocThreadMessageModel(content: $content, timestamp: $timestamp, authorId: $authorId, authorName: $authorName)';
}


}

/// @nodoc
abstract mixin class _$DocThreadMessageModelCopyWith<$Res> implements $DocThreadMessageModelCopyWith<$Res> {
  factory _$DocThreadMessageModelCopyWith(_DocThreadMessageModel value, $Res Function(_DocThreadMessageModel) _then) = __$DocThreadMessageModelCopyWithImpl;
@override @useResult
$Res call({
 String content, DateTime timestamp, String authorId, String authorName
});




}
/// @nodoc
class __$DocThreadMessageModelCopyWithImpl<$Res>
    implements _$DocThreadMessageModelCopyWith<$Res> {
  __$DocThreadMessageModelCopyWithImpl(this._self, this._then);

  final _DocThreadMessageModel _self;
  final $Res Function(_DocThreadMessageModel) _then;

/// Create a copy of DocThreadMessageModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? content = null,Object? timestamp = null,Object? authorId = null,Object? authorName = null,}) {
  return _then(_DocThreadMessageModel(
content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,authorId: null == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as String,authorName: null == authorName ? _self.authorName : authorName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$DocThreadModel {

 List<DocThreadMessageModel> get messages;
/// Create a copy of DocThreadModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocThreadModelCopyWith<DocThreadModel> get copyWith => _$DocThreadModelCopyWithImpl<DocThreadModel>(this as DocThreadModel, _$identity);

  /// Serializes this DocThreadModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DocThreadModel&&const DeepCollectionEquality().equals(other.messages, messages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(messages));

@override
String toString() {
  return 'DocThreadModel(messages: $messages)';
}


}

/// @nodoc
abstract mixin class $DocThreadModelCopyWith<$Res>  {
  factory $DocThreadModelCopyWith(DocThreadModel value, $Res Function(DocThreadModel) _then) = _$DocThreadModelCopyWithImpl;
@useResult
$Res call({
 List<DocThreadMessageModel> messages
});




}
/// @nodoc
class _$DocThreadModelCopyWithImpl<$Res>
    implements $DocThreadModelCopyWith<$Res> {
  _$DocThreadModelCopyWithImpl(this._self, this._then);

  final DocThreadModel _self;
  final $Res Function(DocThreadModel) _then;

/// Create a copy of DocThreadModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? messages = null,}) {
  return _then(DocThreadModel(
messages: null == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as List<DocThreadMessageModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [DocThreadModel].
extension DocThreadModelPatterns on DocThreadModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DocThreadModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DocThreadModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DocThreadModel value)  $default,){
final _that = this;
switch (_that) {
case _DocThreadModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DocThreadModel value)?  $default,){
final _that = this;
switch (_that) {
case _DocThreadModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<DocThreadMessageModel> messages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DocThreadModel() when $default != null:
return $default(_that.messages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<DocThreadMessageModel> messages)  $default,) {final _that = this;
switch (_that) {
case _DocThreadModel():
return $default(_that.messages);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<DocThreadMessageModel> messages)?  $default,) {final _that = this;
switch (_that) {
case _DocThreadModel() when $default != null:
return $default(_that.messages);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DocThreadModel implements DocThreadModel {
  const _DocThreadModel({ List<DocThreadMessageModel> messages = const []}): _messages = messages;
  factory _DocThreadModel.fromJson(Map<String, dynamic> json) => _$DocThreadModelFromJson(json);

 final  List<DocThreadMessageModel> _messages;
@override@JsonKey() List<DocThreadMessageModel> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}


/// Create a copy of DocThreadModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DocThreadModelCopyWith<_DocThreadModel> get copyWith => __$DocThreadModelCopyWithImpl<_DocThreadModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DocThreadModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DocThreadModel&&const DeepCollectionEquality().equals(other._messages, _messages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_messages));

@override
String toString() {
  return 'DocThreadModel(messages: $messages)';
}


}

/// @nodoc
abstract mixin class _$DocThreadModelCopyWith<$Res> implements $DocThreadModelCopyWith<$Res> {
  factory _$DocThreadModelCopyWith(_DocThreadModel value, $Res Function(_DocThreadModel) _then) = __$DocThreadModelCopyWithImpl;
@override @useResult
$Res call({
 List<DocThreadMessageModel> messages
});




}
/// @nodoc
class __$DocThreadModelCopyWithImpl<$Res>
    implements _$DocThreadModelCopyWith<$Res> {
  __$DocThreadModelCopyWithImpl(this._self, this._then);

  final _DocThreadModel _self;
  final $Res Function(_DocThreadModel) _then;

/// Create a copy of DocThreadModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? messages = null,}) {
  return _then(_DocThreadModel(
messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<DocThreadMessageModel>,
  ));
}


}

ProjectModel _$ProjectModelFromJson(
  Map<String, dynamic> json
) {
        switch (json['runtimeType']) {
                  case 'idea':
          return ProjectModelIdea.fromJson(
            json
          );
                case 'note':
          return ProjectModelNote.fromJson(
            json
          );
                case 'changelog':
          return ProjectModelChangelog.fromJson(
            json
          );
                case 'doc':
          return ProjectModelDoc.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'runtimeType',
  'ProjectModel',
  'Invalid union type "${json['runtimeType']}"!'
);
        }
      
}

/// @nodoc
mixin _$ProjectModel {

 ProjectModelId get id; DateTime get createdAt; DateTime get updatedAt; ProjectTypes get type; DateTime? get archivedAt; List<ProjectTagModelId> get tagsIds;
/// Create a copy of ProjectModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectModelCopyWith<ProjectModel> get copyWith => _$ProjectModelCopyWithImpl<ProjectModel>(this as ProjectModel, _$identity);

  /// Serializes this ProjectModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectModel&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.type, type) || other.type == type)&&(identical(other.archivedAt, archivedAt) || other.archivedAt == archivedAt)&&const DeepCollectionEquality().equals(other.tagsIds, tagsIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createdAt,updatedAt,type,archivedAt,const DeepCollectionEquality().hash(tagsIds));

@override
String toString() {
  return 'ProjectModel(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, type: $type, archivedAt: $archivedAt, tagsIds: $tagsIds)';
}


}

/// @nodoc
abstract mixin class $ProjectModelCopyWith<$Res>  {
  factory $ProjectModelCopyWith(ProjectModel value, $Res Function(ProjectModel) _then) = _$ProjectModelCopyWithImpl;
@useResult
$Res call({
 ProjectModelId id, DateTime createdAt, DateTime updatedAt, ProjectTypes type, DateTime? archivedAt, List<ProjectTagModelId> tagsIds
});




}
/// @nodoc
class _$ProjectModelCopyWithImpl<$Res>
    implements $ProjectModelCopyWith<$Res> {
  _$ProjectModelCopyWithImpl(this._self, this._then);

  final ProjectModel _self;
  final $Res Function(ProjectModel) _then;

/// Create a copy of ProjectModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? createdAt = null,Object? updatedAt = null,Object? type = null,Object? archivedAt = freezed,Object? tagsIds = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as ProjectModelId,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ProjectTypes,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,tagsIds: null == tagsIds ? _self.tagsIds : tagsIds // ignore: cast_nullable_to_non_nullable
as List<ProjectTagModelId>,
  ));
}

}


/// Adds pattern-matching-related methods to [ProjectModel].
extension ProjectModelPatterns on ProjectModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ProjectModelIdea value)?  idea,TResult Function( ProjectModelNote value)?  note,TResult Function( ProjectModelChangelog value)?  changelog,TResult Function( ProjectModelDoc value)?  doc,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ProjectModelIdea() when idea != null:
return idea(_that);case ProjectModelNote() when note != null:
return note(_that);case ProjectModelChangelog() when changelog != null:
return changelog(_that);case ProjectModelDoc() when doc != null:
return doc(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ProjectModelIdea value)  idea,required TResult Function( ProjectModelNote value)  note,required TResult Function( ProjectModelChangelog value)  changelog,required TResult Function( ProjectModelDoc value)  doc,}){
final _that = this;
switch (_that) {
case ProjectModelIdea():
return idea(_that);case ProjectModelNote():
return note(_that);case ProjectModelChangelog():
return changelog(_that);case ProjectModelDoc():
return doc(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ProjectModelIdea value)?  idea,TResult? Function( ProjectModelNote value)?  note,TResult? Function( ProjectModelChangelog value)?  changelog,TResult? Function( ProjectModelDoc value)?  doc,}){
final _that = this;
switch (_that) {
case ProjectModelIdea() when idea != null:
return idea(_that);case ProjectModelNote() when note != null:
return note(_that);case ProjectModelChangelog() when changelog != null:
return changelog(_that);case ProjectModelDoc() when doc != null:
return doc(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( ProjectModelId id,  DateTime createdAt,  DateTime updatedAt,  String title,  ProjectTypes type,  DateTime? archivedAt,  List<IdeaProjectAnswerModel> answers,  IdeaProjectAnswerModel? draftAnswer,  List<ProjectTagModelId> tagsIds)?  idea,TResult Function( ProjectModelId id,  DateTime createdAt,  DateTime updatedAt,  String note,  ProjectTypes type,  int charactersLimit,  DateTime? archivedAt,  List<ProjectTagModelId> tagsIds)?  note,TResult Function( DateTime createdAt,  DateTime updatedAt,  LocalizedTextModel title,  ProjectModelId id,  ProjectTypes type,  List<ProjectTagModelId> tagsIds,  DateTime? archivedAt)?  changelog,TResult Function( ProjectModelId id,  DateTime createdAt,  DateTime updatedAt,  DocKind docKind,  String title,  ProjectTypes type,  List<ProjectTagModelId> tagsIds,  DateTime? archivedAt,  List<DocBlockModel> blocks, @JsonKey(fromJson: threadsFromJsonMap, toJson: threadsToJsonMap)  Map<SpanId, DocThreadModel> threads)?  doc,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ProjectModelIdea() when idea != null:
return idea(_that.id,_that.createdAt,_that.updatedAt,_that.title,_that.type,_that.archivedAt,_that.answers,_that.draftAnswer,_that.tagsIds);case ProjectModelNote() when note != null:
return note(_that.id,_that.createdAt,_that.updatedAt,_that.note,_that.type,_that.charactersLimit,_that.archivedAt,_that.tagsIds);case ProjectModelChangelog() when changelog != null:
return changelog(_that.createdAt,_that.updatedAt,_that.title,_that.id,_that.type,_that.tagsIds,_that.archivedAt);case ProjectModelDoc() when doc != null:
return doc(_that.id,_that.createdAt,_that.updatedAt,_that.docKind,_that.title,_that.type,_that.tagsIds,_that.archivedAt,_that.blocks,_that.threads);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( ProjectModelId id,  DateTime createdAt,  DateTime updatedAt,  String title,  ProjectTypes type,  DateTime? archivedAt,  List<IdeaProjectAnswerModel> answers,  IdeaProjectAnswerModel? draftAnswer,  List<ProjectTagModelId> tagsIds)  idea,required TResult Function( ProjectModelId id,  DateTime createdAt,  DateTime updatedAt,  String note,  ProjectTypes type,  int charactersLimit,  DateTime? archivedAt,  List<ProjectTagModelId> tagsIds)  note,required TResult Function( DateTime createdAt,  DateTime updatedAt,  LocalizedTextModel title,  ProjectModelId id,  ProjectTypes type,  List<ProjectTagModelId> tagsIds,  DateTime? archivedAt)  changelog,required TResult Function( ProjectModelId id,  DateTime createdAt,  DateTime updatedAt,  DocKind docKind,  String title,  ProjectTypes type,  List<ProjectTagModelId> tagsIds,  DateTime? archivedAt,  List<DocBlockModel> blocks, @JsonKey(fromJson: threadsFromJsonMap, toJson: threadsToJsonMap)  Map<SpanId, DocThreadModel> threads)  doc,}) {final _that = this;
switch (_that) {
case ProjectModelIdea():
return idea(_that.id,_that.createdAt,_that.updatedAt,_that.title,_that.type,_that.archivedAt,_that.answers,_that.draftAnswer,_that.tagsIds);case ProjectModelNote():
return note(_that.id,_that.createdAt,_that.updatedAt,_that.note,_that.type,_that.charactersLimit,_that.archivedAt,_that.tagsIds);case ProjectModelChangelog():
return changelog(_that.createdAt,_that.updatedAt,_that.title,_that.id,_that.type,_that.tagsIds,_that.archivedAt);case ProjectModelDoc():
return doc(_that.id,_that.createdAt,_that.updatedAt,_that.docKind,_that.title,_that.type,_that.tagsIds,_that.archivedAt,_that.blocks,_that.threads);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( ProjectModelId id,  DateTime createdAt,  DateTime updatedAt,  String title,  ProjectTypes type,  DateTime? archivedAt,  List<IdeaProjectAnswerModel> answers,  IdeaProjectAnswerModel? draftAnswer,  List<ProjectTagModelId> tagsIds)?  idea,TResult? Function( ProjectModelId id,  DateTime createdAt,  DateTime updatedAt,  String note,  ProjectTypes type,  int charactersLimit,  DateTime? archivedAt,  List<ProjectTagModelId> tagsIds)?  note,TResult? Function( DateTime createdAt,  DateTime updatedAt,  LocalizedTextModel title,  ProjectModelId id,  ProjectTypes type,  List<ProjectTagModelId> tagsIds,  DateTime? archivedAt)?  changelog,TResult? Function( ProjectModelId id,  DateTime createdAt,  DateTime updatedAt,  DocKind docKind,  String title,  ProjectTypes type,  List<ProjectTagModelId> tagsIds,  DateTime? archivedAt,  List<DocBlockModel> blocks, @JsonKey(fromJson: threadsFromJsonMap, toJson: threadsToJsonMap)  Map<SpanId, DocThreadModel> threads)?  doc,}) {final _that = this;
switch (_that) {
case ProjectModelIdea() when idea != null:
return idea(_that.id,_that.createdAt,_that.updatedAt,_that.title,_that.type,_that.archivedAt,_that.answers,_that.draftAnswer,_that.tagsIds);case ProjectModelNote() when note != null:
return note(_that.id,_that.createdAt,_that.updatedAt,_that.note,_that.type,_that.charactersLimit,_that.archivedAt,_that.tagsIds);case ProjectModelChangelog() when changelog != null:
return changelog(_that.createdAt,_that.updatedAt,_that.title,_that.id,_that.type,_that.tagsIds,_that.archivedAt);case ProjectModelDoc() when doc != null:
return doc(_that.id,_that.createdAt,_that.updatedAt,_that.docKind,_that.title,_that.type,_that.tagsIds,_that.archivedAt,_that.blocks,_that.threads);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class ProjectModelIdea extends ProjectModel implements Archivable, Sharable {
  const ProjectModelIdea({required this.id, required this.createdAt, required this.updatedAt, this.title = '', this.type = ProjectTypes.idea, this.archivedAt,  List<IdeaProjectAnswerModel> answers = const [], this.draftAnswer,  List<ProjectTagModelId> tagsIds = const [],  String? $type}): _answers = answers,_tagsIds = tagsIds,$type = $type ?? 'idea',super._();
  factory ProjectModelIdea.fromJson(Map<String, dynamic> json) => _$ProjectModelIdeaFromJson(json);

@override final  ProjectModelId id;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@JsonKey() final  String title;
@override@JsonKey() final  ProjectTypes type;
@override final  DateTime? archivedAt;
 final  List<IdeaProjectAnswerModel> _answers;
@JsonKey() List<IdeaProjectAnswerModel> get answers {
  if (_answers is EqualUnmodifiableListView) return _answers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_answers);
}

 final  IdeaProjectAnswerModel? draftAnswer;
 final  List<ProjectTagModelId> _tagsIds;
@override@JsonKey() List<ProjectTagModelId> get tagsIds {
  if (_tagsIds is EqualUnmodifiableListView) return _tagsIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tagsIds);
}


@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of ProjectModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectModelIdeaCopyWith<ProjectModelIdea> get copyWith => _$ProjectModelIdeaCopyWithImpl<ProjectModelIdea>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProjectModelIdeaToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectModelIdea&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.title, title) || other.title == title)&&(identical(other.type, type) || other.type == type)&&(identical(other.archivedAt, archivedAt) || other.archivedAt == archivedAt)&&const DeepCollectionEquality().equals(other._answers, _answers)&&(identical(other.draftAnswer, draftAnswer) || other.draftAnswer == draftAnswer)&&const DeepCollectionEquality().equals(other._tagsIds, _tagsIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createdAt,updatedAt,title,type,archivedAt,const DeepCollectionEquality().hash(_answers),draftAnswer,const DeepCollectionEquality().hash(_tagsIds));

@override
String toString() {
  return 'ProjectModel.idea(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, title: $title, type: $type, archivedAt: $archivedAt, answers: $answers, draftAnswer: $draftAnswer, tagsIds: $tagsIds)';
}


}

/// @nodoc
abstract mixin class $ProjectModelIdeaCopyWith<$Res> implements $ProjectModelCopyWith<$Res> {
  factory $ProjectModelIdeaCopyWith(ProjectModelIdea value, $Res Function(ProjectModelIdea) _then) = _$ProjectModelIdeaCopyWithImpl;
@override @useResult
$Res call({
 ProjectModelId id, DateTime createdAt, DateTime updatedAt, String title, ProjectTypes type, DateTime? archivedAt, List<IdeaProjectAnswerModel> answers, IdeaProjectAnswerModel? draftAnswer, List<ProjectTagModelId> tagsIds
});


$IdeaProjectAnswerModelCopyWith<$Res>? get draftAnswer;

}
/// @nodoc
class _$ProjectModelIdeaCopyWithImpl<$Res>
    implements $ProjectModelIdeaCopyWith<$Res> {
  _$ProjectModelIdeaCopyWithImpl(this._self, this._then);

  final ProjectModelIdea _self;
  final $Res Function(ProjectModelIdea) _then;

/// Create a copy of ProjectModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? createdAt = null,Object? updatedAt = null,Object? title = null,Object? type = null,Object? archivedAt = freezed,Object? answers = null,Object? draftAnswer = freezed,Object? tagsIds = null,}) {
  return _then(ProjectModelIdea(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as ProjectModelId,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ProjectTypes,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,answers: null == answers ? _self._answers : answers // ignore: cast_nullable_to_non_nullable
as List<IdeaProjectAnswerModel>,draftAnswer: freezed == draftAnswer ? _self.draftAnswer : draftAnswer // ignore: cast_nullable_to_non_nullable
as IdeaProjectAnswerModel?,tagsIds: null == tagsIds ? _self._tagsIds : tagsIds // ignore: cast_nullable_to_non_nullable
as List<ProjectTagModelId>,
  ));
}

/// Create a copy of ProjectModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IdeaProjectAnswerModelCopyWith<$Res>? get draftAnswer {
    if (_self.draftAnswer == null) {
    return null;
  }

  return $IdeaProjectAnswerModelCopyWith<$Res>(_self.draftAnswer!, (value) {
    return _then(_self.copyWith(draftAnswer: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class ProjectModelNote extends ProjectModel implements Archivable, Sharable {
  const ProjectModelNote({required this.id, required this.createdAt, required this.updatedAt, this.note = '', this.type = ProjectTypes.note, this.charactersLimit = 0, this.archivedAt,  List<ProjectTagModelId> tagsIds = const [],  String? $type}): _tagsIds = tagsIds,$type = $type ?? 'note',super._();
  factory ProjectModelNote.fromJson(Map<String, dynamic> json) => _$ProjectModelNoteFromJson(json);

@override final  ProjectModelId id;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@JsonKey() final  String note;
@override@JsonKey() final  ProjectTypes type;
@JsonKey() final  int charactersLimit;
@override final  DateTime? archivedAt;
 final  List<ProjectTagModelId> _tagsIds;
@override@JsonKey() List<ProjectTagModelId> get tagsIds {
  if (_tagsIds is EqualUnmodifiableListView) return _tagsIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tagsIds);
}


@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of ProjectModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectModelNoteCopyWith<ProjectModelNote> get copyWith => _$ProjectModelNoteCopyWithImpl<ProjectModelNote>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProjectModelNoteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectModelNote&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.note, note) || other.note == note)&&(identical(other.type, type) || other.type == type)&&(identical(other.charactersLimit, charactersLimit) || other.charactersLimit == charactersLimit)&&(identical(other.archivedAt, archivedAt) || other.archivedAt == archivedAt)&&const DeepCollectionEquality().equals(other._tagsIds, _tagsIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createdAt,updatedAt,note,type,charactersLimit,archivedAt,const DeepCollectionEquality().hash(_tagsIds));

@override
String toString() {
  return 'ProjectModel.note(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, note: $note, type: $type, charactersLimit: $charactersLimit, archivedAt: $archivedAt, tagsIds: $tagsIds)';
}


}

/// @nodoc
abstract mixin class $ProjectModelNoteCopyWith<$Res> implements $ProjectModelCopyWith<$Res> {
  factory $ProjectModelNoteCopyWith(ProjectModelNote value, $Res Function(ProjectModelNote) _then) = _$ProjectModelNoteCopyWithImpl;
@override @useResult
$Res call({
 ProjectModelId id, DateTime createdAt, DateTime updatedAt, String note, ProjectTypes type, int charactersLimit, DateTime? archivedAt, List<ProjectTagModelId> tagsIds
});




}
/// @nodoc
class _$ProjectModelNoteCopyWithImpl<$Res>
    implements $ProjectModelNoteCopyWith<$Res> {
  _$ProjectModelNoteCopyWithImpl(this._self, this._then);

  final ProjectModelNote _self;
  final $Res Function(ProjectModelNote) _then;

/// Create a copy of ProjectModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? createdAt = null,Object? updatedAt = null,Object? note = null,Object? type = null,Object? charactersLimit = null,Object? archivedAt = freezed,Object? tagsIds = null,}) {
  return _then(ProjectModelNote(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as ProjectModelId,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ProjectTypes,charactersLimit: null == charactersLimit ? _self.charactersLimit : charactersLimit // ignore: cast_nullable_to_non_nullable
as int,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,tagsIds: null == tagsIds ? _self._tagsIds : tagsIds // ignore: cast_nullable_to_non_nullable
as List<ProjectTagModelId>,
  ));
}


}

/// @nodoc
@JsonSerializable()

class ProjectModelChangelog extends ProjectModel implements Sharable, Archivable {
  const ProjectModelChangelog({required this.createdAt, required this.updatedAt, this.title = LocalizedTextModel.empty, this.id = ProjectModelId.systemChangelog, this.type = ProjectTypes.systemChangelog,  List<ProjectTagModelId> tagsIds = const [], this.archivedAt,  String? $type}): _tagsIds = tagsIds,$type = $type ?? 'changelog',super._();
  factory ProjectModelChangelog.fromJson(Map<String, dynamic> json) => _$ProjectModelChangelogFromJson(json);

@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@JsonKey() final  LocalizedTextModel title;
@override@JsonKey() final  ProjectModelId id;
@override@JsonKey() final  ProjectTypes type;
 final  List<ProjectTagModelId> _tagsIds;
@override@JsonKey() List<ProjectTagModelId> get tagsIds {
  if (_tagsIds is EqualUnmodifiableListView) return _tagsIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tagsIds);
}

@override final  DateTime? archivedAt;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of ProjectModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectModelChangelogCopyWith<ProjectModelChangelog> get copyWith => _$ProjectModelChangelogCopyWithImpl<ProjectModelChangelog>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProjectModelChangelogToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectModelChangelog&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.title, title) || other.title == title)&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other._tagsIds, _tagsIds)&&(identical(other.archivedAt, archivedAt) || other.archivedAt == archivedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,createdAt,updatedAt,title,id,type,const DeepCollectionEquality().hash(_tagsIds),archivedAt);

@override
String toString() {
  return 'ProjectModel.changelog(createdAt: $createdAt, updatedAt: $updatedAt, title: $title, id: $id, type: $type, tagsIds: $tagsIds, archivedAt: $archivedAt)';
}


}

/// @nodoc
abstract mixin class $ProjectModelChangelogCopyWith<$Res> implements $ProjectModelCopyWith<$Res> {
  factory $ProjectModelChangelogCopyWith(ProjectModelChangelog value, $Res Function(ProjectModelChangelog) _then) = _$ProjectModelChangelogCopyWithImpl;
@override @useResult
$Res call({
 DateTime createdAt, DateTime updatedAt, LocalizedTextModel title, ProjectModelId id, ProjectTypes type, List<ProjectTagModelId> tagsIds, DateTime? archivedAt
});


$LocalizedTextModelCopyWith<$Res> get title;

}
/// @nodoc
class _$ProjectModelChangelogCopyWithImpl<$Res>
    implements $ProjectModelChangelogCopyWith<$Res> {
  _$ProjectModelChangelogCopyWithImpl(this._self, this._then);

  final ProjectModelChangelog _self;
  final $Res Function(ProjectModelChangelog) _then;

/// Create a copy of ProjectModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? createdAt = null,Object? updatedAt = null,Object? title = null,Object? id = null,Object? type = null,Object? tagsIds = null,Object? archivedAt = freezed,}) {
  return _then(ProjectModelChangelog(
createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as LocalizedTextModel,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as ProjectModelId,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ProjectTypes,tagsIds: null == tagsIds ? _self._tagsIds : tagsIds // ignore: cast_nullable_to_non_nullable
as List<ProjectTagModelId>,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of ProjectModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocalizedTextModelCopyWith<$Res> get title {
  
  return $LocalizedTextModelCopyWith<$Res>(_self.title, (value) {
    return _then(_self.copyWith(title: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class ProjectModelDoc extends ProjectModel implements Archivable, Sharable {
  const ProjectModelDoc({required this.id, required this.createdAt, required this.updatedAt, required this.docKind, this.title = '', this.type = ProjectTypes.doc,  List<ProjectTagModelId> tagsIds = const [], this.archivedAt,  List<DocBlockModel> blocks = const [], @JsonKey(fromJson: threadsFromJsonMap, toJson: threadsToJsonMap)  Map<SpanId, DocThreadModel> threads = const {},  String? $type}): _tagsIds = tagsIds,_blocks = blocks,_threads = threads,$type = $type ?? 'doc',super._();
  factory ProjectModelDoc.fromJson(Map<String, dynamic> json) => _$ProjectModelDocFromJson(json);

@override final  ProjectModelId id;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
 final  DocKind docKind;
@JsonKey() final  String title;
@override@JsonKey() final  ProjectTypes type;
 final  List<ProjectTagModelId> _tagsIds;
@override@JsonKey() List<ProjectTagModelId> get tagsIds {
  if (_tagsIds is EqualUnmodifiableListView) return _tagsIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tagsIds);
}

@override final  DateTime? archivedAt;
 final  List<DocBlockModel> _blocks;
@JsonKey() List<DocBlockModel> get blocks {
  if (_blocks is EqualUnmodifiableListView) return _blocks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_blocks);
}

 final  Map<SpanId, DocThreadModel> _threads;
@JsonKey(fromJson: threadsFromJsonMap, toJson: threadsToJsonMap) Map<SpanId, DocThreadModel> get threads {
  if (_threads is EqualUnmodifiableMapView) return _threads;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_threads);
}


@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of ProjectModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectModelDocCopyWith<ProjectModelDoc> get copyWith => _$ProjectModelDocCopyWithImpl<ProjectModelDoc>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProjectModelDocToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectModelDoc&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.docKind, docKind) || other.docKind == docKind)&&(identical(other.title, title) || other.title == title)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other._tagsIds, _tagsIds)&&(identical(other.archivedAt, archivedAt) || other.archivedAt == archivedAt)&&const DeepCollectionEquality().equals(other._blocks, _blocks)&&const DeepCollectionEquality().equals(other._threads, _threads));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createdAt,updatedAt,docKind,title,type,const DeepCollectionEquality().hash(_tagsIds),archivedAt,const DeepCollectionEquality().hash(_blocks),const DeepCollectionEquality().hash(_threads));

@override
String toString() {
  return 'ProjectModel.doc(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, docKind: $docKind, title: $title, type: $type, tagsIds: $tagsIds, archivedAt: $archivedAt, blocks: $blocks, threads: $threads)';
}


}

/// @nodoc
abstract mixin class $ProjectModelDocCopyWith<$Res> implements $ProjectModelCopyWith<$Res> {
  factory $ProjectModelDocCopyWith(ProjectModelDoc value, $Res Function(ProjectModelDoc) _then) = _$ProjectModelDocCopyWithImpl;
@override @useResult
$Res call({
 ProjectModelId id, DateTime createdAt, DateTime updatedAt, DocKind docKind, String title, ProjectTypes type, List<ProjectTagModelId> tagsIds, DateTime? archivedAt, List<DocBlockModel> blocks,@JsonKey(fromJson: threadsFromJsonMap, toJson: threadsToJsonMap) Map<SpanId, DocThreadModel> threads
});




}
/// @nodoc
class _$ProjectModelDocCopyWithImpl<$Res>
    implements $ProjectModelDocCopyWith<$Res> {
  _$ProjectModelDocCopyWithImpl(this._self, this._then);

  final ProjectModelDoc _self;
  final $Res Function(ProjectModelDoc) _then;

/// Create a copy of ProjectModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? createdAt = null,Object? updatedAt = null,Object? docKind = null,Object? title = null,Object? type = null,Object? tagsIds = null,Object? archivedAt = freezed,Object? blocks = null,Object? threads = null,}) {
  return _then(ProjectModelDoc(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as ProjectModelId,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,docKind: null == docKind ? _self.docKind : docKind // ignore: cast_nullable_to_non_nullable
as DocKind,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ProjectTypes,tagsIds: null == tagsIds ? _self._tagsIds : tagsIds // ignore: cast_nullable_to_non_nullable
as List<ProjectTagModelId>,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,blocks: null == blocks ? _self._blocks : blocks // ignore: cast_nullable_to_non_nullable
as List<DocBlockModel>,threads: null == threads ? _self._threads : threads // ignore: cast_nullable_to_non_nullable
as Map<SpanId, DocThreadModel>,
  ));
}


}


/// @nodoc
mixin _$IdeaProjectAnswerModel {

 IdeaProjectAnswerModelId get id; DateTime get createdAt; IdeaProjectQuestionModel get question; String get text;
/// Create a copy of IdeaProjectAnswerModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IdeaProjectAnswerModelCopyWith<IdeaProjectAnswerModel> get copyWith => _$IdeaProjectAnswerModelCopyWithImpl<IdeaProjectAnswerModel>(this as IdeaProjectAnswerModel, _$identity);

  /// Serializes this IdeaProjectAnswerModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IdeaProjectAnswerModel&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.question, question) || other.question == question)&&(identical(other.text, text) || other.text == text));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createdAt,question,text);

@override
String toString() {
  return 'IdeaProjectAnswerModel(id: $id, createdAt: $createdAt, question: $question, text: $text)';
}


}

/// @nodoc
abstract mixin class $IdeaProjectAnswerModelCopyWith<$Res>  {
  factory $IdeaProjectAnswerModelCopyWith(IdeaProjectAnswerModel value, $Res Function(IdeaProjectAnswerModel) _then) = _$IdeaProjectAnswerModelCopyWithImpl;
@useResult
$Res call({
 IdeaProjectAnswerModelId id, DateTime createdAt, IdeaProjectQuestionModel question, String text
});


$IdeaProjectQuestionModelCopyWith<$Res> get question;

}
/// @nodoc
class _$IdeaProjectAnswerModelCopyWithImpl<$Res>
    implements $IdeaProjectAnswerModelCopyWith<$Res> {
  _$IdeaProjectAnswerModelCopyWithImpl(this._self, this._then);

  final IdeaProjectAnswerModel _self;
  final $Res Function(IdeaProjectAnswerModel) _then;

/// Create a copy of IdeaProjectAnswerModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? createdAt = null,Object? question = null,Object? text = null,}) {
  return _then(IdeaProjectAnswerModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as IdeaProjectAnswerModelId,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as IdeaProjectQuestionModel,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of IdeaProjectAnswerModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IdeaProjectQuestionModelCopyWith<$Res> get question {
  
  return $IdeaProjectQuestionModelCopyWith<$Res>(_self.question, (value) {
    return _then(_self.copyWith(question: value));
  });
}
}


/// Adds pattern-matching-related methods to [IdeaProjectAnswerModel].
extension IdeaProjectAnswerModelPatterns on IdeaProjectAnswerModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IdeaProjectAnswerModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IdeaProjectAnswerModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IdeaProjectAnswerModel value)  $default,){
final _that = this;
switch (_that) {
case _IdeaProjectAnswerModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IdeaProjectAnswerModel value)?  $default,){
final _that = this;
switch (_that) {
case _IdeaProjectAnswerModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( IdeaProjectAnswerModelId id,  DateTime createdAt,  IdeaProjectQuestionModel question,  String text)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IdeaProjectAnswerModel() when $default != null:
return $default(_that.id,_that.createdAt,_that.question,_that.text);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( IdeaProjectAnswerModelId id,  DateTime createdAt,  IdeaProjectQuestionModel question,  String text)  $default,) {final _that = this;
switch (_that) {
case _IdeaProjectAnswerModel():
return $default(_that.id,_that.createdAt,_that.question,_that.text);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( IdeaProjectAnswerModelId id,  DateTime createdAt,  IdeaProjectQuestionModel question,  String text)?  $default,) {final _that = this;
switch (_that) {
case _IdeaProjectAnswerModel() when $default != null:
return $default(_that.id,_that.createdAt,_that.question,_that.text);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IdeaProjectAnswerModel extends IdeaProjectAnswerModel {
  const _IdeaProjectAnswerModel({required this.id, required this.createdAt, required this.question, this.text = ''}): super._();
  factory _IdeaProjectAnswerModel.fromJson(Map<String, dynamic> json) => _$IdeaProjectAnswerModelFromJson(json);

@override final  IdeaProjectAnswerModelId id;
@override final  DateTime createdAt;
@override final  IdeaProjectQuestionModel question;
@override@JsonKey() final  String text;

/// Create a copy of IdeaProjectAnswerModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IdeaProjectAnswerModelCopyWith<_IdeaProjectAnswerModel> get copyWith => __$IdeaProjectAnswerModelCopyWithImpl<_IdeaProjectAnswerModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IdeaProjectAnswerModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IdeaProjectAnswerModel&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.question, question) || other.question == question)&&(identical(other.text, text) || other.text == text));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createdAt,question,text);

@override
String toString() {
  return 'IdeaProjectAnswerModel(id: $id, createdAt: $createdAt, question: $question, text: $text)';
}


}

/// @nodoc
abstract mixin class _$IdeaProjectAnswerModelCopyWith<$Res> implements $IdeaProjectAnswerModelCopyWith<$Res> {
  factory _$IdeaProjectAnswerModelCopyWith(_IdeaProjectAnswerModel value, $Res Function(_IdeaProjectAnswerModel) _then) = __$IdeaProjectAnswerModelCopyWithImpl;
@override @useResult
$Res call({
 IdeaProjectAnswerModelId id, DateTime createdAt, IdeaProjectQuestionModel question, String text
});


@override $IdeaProjectQuestionModelCopyWith<$Res> get question;

}
/// @nodoc
class __$IdeaProjectAnswerModelCopyWithImpl<$Res>
    implements _$IdeaProjectAnswerModelCopyWith<$Res> {
  __$IdeaProjectAnswerModelCopyWithImpl(this._self, this._then);

  final _IdeaProjectAnswerModel _self;
  final $Res Function(_IdeaProjectAnswerModel) _then;

/// Create a copy of IdeaProjectAnswerModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? createdAt = null,Object? question = null,Object? text = null,}) {
  return _then(_IdeaProjectAnswerModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as IdeaProjectAnswerModelId,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as IdeaProjectQuestionModel,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of IdeaProjectAnswerModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IdeaProjectQuestionModelCopyWith<$Res> get question {
  
  return $IdeaProjectQuestionModelCopyWith<$Res>(_self.question, (value) {
    return _then(_self.copyWith(question: value));
  });
}
}


/// @nodoc
mixin _$IdeaProjectQuestionModel {

 IdeaProjectQuestionModelId get id; LocalizedTextModel get title;
/// Create a copy of IdeaProjectQuestionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IdeaProjectQuestionModelCopyWith<IdeaProjectQuestionModel> get copyWith => _$IdeaProjectQuestionModelCopyWithImpl<IdeaProjectQuestionModel>(this as IdeaProjectQuestionModel, _$identity);

  /// Serializes this IdeaProjectQuestionModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IdeaProjectQuestionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title);

@override
String toString() {
  return 'IdeaProjectQuestionModel(id: $id, title: $title)';
}


}

/// @nodoc
abstract mixin class $IdeaProjectQuestionModelCopyWith<$Res>  {
  factory $IdeaProjectQuestionModelCopyWith(IdeaProjectQuestionModel value, $Res Function(IdeaProjectQuestionModel) _then) = _$IdeaProjectQuestionModelCopyWithImpl;
@useResult
$Res call({
 IdeaProjectQuestionModelId id, LocalizedTextModel title
});


$LocalizedTextModelCopyWith<$Res> get title;

}
/// @nodoc
class _$IdeaProjectQuestionModelCopyWithImpl<$Res>
    implements $IdeaProjectQuestionModelCopyWith<$Res> {
  _$IdeaProjectQuestionModelCopyWithImpl(this._self, this._then);

  final IdeaProjectQuestionModel _self;
  final $Res Function(IdeaProjectQuestionModel) _then;

/// Create a copy of IdeaProjectQuestionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,}) {
  return _then(IdeaProjectQuestionModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as IdeaProjectQuestionModelId,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as LocalizedTextModel,
  ));
}
/// Create a copy of IdeaProjectQuestionModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocalizedTextModelCopyWith<$Res> get title {
  
  return $LocalizedTextModelCopyWith<$Res>(_self.title, (value) {
    return _then(_self.copyWith(title: value));
  });
}
}


/// Adds pattern-matching-related methods to [IdeaProjectQuestionModel].
extension IdeaProjectQuestionModelPatterns on IdeaProjectQuestionModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IdeaProjectQuestionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IdeaProjectQuestionModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IdeaProjectQuestionModel value)  $default,){
final _that = this;
switch (_that) {
case _IdeaProjectQuestionModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IdeaProjectQuestionModel value)?  $default,){
final _that = this;
switch (_that) {
case _IdeaProjectQuestionModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( IdeaProjectQuestionModelId id,  LocalizedTextModel title)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IdeaProjectQuestionModel() when $default != null:
return $default(_that.id,_that.title);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( IdeaProjectQuestionModelId id,  LocalizedTextModel title)  $default,) {final _that = this;
switch (_that) {
case _IdeaProjectQuestionModel():
return $default(_that.id,_that.title);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( IdeaProjectQuestionModelId id,  LocalizedTextModel title)?  $default,) {final _that = this;
switch (_that) {
case _IdeaProjectQuestionModel() when $default != null:
return $default(_that.id,_that.title);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IdeaProjectQuestionModel extends IdeaProjectQuestionModel {
  const _IdeaProjectQuestionModel({required this.id, required this.title}): super._();
  factory _IdeaProjectQuestionModel.fromJson(Map<String, dynamic> json) => _$IdeaProjectQuestionModelFromJson(json);

@override final  IdeaProjectQuestionModelId id;
@override final  LocalizedTextModel title;

/// Create a copy of IdeaProjectQuestionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IdeaProjectQuestionModelCopyWith<_IdeaProjectQuestionModel> get copyWith => __$IdeaProjectQuestionModelCopyWithImpl<_IdeaProjectQuestionModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IdeaProjectQuestionModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IdeaProjectQuestionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title);

@override
String toString() {
  return 'IdeaProjectQuestionModel(id: $id, title: $title)';
}


}

/// @nodoc
abstract mixin class _$IdeaProjectQuestionModelCopyWith<$Res> implements $IdeaProjectQuestionModelCopyWith<$Res> {
  factory _$IdeaProjectQuestionModelCopyWith(_IdeaProjectQuestionModel value, $Res Function(_IdeaProjectQuestionModel) _then) = __$IdeaProjectQuestionModelCopyWithImpl;
@override @useResult
$Res call({
 IdeaProjectQuestionModelId id, LocalizedTextModel title
});


@override $LocalizedTextModelCopyWith<$Res> get title;

}
/// @nodoc
class __$IdeaProjectQuestionModelCopyWithImpl<$Res>
    implements _$IdeaProjectQuestionModelCopyWith<$Res> {
  __$IdeaProjectQuestionModelCopyWithImpl(this._self, this._then);

  final _IdeaProjectQuestionModel _self;
  final $Res Function(_IdeaProjectQuestionModel) _then;

/// Create a copy of IdeaProjectQuestionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,}) {
  return _then(_IdeaProjectQuestionModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as IdeaProjectQuestionModelId,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as LocalizedTextModel,
  ));
}

/// Create a copy of IdeaProjectQuestionModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocalizedTextModelCopyWith<$Res> get title {
  
  return $LocalizedTextModelCopyWith<$Res>(_self.title, (value) {
    return _then(_self.copyWith(title: value));
  });
}
}


/// @nodoc
mixin _$LocalizedTextModel {

 String get ru; String get en; String get it; String get ga;
/// Create a copy of LocalizedTextModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocalizedTextModelCopyWith<LocalizedTextModel> get copyWith => _$LocalizedTextModelCopyWithImpl<LocalizedTextModel>(this as LocalizedTextModel, _$identity);

  /// Serializes this LocalizedTextModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocalizedTextModel&&(identical(other.ru, ru) || other.ru == ru)&&(identical(other.en, en) || other.en == en)&&(identical(other.it, it) || other.it == it)&&(identical(other.ga, ga) || other.ga == ga));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ru,en,it,ga);

@override
String toString() {
  return 'LocalizedTextModel(ru: $ru, en: $en, it: $it, ga: $ga)';
}


}

/// @nodoc
abstract mixin class $LocalizedTextModelCopyWith<$Res>  {
  factory $LocalizedTextModelCopyWith(LocalizedTextModel value, $Res Function(LocalizedTextModel) _then) = _$LocalizedTextModelCopyWithImpl;
@useResult
$Res call({
 String ru, String en, String it, String ga
});




}
/// @nodoc
class _$LocalizedTextModelCopyWithImpl<$Res>
    implements $LocalizedTextModelCopyWith<$Res> {
  _$LocalizedTextModelCopyWithImpl(this._self, this._then);

  final LocalizedTextModel _self;
  final $Res Function(LocalizedTextModel) _then;

/// Create a copy of LocalizedTextModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ru = null,Object? en = null,Object? it = null,Object? ga = null,}) {
  return _then(LocalizedTextModel(
ru: null == ru ? _self.ru : ru // ignore: cast_nullable_to_non_nullable
as String,en: null == en ? _self.en : en // ignore: cast_nullable_to_non_nullable
as String,it: null == it ? _self.it : it // ignore: cast_nullable_to_non_nullable
as String,ga: null == ga ? _self.ga : ga // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LocalizedTextModel].
extension LocalizedTextModelPatterns on LocalizedTextModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LocalizedTextModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LocalizedTextModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LocalizedTextModel value)  $default,){
final _that = this;
switch (_that) {
case _LocalizedTextModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LocalizedTextModel value)?  $default,){
final _that = this;
switch (_that) {
case _LocalizedTextModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String ru,  String en,  String it,  String ga)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LocalizedTextModel() when $default != null:
return $default(_that.ru,_that.en,_that.it,_that.ga);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String ru,  String en,  String it,  String ga)  $default,) {final _that = this;
switch (_that) {
case _LocalizedTextModel():
return $default(_that.ru,_that.en,_that.it,_that.ga);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String ru,  String en,  String it,  String ga)?  $default,) {final _that = this;
switch (_that) {
case _LocalizedTextModel() when $default != null:
return $default(_that.ru,_that.en,_that.it,_that.ga);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LocalizedTextModel extends LocalizedTextModel {
  const _LocalizedTextModel({required this.ru, this.en = '', this.it = '', this.ga = ''}): super._();
  factory _LocalizedTextModel.fromJson(Map<String, dynamic> json) => _$LocalizedTextModelFromJson(json);

@override final  String ru;
@override@JsonKey() final  String en;
@override@JsonKey() final  String it;
@override@JsonKey() final  String ga;

/// Create a copy of LocalizedTextModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocalizedTextModelCopyWith<_LocalizedTextModel> get copyWith => __$LocalizedTextModelCopyWithImpl<_LocalizedTextModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LocalizedTextModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LocalizedTextModel&&(identical(other.ru, ru) || other.ru == ru)&&(identical(other.en, en) || other.en == en)&&(identical(other.it, it) || other.it == it)&&(identical(other.ga, ga) || other.ga == ga));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ru,en,it,ga);

@override
String toString() {
  return 'LocalizedTextModel(ru: $ru, en: $en, it: $it, ga: $ga)';
}


}

/// @nodoc
abstract mixin class _$LocalizedTextModelCopyWith<$Res> implements $LocalizedTextModelCopyWith<$Res> {
  factory _$LocalizedTextModelCopyWith(_LocalizedTextModel value, $Res Function(_LocalizedTextModel) _then) = __$LocalizedTextModelCopyWithImpl;
@override @useResult
$Res call({
 String ru, String en, String it, String ga
});




}
/// @nodoc
class __$LocalizedTextModelCopyWithImpl<$Res>
    implements _$LocalizedTextModelCopyWith<$Res> {
  __$LocalizedTextModelCopyWithImpl(this._self, this._then);

  final _LocalizedTextModel _self;
  final $Res Function(_LocalizedTextModel) _then;

/// Create a copy of LocalizedTextModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ru = null,Object? en = null,Object? it = null,Object? ga = null,}) {
  return _then(_LocalizedTextModel(
ru: null == ru ? _self.ru : ru // ignore: cast_nullable_to_non_nullable
as String,en: null == en ? _self.en : en // ignore: cast_nullable_to_non_nullable
as String,it: null == it ? _self.it : it // ignore: cast_nullable_to_non_nullable
as String,ga: null == ga ? _self.ga : ga // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ProjectTagModel {

 ProjectTagModelId get id; String get title;
/// Create a copy of ProjectTagModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectTagModelCopyWith<ProjectTagModel> get copyWith => _$ProjectTagModelCopyWithImpl<ProjectTagModel>(this as ProjectTagModel, _$identity);

  /// Serializes this ProjectTagModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectTagModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title);

@override
String toString() {
  return 'ProjectTagModel(id: $id, title: $title)';
}


}

/// @nodoc
abstract mixin class $ProjectTagModelCopyWith<$Res>  {
  factory $ProjectTagModelCopyWith(ProjectTagModel value, $Res Function(ProjectTagModel) _then) = _$ProjectTagModelCopyWithImpl;
@useResult
$Res call({
 ProjectTagModelId id, String title
});




}
/// @nodoc
class _$ProjectTagModelCopyWithImpl<$Res>
    implements $ProjectTagModelCopyWith<$Res> {
  _$ProjectTagModelCopyWithImpl(this._self, this._then);

  final ProjectTagModel _self;
  final $Res Function(ProjectTagModel) _then;

/// Create a copy of ProjectTagModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,}) {
  return _then(ProjectTagModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as ProjectTagModelId,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ProjectTagModel].
extension ProjectTagModelPatterns on ProjectTagModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProjectTagModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProjectTagModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProjectTagModel value)  $default,){
final _that = this;
switch (_that) {
case _ProjectTagModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProjectTagModel value)?  $default,){
final _that = this;
switch (_that) {
case _ProjectTagModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ProjectTagModelId id,  String title)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProjectTagModel() when $default != null:
return $default(_that.id,_that.title);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ProjectTagModelId id,  String title)  $default,) {final _that = this;
switch (_that) {
case _ProjectTagModel():
return $default(_that.id,_that.title);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ProjectTagModelId id,  String title)?  $default,) {final _that = this;
switch (_that) {
case _ProjectTagModel() when $default != null:
return $default(_that.id,_that.title);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProjectTagModel extends ProjectTagModel {
  const _ProjectTagModel({required this.id, this.title = ''}): super._();
  factory _ProjectTagModel.fromJson(Map<String, dynamic> json) => _$ProjectTagModelFromJson(json);

@override final  ProjectTagModelId id;
@override@JsonKey() final  String title;

/// Create a copy of ProjectTagModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProjectTagModelCopyWith<_ProjectTagModel> get copyWith => __$ProjectTagModelCopyWithImpl<_ProjectTagModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProjectTagModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProjectTagModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title);

@override
String toString() {
  return 'ProjectTagModel(id: $id, title: $title)';
}


}

/// @nodoc
abstract mixin class _$ProjectTagModelCopyWith<$Res> implements $ProjectTagModelCopyWith<$Res> {
  factory _$ProjectTagModelCopyWith(_ProjectTagModel value, $Res Function(_ProjectTagModel) _then) = __$ProjectTagModelCopyWithImpl;
@override @useResult
$Res call({
 ProjectTagModelId id, String title
});




}
/// @nodoc
class __$ProjectTagModelCopyWithImpl<$Res>
    implements _$ProjectTagModelCopyWith<$Res> {
  __$ProjectTagModelCopyWithImpl(this._self, this._then);

  final _ProjectTagModel _self;
  final $Res Function(_ProjectTagModel) _then;

/// Create a copy of ProjectTagModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,}) {
  return _then(_ProjectTagModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as ProjectTagModelId,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$DbSaveModel {

 DbSaveVersion get version; List<ProjectModel> get projects; List<ProjectTagModel> get tags;
/// Create a copy of DbSaveModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DbSaveModelCopyWith<DbSaveModel> get copyWith => _$DbSaveModelCopyWithImpl<DbSaveModel>(this as DbSaveModel, _$identity);

  /// Serializes this DbSaveModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DbSaveModel&&(identical(other.version, version) || other.version == version)&&const DeepCollectionEquality().equals(other.projects, projects)&&const DeepCollectionEquality().equals(other.tags, tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version,const DeepCollectionEquality().hash(projects),const DeepCollectionEquality().hash(tags));

@override
String toString() {
  return 'DbSaveModel(version: $version, projects: $projects, tags: $tags)';
}


}

/// @nodoc
abstract mixin class $DbSaveModelCopyWith<$Res>  {
  factory $DbSaveModelCopyWith(DbSaveModel value, $Res Function(DbSaveModel) _then) = _$DbSaveModelCopyWithImpl;
@useResult
$Res call({
 DbSaveVersion version, List<ProjectModel> projects, List<ProjectTagModel> tags
});




}
/// @nodoc
class _$DbSaveModelCopyWithImpl<$Res>
    implements $DbSaveModelCopyWith<$Res> {
  _$DbSaveModelCopyWithImpl(this._self, this._then);

  final DbSaveModel _self;
  final $Res Function(DbSaveModel) _then;

/// Create a copy of DbSaveModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? version = null,Object? projects = null,Object? tags = null,}) {
  return _then(DbSaveModel(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as DbSaveVersion,projects: null == projects ? _self.projects : projects // ignore: cast_nullable_to_non_nullable
as List<ProjectModel>,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<ProjectTagModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [DbSaveModel].
extension DbSaveModelPatterns on DbSaveModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DbSaveModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DbSaveModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DbSaveModel value)  $default,){
final _that = this;
switch (_that) {
case _DbSaveModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DbSaveModel value)?  $default,){
final _that = this;
switch (_that) {
case _DbSaveModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DbSaveVersion version,  List<ProjectModel> projects,  List<ProjectTagModel> tags)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DbSaveModel() when $default != null:
return $default(_that.version,_that.projects,_that.tags);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DbSaveVersion version,  List<ProjectModel> projects,  List<ProjectTagModel> tags)  $default,) {final _that = this;
switch (_that) {
case _DbSaveModel():
return $default(_that.version,_that.projects,_that.tags);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DbSaveVersion version,  List<ProjectModel> projects,  List<ProjectTagModel> tags)?  $default,) {final _that = this;
switch (_that) {
case _DbSaveModel() when $default != null:
return $default(_that.version,_that.projects,_that.tags);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DbSaveModel extends DbSaveModel {
  const _DbSaveModel({this.version = DbSaveVersion.v1,  List<ProjectModel> projects = const [],  List<ProjectTagModel> tags = const []}): _projects = projects,_tags = tags,super._();
  factory _DbSaveModel.fromJson(Map<String, dynamic> json) => _$DbSaveModelFromJson(json);

@override@JsonKey() final  DbSaveVersion version;
 final  List<ProjectModel> _projects;
@override@JsonKey() List<ProjectModel> get projects {
  if (_projects is EqualUnmodifiableListView) return _projects;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_projects);
}

 final  List<ProjectTagModel> _tags;
@override@JsonKey() List<ProjectTagModel> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}


/// Create a copy of DbSaveModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DbSaveModelCopyWith<_DbSaveModel> get copyWith => __$DbSaveModelCopyWithImpl<_DbSaveModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DbSaveModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DbSaveModel&&(identical(other.version, version) || other.version == version)&&const DeepCollectionEquality().equals(other._projects, _projects)&&const DeepCollectionEquality().equals(other._tags, _tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version,const DeepCollectionEquality().hash(_projects),const DeepCollectionEquality().hash(_tags));

@override
String toString() {
  return 'DbSaveModel(version: $version, projects: $projects, tags: $tags)';
}


}

/// @nodoc
abstract mixin class _$DbSaveModelCopyWith<$Res> implements $DbSaveModelCopyWith<$Res> {
  factory _$DbSaveModelCopyWith(_DbSaveModel value, $Res Function(_DbSaveModel) _then) = __$DbSaveModelCopyWithImpl;
@override @useResult
$Res call({
 DbSaveVersion version, List<ProjectModel> projects, List<ProjectTagModel> tags
});




}
/// @nodoc
class __$DbSaveModelCopyWithImpl<$Res>
    implements _$DbSaveModelCopyWith<$Res> {
  __$DbSaveModelCopyWithImpl(this._self, this._then);

  final _DbSaveModel _self;
  final $Res Function(_DbSaveModel) _then;

/// Create a copy of DbSaveModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? version = null,Object? projects = null,Object? tags = null,}) {
  return _then(_DbSaveModel(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as DbSaveVersion,projects: null == projects ? _self._projects : projects // ignore: cast_nullable_to_non_nullable
as List<ProjectModel>,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<ProjectTagModel>,
  ));
}


}


/// @nodoc
mixin _$UserModel {

 UserSettingsModel get settings; LocalDbVersion get localDbVersion; bool get hasCompletedOnboarding;
/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserModelCopyWith<UserModel> get copyWith => _$UserModelCopyWithImpl<UserModel>(this as UserModel, _$identity);

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserModel&&(identical(other.settings, settings) || other.settings == settings)&&(identical(other.localDbVersion, localDbVersion) || other.localDbVersion == localDbVersion)&&(identical(other.hasCompletedOnboarding, hasCompletedOnboarding) || other.hasCompletedOnboarding == hasCompletedOnboarding));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,settings,localDbVersion,hasCompletedOnboarding);

@override
String toString() {
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

class _UserModel implements UserModel {
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
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserModel&&(identical(other.settings, settings) || other.settings == settings)&&(identical(other.localDbVersion, localDbVersion) || other.localDbVersion == localDbVersion)&&(identical(other.hasCompletedOnboarding, hasCompletedOnboarding) || other.hasCompletedOnboarding == hasCompletedOnboarding));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,settings,localDbVersion,hasCompletedOnboarding);

@override
String toString() {
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
mixin _$UserSettingsModel {

@JsonKey(fromJson: _themeModeFromJson, toJson: _themeModeToJson) ThemeMode get themeMode; bool get isProjectsListReversed; int get charactersLimitForNewNotes;@JsonKey(fromJson: _localeFromJson, toJson: _localeToJson) Locale? get locale; bool get useTimestampForBackupFilename; bool get isSocialNetworksRestricted;
/// Create a copy of UserSettingsModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserSettingsModelCopyWith<UserSettingsModel> get copyWith => _$UserSettingsModelCopyWithImpl<UserSettingsModel>(this as UserSettingsModel, _$identity);

  /// Serializes this UserSettingsModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserSettingsModel&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.isProjectsListReversed, isProjectsListReversed) || other.isProjectsListReversed == isProjectsListReversed)&&(identical(other.charactersLimitForNewNotes, charactersLimitForNewNotes) || other.charactersLimitForNewNotes == charactersLimitForNewNotes)&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.useTimestampForBackupFilename, useTimestampForBackupFilename) || other.useTimestampForBackupFilename == useTimestampForBackupFilename)&&(identical(other.isSocialNetworksRestricted, isSocialNetworksRestricted) || other.isSocialNetworksRestricted == isSocialNetworksRestricted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,themeMode,isProjectsListReversed,charactersLimitForNewNotes,locale,useTimestampForBackupFilename,isSocialNetworksRestricted);

@override
String toString() {
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

class _UserSettingsModel implements UserSettingsModel {
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
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserSettingsModel&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.isProjectsListReversed, isProjectsListReversed) || other.isProjectsListReversed == isProjectsListReversed)&&(identical(other.charactersLimitForNewNotes, charactersLimitForNewNotes) || other.charactersLimitForNewNotes == charactersLimitForNewNotes)&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.useTimestampForBackupFilename, useTimestampForBackupFilename) || other.useTimestampForBackupFilename == useTimestampForBackupFilename)&&(identical(other.isSocialNetworksRestricted, isSocialNetworksRestricted) || other.isSocialNetworksRestricted == isSocialNetworksRestricted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,themeMode,isProjectsListReversed,charactersLimitForNewNotes,locale,useTimestampForBackupFilename,isSocialNetworksRestricted);

@override
String toString() {
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
