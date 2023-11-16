// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$GetProjectsDto {
  ProjectTypes get type => throw _privateConstructorUsedError;
  String get search => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $GetProjectsDtoCopyWith<GetProjectsDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetProjectsDtoCopyWith<$Res> {
  factory $GetProjectsDtoCopyWith(
          GetProjectsDto value, $Res Function(GetProjectsDto) then) =
      _$GetProjectsDtoCopyWithImpl<$Res, GetProjectsDto>;
  @useResult
  $Res call({ProjectTypes type, String search});
}

/// @nodoc
class _$GetProjectsDtoCopyWithImpl<$Res, $Val extends GetProjectsDto>
    implements $GetProjectsDtoCopyWith<$Res> {
  _$GetProjectsDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? search = null,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ProjectTypes,
      search: null == search
          ? _value.search
          : search // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GetProjectsDtoImplCopyWith<$Res>
    implements $GetProjectsDtoCopyWith<$Res> {
  factory _$$GetProjectsDtoImplCopyWith(_$GetProjectsDtoImpl value,
          $Res Function(_$GetProjectsDtoImpl) then) =
      __$$GetProjectsDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({ProjectTypes type, String search});
}

/// @nodoc
class __$$GetProjectsDtoImplCopyWithImpl<$Res>
    extends _$GetProjectsDtoCopyWithImpl<$Res, _$GetProjectsDtoImpl>
    implements _$$GetProjectsDtoImplCopyWith<$Res> {
  __$$GetProjectsDtoImplCopyWithImpl(
      _$GetProjectsDtoImpl _value, $Res Function(_$GetProjectsDtoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? search = null,
  }) {
    return _then(_$GetProjectsDtoImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ProjectTypes,
      search: null == search
          ? _value.search
          : search // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$GetProjectsDtoImpl implements _GetProjectsDto {
  const _$GetProjectsDtoImpl({required this.type, this.search = ''});

  @override
  final ProjectTypes type;
  @override
  @JsonKey()
  final String search;

  @override
  String toString() {
    return 'GetProjectsDto(type: $type, search: $search)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetProjectsDtoImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.search, search) || other.search == search));
  }

  @override
  int get hashCode => Object.hash(runtimeType, type, search);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GetProjectsDtoImplCopyWith<_$GetProjectsDtoImpl> get copyWith =>
      __$$GetProjectsDtoImplCopyWithImpl<_$GetProjectsDtoImpl>(
          this, _$identity);
}

abstract class _GetProjectsDto implements GetProjectsDto {
  const factory _GetProjectsDto(
      {required final ProjectTypes type,
      final String search}) = _$GetProjectsDtoImpl;

  @override
  ProjectTypes get type;
  @override
  String get search;
  @override
  @JsonKey(ignore: true)
  _$$GetProjectsDtoImplCopyWith<_$GetProjectsDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
