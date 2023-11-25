// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'answer_creator.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$AnswerCreatorControllerState {
  IdeaProjectQuestionModel get question => throw _privateConstructorUsedError;
  bool get isQuestionsOpened => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $AnswerCreatorControllerStateCopyWith<AnswerCreatorControllerState>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnswerCreatorControllerStateCopyWith<$Res> {
  factory $AnswerCreatorControllerStateCopyWith(
          AnswerCreatorControllerState value,
          $Res Function(AnswerCreatorControllerState) then) =
      _$AnswerCreatorControllerStateCopyWithImpl<$Res,
          AnswerCreatorControllerState>;
  @useResult
  $Res call({IdeaProjectQuestionModel question, bool isQuestionsOpened});

  $IdeaProjectQuestionModelCopyWith<$Res> get question;
}

/// @nodoc
class _$AnswerCreatorControllerStateCopyWithImpl<$Res,
        $Val extends AnswerCreatorControllerState>
    implements $AnswerCreatorControllerStateCopyWith<$Res> {
  _$AnswerCreatorControllerStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? question = null,
    Object? isQuestionsOpened = null,
  }) {
    return _then(_value.copyWith(
      question: null == question
          ? _value.question
          : question // ignore: cast_nullable_to_non_nullable
              as IdeaProjectQuestionModel,
      isQuestionsOpened: null == isQuestionsOpened
          ? _value.isQuestionsOpened
          : isQuestionsOpened // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $IdeaProjectQuestionModelCopyWith<$Res> get question {
    return $IdeaProjectQuestionModelCopyWith<$Res>(_value.question, (value) {
      return _then(_value.copyWith(question: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AnswerCreatorControllerStateImplCopyWith<$Res>
    implements $AnswerCreatorControllerStateCopyWith<$Res> {
  factory _$$AnswerCreatorControllerStateImplCopyWith(
          _$AnswerCreatorControllerStateImpl value,
          $Res Function(_$AnswerCreatorControllerStateImpl) then) =
      __$$AnswerCreatorControllerStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({IdeaProjectQuestionModel question, bool isQuestionsOpened});

  @override
  $IdeaProjectQuestionModelCopyWith<$Res> get question;
}

/// @nodoc
class __$$AnswerCreatorControllerStateImplCopyWithImpl<$Res>
    extends _$AnswerCreatorControllerStateCopyWithImpl<$Res,
        _$AnswerCreatorControllerStateImpl>
    implements _$$AnswerCreatorControllerStateImplCopyWith<$Res> {
  __$$AnswerCreatorControllerStateImplCopyWithImpl(
      _$AnswerCreatorControllerStateImpl _value,
      $Res Function(_$AnswerCreatorControllerStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? question = null,
    Object? isQuestionsOpened = null,
  }) {
    return _then(_$AnswerCreatorControllerStateImpl(
      question: null == question
          ? _value.question
          : question // ignore: cast_nullable_to_non_nullable
              as IdeaProjectQuestionModel,
      isQuestionsOpened: null == isQuestionsOpened
          ? _value.isQuestionsOpened
          : isQuestionsOpened // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$AnswerCreatorControllerStateImpl
    implements _AnswerCreatorControllerState {
  const _$AnswerCreatorControllerStateImpl(
      {required this.question, this.isQuestionsOpened = false});

  @override
  final IdeaProjectQuestionModel question;
  @override
  @JsonKey()
  final bool isQuestionsOpened;

  @override
  String toString() {
    return 'AnswerCreatorControllerState(question: $question, isQuestionsOpened: $isQuestionsOpened)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnswerCreatorControllerStateImpl &&
            (identical(other.question, question) ||
                other.question == question) &&
            (identical(other.isQuestionsOpened, isQuestionsOpened) ||
                other.isQuestionsOpened == isQuestionsOpened));
  }

  @override
  int get hashCode => Object.hash(runtimeType, question, isQuestionsOpened);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AnswerCreatorControllerStateImplCopyWith<
          _$AnswerCreatorControllerStateImpl>
      get copyWith => __$$AnswerCreatorControllerStateImplCopyWithImpl<
          _$AnswerCreatorControllerStateImpl>(this, _$identity);
}

abstract class _AnswerCreatorControllerState
    implements AnswerCreatorControllerState {
  const factory _AnswerCreatorControllerState(
      {required final IdeaProjectQuestionModel question,
      final bool isQuestionsOpened}) = _$AnswerCreatorControllerStateImpl;

  @override
  IdeaProjectQuestionModel get question;
  @override
  bool get isQuestionsOpened;
  @override
  @JsonKey(ignore: true)
  _$$AnswerCreatorControllerStateImplCopyWith<
          _$AnswerCreatorControllerStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
