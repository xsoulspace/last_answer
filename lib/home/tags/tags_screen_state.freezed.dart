// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tags_screen_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$TagsScreenState {
  FieldContainer<ProjectTagModel> get selectedTag =>
      throw _privateConstructorUsedError;
  LoadableContainer<List<ProjectModel>> get projects =>
      throw _privateConstructorUsedError;
  TagsScreenType get screenType => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $TagsScreenStateCopyWith<TagsScreenState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TagsScreenStateCopyWith<$Res> {
  factory $TagsScreenStateCopyWith(
          TagsScreenState value, $Res Function(TagsScreenState) then) =
      _$TagsScreenStateCopyWithImpl<$Res, TagsScreenState>;
  @useResult
  $Res call(
      {FieldContainer<ProjectTagModel> selectedTag,
      LoadableContainer<List<ProjectModel>> projects,
      TagsScreenType screenType});

  $FieldContainerCopyWith<ProjectTagModel, $Res> get selectedTag;
  $LoadableContainerCopyWith<List<ProjectModel>, $Res> get projects;
}

/// @nodoc
class _$TagsScreenStateCopyWithImpl<$Res, $Val extends TagsScreenState>
    implements $TagsScreenStateCopyWith<$Res> {
  _$TagsScreenStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedTag = null,
    Object? projects = null,
    Object? screenType = null,
  }) {
    return _then(_value.copyWith(
      selectedTag: null == selectedTag
          ? _value.selectedTag
          : selectedTag // ignore: cast_nullable_to_non_nullable
              as FieldContainer<ProjectTagModel>,
      projects: null == projects
          ? _value.projects
          : projects // ignore: cast_nullable_to_non_nullable
              as LoadableContainer<List<ProjectModel>>,
      screenType: null == screenType
          ? _value.screenType
          : screenType // ignore: cast_nullable_to_non_nullable
              as TagsScreenType,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $FieldContainerCopyWith<ProjectTagModel, $Res> get selectedTag {
    return $FieldContainerCopyWith<ProjectTagModel, $Res>(_value.selectedTag,
        (value) {
      return _then(_value.copyWith(selectedTag: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $LoadableContainerCopyWith<List<ProjectModel>, $Res> get projects {
    return $LoadableContainerCopyWith<List<ProjectModel>, $Res>(_value.projects,
        (value) {
      return _then(_value.copyWith(projects: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TagsScreenStateImplCopyWith<$Res>
    implements $TagsScreenStateCopyWith<$Res> {
  factory _$$TagsScreenStateImplCopyWith(_$TagsScreenStateImpl value,
          $Res Function(_$TagsScreenStateImpl) then) =
      __$$TagsScreenStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {FieldContainer<ProjectTagModel> selectedTag,
      LoadableContainer<List<ProjectModel>> projects,
      TagsScreenType screenType});

  @override
  $FieldContainerCopyWith<ProjectTagModel, $Res> get selectedTag;
  @override
  $LoadableContainerCopyWith<List<ProjectModel>, $Res> get projects;
}

/// @nodoc
class __$$TagsScreenStateImplCopyWithImpl<$Res>
    extends _$TagsScreenStateCopyWithImpl<$Res, _$TagsScreenStateImpl>
    implements _$$TagsScreenStateImplCopyWith<$Res> {
  __$$TagsScreenStateImplCopyWithImpl(
      _$TagsScreenStateImpl _value, $Res Function(_$TagsScreenStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedTag = null,
    Object? projects = null,
    Object? screenType = null,
  }) {
    return _then(_$TagsScreenStateImpl(
      selectedTag: null == selectedTag
          ? _value.selectedTag
          : selectedTag // ignore: cast_nullable_to_non_nullable
              as FieldContainer<ProjectTagModel>,
      projects: null == projects
          ? _value.projects
          : projects // ignore: cast_nullable_to_non_nullable
              as LoadableContainer<List<ProjectModel>>,
      screenType: null == screenType
          ? _value.screenType
          : screenType // ignore: cast_nullable_to_non_nullable
              as TagsScreenType,
    ));
  }
}

/// @nodoc

class _$TagsScreenStateImpl implements _TagsScreenState {
  const _$TagsScreenStateImpl(
      {this.selectedTag = const FieldContainer(value: ProjectTagModel.empty),
      this.projects = const LoadableContainer(value: []),
      this.screenType = TagsScreenType.allTags});

  @override
  @JsonKey()
  final FieldContainer<ProjectTagModel> selectedTag;
  @override
  @JsonKey()
  final LoadableContainer<List<ProjectModel>> projects;
  @override
  @JsonKey()
  final TagsScreenType screenType;

  @override
  String toString() {
    return 'TagsScreenState(selectedTag: $selectedTag, projects: $projects, screenType: $screenType)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TagsScreenStateImpl &&
            (identical(other.selectedTag, selectedTag) ||
                other.selectedTag == selectedTag) &&
            (identical(other.projects, projects) ||
                other.projects == projects) &&
            (identical(other.screenType, screenType) ||
                other.screenType == screenType));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, selectedTag, projects, screenType);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TagsScreenStateImplCopyWith<_$TagsScreenStateImpl> get copyWith =>
      __$$TagsScreenStateImplCopyWithImpl<_$TagsScreenStateImpl>(
          this, _$identity);
}

abstract class _TagsScreenState implements TagsScreenState {
  const factory _TagsScreenState(
      {final FieldContainer<ProjectTagModel> selectedTag,
      final LoadableContainer<List<ProjectModel>> projects,
      final TagsScreenType screenType}) = _$TagsScreenStateImpl;

  @override
  FieldContainer<ProjectTagModel> get selectedTag;
  @override
  LoadableContainer<List<ProjectModel>> get projects;
  @override
  TagsScreenType get screenType;
  @override
  @JsonKey(ignore: true)
  _$$TagsScreenStateImplCopyWith<_$TagsScreenStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
