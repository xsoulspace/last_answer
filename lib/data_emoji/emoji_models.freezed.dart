// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'emoji_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EmojiModel {

 String get category; String get emoji; String get keywords;
/// Create a copy of EmojiModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmojiModelCopyWith<EmojiModel> get copyWith => _$EmojiModelCopyWithImpl<EmojiModel>(this as EmojiModel, _$identity);

  /// Serializes this EmojiModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmojiModel&&(identical(other.category, category) || other.category == category)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.keywords, keywords) || other.keywords == keywords));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,category,emoji,keywords);

@override
String toString() {
  return 'EmojiModel(category: $category, emoji: $emoji, keywords: $keywords)';
}


}

/// @nodoc
abstract mixin class $EmojiModelCopyWith<$Res>  {
  factory $EmojiModelCopyWith(EmojiModel value, $Res Function(EmojiModel) _then) = _$EmojiModelCopyWithImpl;
@useResult
$Res call({
 String category, String emoji, String keywords
});




}
/// @nodoc
class _$EmojiModelCopyWithImpl<$Res>
    implements $EmojiModelCopyWith<$Res> {
  _$EmojiModelCopyWithImpl(this._self, this._then);

  final EmojiModel _self;
  final $Res Function(EmojiModel) _then;

/// Create a copy of EmojiModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? category = null,Object? emoji = null,Object? keywords = null,}) {
  return _then(EmojiModel(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,keywords: null == keywords ? _self.keywords : keywords // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [EmojiModel].
extension EmojiModelPatterns on EmojiModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EmojiModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EmojiModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EmojiModel value)  $default,){
final _that = this;
switch (_that) {
case _EmojiModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EmojiModel value)?  $default,){
final _that = this;
switch (_that) {
case _EmojiModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String category,  String emoji,  String keywords)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EmojiModel() when $default != null:
return $default(_that.category,_that.emoji,_that.keywords);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String category,  String emoji,  String keywords)  $default,) {final _that = this;
switch (_that) {
case _EmojiModel():
return $default(_that.category,_that.emoji,_that.keywords);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String category,  String emoji,  String keywords)?  $default,) {final _that = this;
switch (_that) {
case _EmojiModel() when $default != null:
return $default(_that.category,_that.emoji,_that.keywords);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EmojiModel extends EmojiModel {
  const _EmojiModel({required this.category, required this.emoji, required this.keywords}): super._();
  factory _EmojiModel.fromJson(Map<String, dynamic> json) => _$EmojiModelFromJson(json);

@override final  String category;
@override final  String emoji;
@override final  String keywords;

/// Create a copy of EmojiModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmojiModelCopyWith<_EmojiModel> get copyWith => __$EmojiModelCopyWithImpl<_EmojiModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EmojiModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmojiModel&&(identical(other.category, category) || other.category == category)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.keywords, keywords) || other.keywords == keywords));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,category,emoji,keywords);

@override
String toString() {
  return 'EmojiModel(category: $category, emoji: $emoji, keywords: $keywords)';
}


}

/// @nodoc
abstract mixin class _$EmojiModelCopyWith<$Res> implements $EmojiModelCopyWith<$Res> {
  factory _$EmojiModelCopyWith(_EmojiModel value, $Res Function(_EmojiModel) _then) = __$EmojiModelCopyWithImpl;
@override @useResult
$Res call({
 String category, String emoji, String keywords
});




}
/// @nodoc
class __$EmojiModelCopyWithImpl<$Res>
    implements _$EmojiModelCopyWith<$Res> {
  __$EmojiModelCopyWithImpl(this._self, this._then);

  final _EmojiModel _self;
  final $Res Function(_EmojiModel) _then;

/// Create a copy of EmojiModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? category = null,Object? emoji = null,Object? keywords = null,}) {
  return _then(_EmojiModel(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,keywords: null == keywords ? _self.keywords : keywords // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
