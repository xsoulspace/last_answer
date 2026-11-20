// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'projects_paged_requests_builder.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
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
