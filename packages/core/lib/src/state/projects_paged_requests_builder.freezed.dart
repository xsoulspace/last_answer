// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'projects_paged_requests_builder.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$RequestProjectsDto {
  String get search => throw _privateConstructorUsedError;
  List<ProjectTypes> get types => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $RequestProjectsDtoCopyWith<RequestProjectsDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RequestProjectsDtoCopyWith<$Res> {
  factory $RequestProjectsDtoCopyWith(
          RequestProjectsDto value, $Res Function(RequestProjectsDto) then) =
      _$RequestProjectsDtoCopyWithImpl<$Res, RequestProjectsDto>;
  @useResult
  $Res call({String search, List<ProjectTypes> types});
}

/// @nodoc
class _$RequestProjectsDtoCopyWithImpl<$Res, $Val extends RequestProjectsDto>
    implements $RequestProjectsDtoCopyWith<$Res> {
  _$RequestProjectsDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? search = null,
    Object? types = null,
  }) {
    return _then(_value.copyWith(
      search: null == search
          ? _value.search
          : search // ignore: cast_nullable_to_non_nullable
              as String,
      types: null == types
          ? _value.types
          : types // ignore: cast_nullable_to_non_nullable
              as List<ProjectTypes>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RequestProjectsDtoImplCopyWith<$Res>
    implements $RequestProjectsDtoCopyWith<$Res> {
  factory _$$RequestProjectsDtoImplCopyWith(_$RequestProjectsDtoImpl value,
          $Res Function(_$RequestProjectsDtoImpl) then) =
      __$$RequestProjectsDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String search, List<ProjectTypes> types});
}

/// @nodoc
class __$$RequestProjectsDtoImplCopyWithImpl<$Res>
    extends _$RequestProjectsDtoCopyWithImpl<$Res, _$RequestProjectsDtoImpl>
    implements _$$RequestProjectsDtoImplCopyWith<$Res> {
  __$$RequestProjectsDtoImplCopyWithImpl(_$RequestProjectsDtoImpl _value,
      $Res Function(_$RequestProjectsDtoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? search = null,
    Object? types = null,
  }) {
    return _then(_$RequestProjectsDtoImpl(
      search: null == search
          ? _value.search
          : search // ignore: cast_nullable_to_non_nullable
              as String,
      types: null == types
          ? _value._types
          : types // ignore: cast_nullable_to_non_nullable
              as List<ProjectTypes>,
    ));
  }
}

/// @nodoc

class _$RequestProjectsDtoImpl implements _RequestProjectsDto {
  const _$RequestProjectsDtoImpl(
      {this.search = '', final List<ProjectTypes> types = const []})
      : _types = types;

  @override
  @JsonKey()
  final String search;
  final List<ProjectTypes> _types;
  @override
  @JsonKey()
  List<ProjectTypes> get types {
    if (_types is EqualUnmodifiableListView) return _types;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_types);
  }

  @override
  String toString() {
    return 'RequestProjectsDto(search: $search, types: $types)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RequestProjectsDtoImpl &&
            (identical(other.search, search) || other.search == search) &&
            const DeepCollectionEquality().equals(other._types, _types));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, search, const DeepCollectionEquality().hash(_types));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RequestProjectsDtoImplCopyWith<_$RequestProjectsDtoImpl> get copyWith =>
      __$$RequestProjectsDtoImplCopyWithImpl<_$RequestProjectsDtoImpl>(
          this, _$identity);
}

abstract class _RequestProjectsDto implements RequestProjectsDto {
  const factory _RequestProjectsDto(
      {final String search,
      final List<ProjectTypes> types}) = _$RequestProjectsDtoImpl;

  @override
  String get search;
  @override
  List<ProjectTypes> get types;
  @override
  @JsonKey(ignore: true)
  _$$RequestProjectsDtoImplCopyWith<_$RequestProjectsDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
