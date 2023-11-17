// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'global_state_notifier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$GlobalStateNotifierState {
  Map<String, IdeaProjectQuestionModel> get ideaProjectQuestions =>
      throw _privateConstructorUsedError;
  RequestProjectsDto get requestProjectsDto =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $GlobalStateNotifierStateCopyWith<GlobalStateNotifierState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GlobalStateNotifierStateCopyWith<$Res> {
  factory $GlobalStateNotifierStateCopyWith(GlobalStateNotifierState value,
          $Res Function(GlobalStateNotifierState) then) =
      _$GlobalStateNotifierStateCopyWithImpl<$Res, GlobalStateNotifierState>;
  @useResult
  $Res call(
      {Map<String, IdeaProjectQuestionModel> ideaProjectQuestions,
      RequestProjectsDto requestProjectsDto});

  $RequestProjectsDtoCopyWith<$Res> get requestProjectsDto;
}

/// @nodoc
class _$GlobalStateNotifierStateCopyWithImpl<$Res,
        $Val extends GlobalStateNotifierState>
    implements $GlobalStateNotifierStateCopyWith<$Res> {
  _$GlobalStateNotifierStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ideaProjectQuestions = null,
    Object? requestProjectsDto = null,
  }) {
    return _then(_value.copyWith(
      ideaProjectQuestions: null == ideaProjectQuestions
          ? _value.ideaProjectQuestions
          : ideaProjectQuestions // ignore: cast_nullable_to_non_nullable
              as Map<String, IdeaProjectQuestionModel>,
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
abstract class _$$GlobalStateNotifierStateImplCopyWith<$Res>
    implements $GlobalStateNotifierStateCopyWith<$Res> {
  factory _$$GlobalStateNotifierStateImplCopyWith(
          _$GlobalStateNotifierStateImpl value,
          $Res Function(_$GlobalStateNotifierStateImpl) then) =
      __$$GlobalStateNotifierStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Map<String, IdeaProjectQuestionModel> ideaProjectQuestions,
      RequestProjectsDto requestProjectsDto});

  @override
  $RequestProjectsDtoCopyWith<$Res> get requestProjectsDto;
}

/// @nodoc
class __$$GlobalStateNotifierStateImplCopyWithImpl<$Res>
    extends _$GlobalStateNotifierStateCopyWithImpl<$Res,
        _$GlobalStateNotifierStateImpl>
    implements _$$GlobalStateNotifierStateImplCopyWith<$Res> {
  __$$GlobalStateNotifierStateImplCopyWithImpl(
      _$GlobalStateNotifierStateImpl _value,
      $Res Function(_$GlobalStateNotifierStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ideaProjectQuestions = null,
    Object? requestProjectsDto = null,
  }) {
    return _then(_$GlobalStateNotifierStateImpl(
      ideaProjectQuestions: null == ideaProjectQuestions
          ? _value._ideaProjectQuestions
          : ideaProjectQuestions // ignore: cast_nullable_to_non_nullable
              as Map<String, IdeaProjectQuestionModel>,
      requestProjectsDto: null == requestProjectsDto
          ? _value.requestProjectsDto
          : requestProjectsDto // ignore: cast_nullable_to_non_nullable
              as RequestProjectsDto,
    ));
  }
}

/// @nodoc

class _$GlobalStateNotifierStateImpl implements _GlobalStateNotifierState {
  const _$GlobalStateNotifierStateImpl(
      {final Map<String, IdeaProjectQuestionModel> ideaProjectQuestions =
          const {},
      this.requestProjectsDto = RequestProjectsDto.empty})
      : _ideaProjectQuestions = ideaProjectQuestions;

  final Map<String, IdeaProjectQuestionModel> _ideaProjectQuestions;
  @override
  @JsonKey()
  Map<String, IdeaProjectQuestionModel> get ideaProjectQuestions {
    if (_ideaProjectQuestions is EqualUnmodifiableMapView)
      return _ideaProjectQuestions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_ideaProjectQuestions);
  }

  @override
  @JsonKey()
  final RequestProjectsDto requestProjectsDto;

  @override
  String toString() {
    return 'GlobalStateNotifierState(ideaProjectQuestions: $ideaProjectQuestions, requestProjectsDto: $requestProjectsDto)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GlobalStateNotifierStateImpl &&
            const DeepCollectionEquality()
                .equals(other._ideaProjectQuestions, _ideaProjectQuestions) &&
            (identical(other.requestProjectsDto, requestProjectsDto) ||
                other.requestProjectsDto == requestProjectsDto));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_ideaProjectQuestions),
      requestProjectsDto);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GlobalStateNotifierStateImplCopyWith<_$GlobalStateNotifierStateImpl>
      get copyWith => __$$GlobalStateNotifierStateImplCopyWithImpl<
          _$GlobalStateNotifierStateImpl>(this, _$identity);
}

abstract class _GlobalStateNotifierState implements GlobalStateNotifierState {
  const factory _GlobalStateNotifierState(
          {final Map<String, IdeaProjectQuestionModel> ideaProjectQuestions,
          final RequestProjectsDto requestProjectsDto}) =
      _$GlobalStateNotifierStateImpl;

  @override
  Map<String, IdeaProjectQuestionModel> get ideaProjectQuestions;
  @override
  RequestProjectsDto get requestProjectsDto;
  @override
  @JsonKey(ignore: true)
  _$$GlobalStateNotifierStateImplCopyWith<_$GlobalStateNotifierStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
