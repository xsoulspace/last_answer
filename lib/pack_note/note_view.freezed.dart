// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'note_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$NoteProjectViewBlocState {
  ProjectModelNote get note => throw _privateConstructorUsedError;
  bool get isKeyboardVisible => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $NoteProjectViewBlocStateCopyWith<NoteProjectViewBlocState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NoteProjectViewBlocStateCopyWith<$Res> {
  factory $NoteProjectViewBlocStateCopyWith(NoteProjectViewBlocState value,
          $Res Function(NoteProjectViewBlocState) then) =
      _$NoteProjectViewBlocStateCopyWithImpl<$Res, NoteProjectViewBlocState>;
  @useResult
  $Res call({ProjectModelNote note, bool isKeyboardVisible});
}

/// @nodoc
class _$NoteProjectViewBlocStateCopyWithImpl<$Res,
        $Val extends NoteProjectViewBlocState>
    implements $NoteProjectViewBlocStateCopyWith<$Res> {
  _$NoteProjectViewBlocStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? note = null,
    Object? isKeyboardVisible = null,
  }) {
    return _then(_value.copyWith(
      note: null == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as ProjectModelNote,
      isKeyboardVisible: null == isKeyboardVisible
          ? _value.isKeyboardVisible
          : isKeyboardVisible // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NoteProjectViewBlocStateImplCopyWith<$Res>
    implements $NoteProjectViewBlocStateCopyWith<$Res> {
  factory _$$NoteProjectViewBlocStateImplCopyWith(
          _$NoteProjectViewBlocStateImpl value,
          $Res Function(_$NoteProjectViewBlocStateImpl) then) =
      __$$NoteProjectViewBlocStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({ProjectModelNote note, bool isKeyboardVisible});
}

/// @nodoc
class __$$NoteProjectViewBlocStateImplCopyWithImpl<$Res>
    extends _$NoteProjectViewBlocStateCopyWithImpl<$Res,
        _$NoteProjectViewBlocStateImpl>
    implements _$$NoteProjectViewBlocStateImplCopyWith<$Res> {
  __$$NoteProjectViewBlocStateImplCopyWithImpl(
      _$NoteProjectViewBlocStateImpl _value,
      $Res Function(_$NoteProjectViewBlocStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? note = null,
    Object? isKeyboardVisible = null,
  }) {
    return _then(_$NoteProjectViewBlocStateImpl(
      note: null == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as ProjectModelNote,
      isKeyboardVisible: null == isKeyboardVisible
          ? _value.isKeyboardVisible
          : isKeyboardVisible // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$NoteProjectViewBlocStateImpl implements _NoteProjectViewBlocState {
  const _$NoteProjectViewBlocStateImpl(
      {required this.note, this.isKeyboardVisible = false});

  @override
  final ProjectModelNote note;
  @override
  @JsonKey()
  final bool isKeyboardVisible;

  @override
  String toString() {
    return 'NoteProjectViewBlocState(note: $note, isKeyboardVisible: $isKeyboardVisible)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NoteProjectViewBlocStateImpl &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.isKeyboardVisible, isKeyboardVisible) ||
                other.isKeyboardVisible == isKeyboardVisible));
  }

  @override
  int get hashCode => Object.hash(runtimeType, note, isKeyboardVisible);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NoteProjectViewBlocStateImplCopyWith<_$NoteProjectViewBlocStateImpl>
      get copyWith => __$$NoteProjectViewBlocStateImplCopyWithImpl<
          _$NoteProjectViewBlocStateImpl>(this, _$identity);
}

abstract class _NoteProjectViewBlocState implements NoteProjectViewBlocState {
  const factory _NoteProjectViewBlocState(
      {required final ProjectModelNote note,
      final bool isKeyboardVisible}) = _$NoteProjectViewBlocStateImpl;

  @override
  ProjectModelNote get note;
  @override
  bool get isKeyboardVisible;
  @override
  @JsonKey(ignore: true)
  _$$NoteProjectViewBlocStateImplCopyWith<_$NoteProjectViewBlocStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
