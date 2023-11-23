// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'idea_view_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$IdeaViewBlocState {
  ProjectModelIdea get idea => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $IdeaViewBlocStateCopyWith<IdeaViewBlocState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IdeaViewBlocStateCopyWith<$Res> {
  factory $IdeaViewBlocStateCopyWith(
          IdeaViewBlocState value, $Res Function(IdeaViewBlocState) then) =
      _$IdeaViewBlocStateCopyWithImpl<$Res, IdeaViewBlocState>;
  @useResult
  $Res call({ProjectModelIdea idea});
}

/// @nodoc
class _$IdeaViewBlocStateCopyWithImpl<$Res, $Val extends IdeaViewBlocState>
    implements $IdeaViewBlocStateCopyWith<$Res> {
  _$IdeaViewBlocStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? idea = null,
  }) {
    return _then(_value.copyWith(
      idea: null == idea
          ? _value.idea
          : idea // ignore: cast_nullable_to_non_nullable
              as ProjectModelIdea,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$IdeaViewBlocStateImplCopyWith<$Res>
    implements $IdeaViewBlocStateCopyWith<$Res> {
  factory _$$IdeaViewBlocStateImplCopyWith(_$IdeaViewBlocStateImpl value,
          $Res Function(_$IdeaViewBlocStateImpl) then) =
      __$$IdeaViewBlocStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({ProjectModelIdea idea});
}

/// @nodoc
class __$$IdeaViewBlocStateImplCopyWithImpl<$Res>
    extends _$IdeaViewBlocStateCopyWithImpl<$Res, _$IdeaViewBlocStateImpl>
    implements _$$IdeaViewBlocStateImplCopyWith<$Res> {
  __$$IdeaViewBlocStateImplCopyWithImpl(_$IdeaViewBlocStateImpl _value,
      $Res Function(_$IdeaViewBlocStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? idea = null,
  }) {
    return _then(_$IdeaViewBlocStateImpl(
      idea: null == idea
          ? _value.idea
          : idea // ignore: cast_nullable_to_non_nullable
              as ProjectModelIdea,
    ));
  }
}

/// @nodoc

class _$IdeaViewBlocStateImpl implements _IdeaViewBlocState {
  const _$IdeaViewBlocStateImpl({required this.idea});

  @override
  final ProjectModelIdea idea;

  @override
  String toString() {
    return 'IdeaViewBlocState(idea: $idea)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IdeaViewBlocStateImpl &&
            (identical(other.idea, idea) || other.idea == idea));
  }

  @override
  int get hashCode => Object.hash(runtimeType, idea);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$IdeaViewBlocStateImplCopyWith<_$IdeaViewBlocStateImpl> get copyWith =>
      __$$IdeaViewBlocStateImplCopyWithImpl<_$IdeaViewBlocStateImpl>(
          this, _$identity);
}

abstract class _IdeaViewBlocState implements IdeaViewBlocState {
  const factory _IdeaViewBlocState({required final ProjectModelIdea idea}) =
      _$IdeaViewBlocStateImpl;

  @override
  ProjectModelIdea get idea;
  @override
  @JsonKey(ignore: true)
  _$$IdeaViewBlocStateImplCopyWith<_$IdeaViewBlocStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
