// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'projects_notifier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$ProjectsNotifierState {
  RequestProjectsDto get requestProjectsDto =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ProjectsNotifierStateCopyWith<ProjectsNotifierState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProjectsNotifierStateCopyWith<$Res> {
  factory $ProjectsNotifierStateCopyWith(ProjectsNotifierState value,
          $Res Function(ProjectsNotifierState) then) =
      _$ProjectsNotifierStateCopyWithImpl<$Res, ProjectsNotifierState>;
  @useResult
  $Res call({RequestProjectsDto requestProjectsDto});

  $RequestProjectsDtoCopyWith<$Res> get requestProjectsDto;
}

/// @nodoc
class _$ProjectsNotifierStateCopyWithImpl<$Res,
        $Val extends ProjectsNotifierState>
    implements $ProjectsNotifierStateCopyWith<$Res> {
  _$ProjectsNotifierStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? requestProjectsDto = null,
  }) {
    return _then(_value.copyWith(
      requestProjectsDto: null == requestProjectsDto
          ? _value.requestProjectsDto
          : requestProjectsDto // ignore: cast_nullable_to_non_nullable
              as RequestProjectsDto,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $RequestProjectsDtoCopyWith<$Res> get requestProjectsDto {
    return $RequestProjectsDtoCopyWith<$Res>(_value.requestProjectsDto,
        (value) {
      return _then(_value.copyWith(requestProjectsDto: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ProjectsNotifierStateImplCopyWith<$Res>
    implements $ProjectsNotifierStateCopyWith<$Res> {
  factory _$$ProjectsNotifierStateImplCopyWith(
          _$ProjectsNotifierStateImpl value,
          $Res Function(_$ProjectsNotifierStateImpl) then) =
      __$$ProjectsNotifierStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({RequestProjectsDto requestProjectsDto});

  @override
  $RequestProjectsDtoCopyWith<$Res> get requestProjectsDto;
}

/// @nodoc
class __$$ProjectsNotifierStateImplCopyWithImpl<$Res>
    extends _$ProjectsNotifierStateCopyWithImpl<$Res,
        _$ProjectsNotifierStateImpl>
    implements _$$ProjectsNotifierStateImplCopyWith<$Res> {
  __$$ProjectsNotifierStateImplCopyWithImpl(_$ProjectsNotifierStateImpl _value,
      $Res Function(_$ProjectsNotifierStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? requestProjectsDto = null,
  }) {
    return _then(_$ProjectsNotifierStateImpl(
      requestProjectsDto: null == requestProjectsDto
          ? _value.requestProjectsDto
          : requestProjectsDto // ignore: cast_nullable_to_non_nullable
              as RequestProjectsDto,
    ));
  }
}

/// @nodoc

class _$ProjectsNotifierStateImpl implements _ProjectsNotifierState {
  const _$ProjectsNotifierStateImpl(
      {this.requestProjectsDto = RequestProjectsDto.empty});

  @override
  @JsonKey()
  final RequestProjectsDto requestProjectsDto;

  @override
  String toString() {
    return 'ProjectsNotifierState(requestProjectsDto: $requestProjectsDto)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProjectsNotifierStateImpl &&
            (identical(other.requestProjectsDto, requestProjectsDto) ||
                other.requestProjectsDto == requestProjectsDto));
  }

  @override
  int get hashCode => Object.hash(runtimeType, requestProjectsDto);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ProjectsNotifierStateImplCopyWith<_$ProjectsNotifierStateImpl>
      get copyWith => __$$ProjectsNotifierStateImplCopyWithImpl<
          _$ProjectsNotifierStateImpl>(this, _$identity);
}

abstract class _ProjectsNotifierState implements ProjectsNotifierState {
  const factory _ProjectsNotifierState(
          {final RequestProjectsDto requestProjectsDto}) =
      _$ProjectsNotifierStateImpl;

  @override
  RequestProjectsDto get requestProjectsDto;
  @override
  @JsonKey(ignore: true)
  _$$ProjectsNotifierStateImplCopyWith<_$ProjectsNotifierStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
