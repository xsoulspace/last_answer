// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

AppRouteParameters _$AppRouteParametersFromJson(Map<String, dynamic> json) {
  return _AppRouteParameters.fromJson(json);
}

/// @nodoc
mixin _$AppRouteParameters {
  String get noteId => throw _privateConstructorUsedError;
  String get ideaId => throw _privateConstructorUsedError;
  String get answerId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AppRouteParametersCopyWith<AppRouteParameters> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppRouteParametersCopyWith<$Res> {
  factory $AppRouteParametersCopyWith(
          AppRouteParameters value, $Res Function(AppRouteParameters) then) =
      _$AppRouteParametersCopyWithImpl<$Res>;
  $Res call({String noteId, String ideaId, String answerId});
}

/// @nodoc
class _$AppRouteParametersCopyWithImpl<$Res>
    implements $AppRouteParametersCopyWith<$Res> {
  _$AppRouteParametersCopyWithImpl(this._value, this._then);

  final AppRouteParameters _value;
  // ignore: unused_field
  final $Res Function(AppRouteParameters) _then;

  @override
  $Res call({
    Object? noteId = freezed,
    Object? ideaId = freezed,
    Object? answerId = freezed,
  }) {
    return _then(_value.copyWith(
      noteId: noteId == freezed
          ? _value.noteId
          : noteId // ignore: cast_nullable_to_non_nullable
              as String,
      ideaId: ideaId == freezed
          ? _value.ideaId
          : ideaId // ignore: cast_nullable_to_non_nullable
              as String,
      answerId: answerId == freezed
          ? _value.answerId
          : answerId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
abstract class _$$_AppRouteParametersCopyWith<$Res>
    implements $AppRouteParametersCopyWith<$Res> {
  factory _$$_AppRouteParametersCopyWith(_$_AppRouteParameters value,
          $Res Function(_$_AppRouteParameters) then) =
      __$$_AppRouteParametersCopyWithImpl<$Res>;
  @override
  $Res call({String noteId, String ideaId, String answerId});
}

/// @nodoc
class __$$_AppRouteParametersCopyWithImpl<$Res>
    extends _$AppRouteParametersCopyWithImpl<$Res>
    implements _$$_AppRouteParametersCopyWith<$Res> {
  __$$_AppRouteParametersCopyWithImpl(
      _$_AppRouteParameters _value, $Res Function(_$_AppRouteParameters) _then)
      : super(_value, (v) => _then(v as _$_AppRouteParameters));

  @override
  _$_AppRouteParameters get _value => super._value as _$_AppRouteParameters;

  @override
  $Res call({
    Object? noteId = freezed,
    Object? ideaId = freezed,
    Object? answerId = freezed,
  }) {
    return _then(_$_AppRouteParameters(
      noteId: noteId == freezed
          ? _value.noteId
          : noteId // ignore: cast_nullable_to_non_nullable
              as String,
      ideaId: ideaId == freezed
          ? _value.ideaId
          : ideaId // ignore: cast_nullable_to_non_nullable
              as String,
      answerId: answerId == freezed
          ? _value.answerId
          : answerId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$_AppRouteParameters implements _AppRouteParameters {
  const _$_AppRouteParameters(
      {this.noteId = '', this.ideaId = '', this.answerId = ''});

  factory _$_AppRouteParameters.fromJson(Map<String, dynamic> json) =>
      _$$_AppRouteParametersFromJson(json);

  @override
  @JsonKey()
  final String noteId;
  @override
  @JsonKey()
  final String ideaId;
  @override
  @JsonKey()
  final String answerId;

  @override
  String toString() {
    return 'AppRouteParameters(noteId: $noteId, ideaId: $ideaId, answerId: $answerId)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_AppRouteParameters &&
            const DeepCollectionEquality().equals(other.noteId, noteId) &&
            const DeepCollectionEquality().equals(other.ideaId, ideaId) &&
            const DeepCollectionEquality().equals(other.answerId, answerId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(noteId),
      const DeepCollectionEquality().hash(ideaId),
      const DeepCollectionEquality().hash(answerId));

  @JsonKey(ignore: true)
  @override
  _$$_AppRouteParametersCopyWith<_$_AppRouteParameters> get copyWith =>
      __$$_AppRouteParametersCopyWithImpl<_$_AppRouteParameters>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_AppRouteParametersToJson(
      this,
    );
  }
}

abstract class _AppRouteParameters implements AppRouteParameters {
  const factory _AppRouteParameters(
      {final String noteId,
      final String ideaId,
      final String answerId}) = _$_AppRouteParameters;

  factory _AppRouteParameters.fromJson(Map<String, dynamic> json) =
      _$_AppRouteParameters.fromJson;

  @override
  String get noteId;
  @override
  String get ideaId;
  @override
  String get answerId;
  @override
  @JsonKey(ignore: true)
  _$$_AppRouteParametersCopyWith<_$_AppRouteParameters> get copyWith =>
      throw _privateConstructorUsedError;
}
