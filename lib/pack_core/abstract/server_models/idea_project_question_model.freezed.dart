// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'idea_project_question_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

IdeaProjectQuestionModel _$IdeaProjectQuestionModelFromJson(
    Map<String, dynamic> json) {
  return _IdeaProjectQuestionModel.fromJson(json);
}

/// @nodoc
mixin _$IdeaProjectQuestionModel {
  @JsonKey(fromJson: fromIntToString, toJson: fromStringToInt)
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $IdeaProjectQuestionModelCopyWith<IdeaProjectQuestionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IdeaProjectQuestionModelCopyWith<$Res> {
  factory $IdeaProjectQuestionModelCopyWith(IdeaProjectQuestionModel value,
          $Res Function(IdeaProjectQuestionModel) then) =
      _$IdeaProjectQuestionModelCopyWithImpl<$Res>;
  $Res call(
      {@JsonKey(fromJson: fromIntToString, toJson: fromStringToInt) String id,
      String title});
}

/// @nodoc
class _$IdeaProjectQuestionModelCopyWithImpl<$Res>
    implements $IdeaProjectQuestionModelCopyWith<$Res> {
  _$IdeaProjectQuestionModelCopyWithImpl(this._value, this._then);

  final IdeaProjectQuestionModel _value;
  // ignore: unused_field
  final $Res Function(IdeaProjectQuestionModel) _then;

  @override
  $Res call({
    Object? id = freezed,
    Object? title = freezed,
  }) {
    return _then(_value.copyWith(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: title == freezed
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
abstract class _$$_IdeaProjectQuestionModelCopyWith<$Res>
    implements $IdeaProjectQuestionModelCopyWith<$Res> {
  factory _$$_IdeaProjectQuestionModelCopyWith(
          _$_IdeaProjectQuestionModel value,
          $Res Function(_$_IdeaProjectQuestionModel) then) =
      __$$_IdeaProjectQuestionModelCopyWithImpl<$Res>;
  @override
  $Res call(
      {@JsonKey(fromJson: fromIntToString, toJson: fromStringToInt) String id,
      String title});
}

/// @nodoc
class __$$_IdeaProjectQuestionModelCopyWithImpl<$Res>
    extends _$IdeaProjectQuestionModelCopyWithImpl<$Res>
    implements _$$_IdeaProjectQuestionModelCopyWith<$Res> {
  __$$_IdeaProjectQuestionModelCopyWithImpl(_$_IdeaProjectQuestionModel _value,
      $Res Function(_$_IdeaProjectQuestionModel) _then)
      : super(_value, (v) => _then(v as _$_IdeaProjectQuestionModel));

  @override
  _$_IdeaProjectQuestionModel get _value =>
      super._value as _$_IdeaProjectQuestionModel;

  @override
  $Res call({
    Object? id = freezed,
    Object? title = freezed,
  }) {
    return _then(_$_IdeaProjectQuestionModel(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: title == freezed
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$_IdeaProjectQuestionModel extends _IdeaProjectQuestionModel {
  const _$_IdeaProjectQuestionModel(
      {@JsonKey(fromJson: fromIntToString, toJson: fromStringToInt)
          required this.id,
      required this.title})
      : super._();

  factory _$_IdeaProjectQuestionModel.fromJson(Map<String, dynamic> json) =>
      _$$_IdeaProjectQuestionModelFromJson(json);

  @override
  @JsonKey(fromJson: fromIntToString, toJson: fromStringToInt)
  final String id;
  @override
  final String title;

  @override
  String toString() {
    return 'IdeaProjectQuestionModel(id: $id, title: $title)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_IdeaProjectQuestionModel &&
            const DeepCollectionEquality().equals(other.id, id) &&
            const DeepCollectionEquality().equals(other.title, title));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(id),
      const DeepCollectionEquality().hash(title));

  @JsonKey(ignore: true)
  @override
  _$$_IdeaProjectQuestionModelCopyWith<_$_IdeaProjectQuestionModel>
      get copyWith => __$$_IdeaProjectQuestionModelCopyWithImpl<
          _$_IdeaProjectQuestionModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_IdeaProjectQuestionModelToJson(this);
  }
}

abstract class _IdeaProjectQuestionModel extends IdeaProjectQuestionModel {
  const factory _IdeaProjectQuestionModel(
      {@JsonKey(fromJson: fromIntToString, toJson: fromStringToInt)
          required final String id,
      required final String title}) = _$_IdeaProjectQuestionModel;
  const _IdeaProjectQuestionModel._() : super._();

  factory _IdeaProjectQuestionModel.fromJson(Map<String, dynamic> json) =
      _$_IdeaProjectQuestionModel.fromJson;

  @override
  @JsonKey(fromJson: fromIntToString, toJson: fromStringToInt)
  String get id => throw _privateConstructorUsedError;
  @override
  String get title => throw _privateConstructorUsedError;
  @override
  @JsonKey(ignore: true)
  _$$_IdeaProjectQuestionModelCopyWith<_$_IdeaProjectQuestionModel>
      get copyWith => throw _privateConstructorUsedError;
}
