// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'projects_notifier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
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

// dart format on
