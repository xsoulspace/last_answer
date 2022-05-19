// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of pack_settings;

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$InstanceDiff<T extends HasId, TOther extends HasId> {
  T get original => throw _privateConstructorUsedError;
  TOther get other => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $InstanceDiffCopyWith<T, TOther, InstanceDiff<T, TOther>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InstanceDiffCopyWith<T extends HasId, TOther extends HasId,
    $Res> {
  factory $InstanceDiffCopyWith(InstanceDiff<T, TOther> value,
          $Res Function(InstanceDiff<T, TOther>) then) =
      _$InstanceDiffCopyWithImpl<T, TOther, $Res>;
  $Res call({T original, TOther other});
}

/// @nodoc
class _$InstanceDiffCopyWithImpl<T extends HasId, TOther extends HasId, $Res>
    implements $InstanceDiffCopyWith<T, TOther, $Res> {
  _$InstanceDiffCopyWithImpl(this._value, this._then);

  final InstanceDiff<T, TOther> _value;
  // ignore: unused_field
  final $Res Function(InstanceDiff<T, TOther>) _then;

  @override
  $Res call({
    Object? original = freezed,
    Object? other = freezed,
  }) {
    return _then(_value.copyWith(
      original: original == freezed
          ? _value.original
          : original // ignore: cast_nullable_to_non_nullable
              as T,
      other: other == freezed
          ? _value.other
          : other // ignore: cast_nullable_to_non_nullable
              as TOther,
    ));
  }
}

/// @nodoc
abstract class _$$_InstanceDiffCopyWith<T extends HasId, TOther extends HasId,
    $Res> implements $InstanceDiffCopyWith<T, TOther, $Res> {
  factory _$$_InstanceDiffCopyWith(_$_InstanceDiff<T, TOther> value,
          $Res Function(_$_InstanceDiff<T, TOther>) then) =
      __$$_InstanceDiffCopyWithImpl<T, TOther, $Res>;
  @override
  $Res call({T original, TOther other});
}

/// @nodoc
class __$$_InstanceDiffCopyWithImpl<T extends HasId, TOther extends HasId, $Res>
    extends _$InstanceDiffCopyWithImpl<T, TOther, $Res>
    implements _$$_InstanceDiffCopyWith<T, TOther, $Res> {
  __$$_InstanceDiffCopyWithImpl(_$_InstanceDiff<T, TOther> _value,
      $Res Function(_$_InstanceDiff<T, TOther>) _then)
      : super(_value, (v) => _then(v as _$_InstanceDiff<T, TOther>));

  @override
  _$_InstanceDiff<T, TOther> get _value =>
      super._value as _$_InstanceDiff<T, TOther>;

  @override
  $Res call({
    Object? original = freezed,
    Object? other = freezed,
  }) {
    return _then(_$_InstanceDiff<T, TOther>(
      original: original == freezed
          ? _value.original
          : original // ignore: cast_nullable_to_non_nullable
              as T,
      other: other == freezed
          ? _value.other
          : other // ignore: cast_nullable_to_non_nullable
              as TOther,
    ));
  }
}

/// @nodoc

class _$_InstanceDiff<T extends HasId, TOther extends HasId>
    extends _InstanceDiff<T, TOther> {
  const _$_InstanceDiff({required this.original, required this.other})
      : super._();

  @override
  final T original;
  @override
  final TOther other;

  @override
  String toString() {
    return 'InstanceDiff<$T, $TOther>(original: $original, other: $other)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_InstanceDiff<T, TOther> &&
            const DeepCollectionEquality().equals(other.original, original) &&
            const DeepCollectionEquality().equals(other.other, this.other));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(original),
      const DeepCollectionEquality().hash(other));

  @JsonKey(ignore: true)
  @override
  _$$_InstanceDiffCopyWith<T, TOther, _$_InstanceDiff<T, TOther>>
      get copyWith =>
          __$$_InstanceDiffCopyWithImpl<T, TOther, _$_InstanceDiff<T, TOther>>(
              this, _$identity);
}

abstract class _InstanceDiff<T extends HasId, TOther extends HasId>
    extends InstanceDiff<T, TOther> {
  const factory _InstanceDiff(
      {required final T original,
      required final TOther other}) = _$_InstanceDiff<T, TOther>;
  const _InstanceDiff._() : super._();

  @override
  T get original => throw _privateConstructorUsedError;
  @override
  TOther get other => throw _privateConstructorUsedError;
  @override
  @JsonKey(ignore: true)
  _$$_InstanceDiffCopyWith<T, TOther, _$_InstanceDiff<T, TOther>>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ModelUpdaterDiff<T extends HasId, TOther extends HasId> {
  Map<String, T> get instancesToCreate => throw _privateConstructorUsedError;
  Map<String, TOther> get otherInstancesToCreate =>
      throw _privateConstructorUsedError;
  Map<String, InstanceDiff<T, TOther>> get instancesToCheck =>
      throw _privateConstructorUsedError;
  Map<String, InstanceDiff<T, TOther>> get instancesToUpdate =>
      throw _privateConstructorUsedError;
  Map<String, InstanceDiff<T, TOther>> get updatedInstances =>
      throw _privateConstructorUsedError;
  Map<String, T> get instancesToDelete => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ModelUpdaterDiffCopyWith<T, TOther, ModelUpdaterDiff<T, TOther>>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ModelUpdaterDiffCopyWith<T extends HasId, TOther extends HasId,
    $Res> {
  factory $ModelUpdaterDiffCopyWith(ModelUpdaterDiff<T, TOther> value,
          $Res Function(ModelUpdaterDiff<T, TOther>) then) =
      _$ModelUpdaterDiffCopyWithImpl<T, TOther, $Res>;
  $Res call(
      {Map<String, T> instancesToCreate,
      Map<String, TOther> otherInstancesToCreate,
      Map<String, InstanceDiff<T, TOther>> instancesToCheck,
      Map<String, InstanceDiff<T, TOther>> instancesToUpdate,
      Map<String, InstanceDiff<T, TOther>> updatedInstances,
      Map<String, T> instancesToDelete});
}

/// @nodoc
class _$ModelUpdaterDiffCopyWithImpl<T extends HasId, TOther extends HasId,
    $Res> implements $ModelUpdaterDiffCopyWith<T, TOther, $Res> {
  _$ModelUpdaterDiffCopyWithImpl(this._value, this._then);

  final ModelUpdaterDiff<T, TOther> _value;
  // ignore: unused_field
  final $Res Function(ModelUpdaterDiff<T, TOther>) _then;

  @override
  $Res call({
    Object? instancesToCreate = freezed,
    Object? otherInstancesToCreate = freezed,
    Object? instancesToCheck = freezed,
    Object? instancesToUpdate = freezed,
    Object? updatedInstances = freezed,
    Object? instancesToDelete = freezed,
  }) {
    return _then(_value.copyWith(
      instancesToCreate: instancesToCreate == freezed
          ? _value.instancesToCreate
          : instancesToCreate // ignore: cast_nullable_to_non_nullable
              as Map<String, T>,
      otherInstancesToCreate: otherInstancesToCreate == freezed
          ? _value.otherInstancesToCreate
          : otherInstancesToCreate // ignore: cast_nullable_to_non_nullable
              as Map<String, TOther>,
      instancesToCheck: instancesToCheck == freezed
          ? _value.instancesToCheck
          : instancesToCheck // ignore: cast_nullable_to_non_nullable
              as Map<String, InstanceDiff<T, TOther>>,
      instancesToUpdate: instancesToUpdate == freezed
          ? _value.instancesToUpdate
          : instancesToUpdate // ignore: cast_nullable_to_non_nullable
              as Map<String, InstanceDiff<T, TOther>>,
      updatedInstances: updatedInstances == freezed
          ? _value.updatedInstances
          : updatedInstances // ignore: cast_nullable_to_non_nullable
              as Map<String, InstanceDiff<T, TOther>>,
      instancesToDelete: instancesToDelete == freezed
          ? _value.instancesToDelete
          : instancesToDelete // ignore: cast_nullable_to_non_nullable
              as Map<String, T>,
    ));
  }
}

/// @nodoc
abstract class _$$_ModelUpdaterDiffCopyWith<
    T extends HasId,
    TOther extends HasId,
    $Res> implements $ModelUpdaterDiffCopyWith<T, TOther, $Res> {
  factory _$$_ModelUpdaterDiffCopyWith(_$_ModelUpdaterDiff<T, TOther> value,
          $Res Function(_$_ModelUpdaterDiff<T, TOther>) then) =
      __$$_ModelUpdaterDiffCopyWithImpl<T, TOther, $Res>;
  @override
  $Res call(
      {Map<String, T> instancesToCreate,
      Map<String, TOther> otherInstancesToCreate,
      Map<String, InstanceDiff<T, TOther>> instancesToCheck,
      Map<String, InstanceDiff<T, TOther>> instancesToUpdate,
      Map<String, InstanceDiff<T, TOther>> updatedInstances,
      Map<String, T> instancesToDelete});
}

/// @nodoc
class __$$_ModelUpdaterDiffCopyWithImpl<T extends HasId, TOther extends HasId,
        $Res> extends _$ModelUpdaterDiffCopyWithImpl<T, TOther, $Res>
    implements _$$_ModelUpdaterDiffCopyWith<T, TOther, $Res> {
  __$$_ModelUpdaterDiffCopyWithImpl(_$_ModelUpdaterDiff<T, TOther> _value,
      $Res Function(_$_ModelUpdaterDiff<T, TOther>) _then)
      : super(_value, (v) => _then(v as _$_ModelUpdaterDiff<T, TOther>));

  @override
  _$_ModelUpdaterDiff<T, TOther> get _value =>
      super._value as _$_ModelUpdaterDiff<T, TOther>;

  @override
  $Res call({
    Object? instancesToCreate = freezed,
    Object? otherInstancesToCreate = freezed,
    Object? instancesToCheck = freezed,
    Object? instancesToUpdate = freezed,
    Object? updatedInstances = freezed,
    Object? instancesToDelete = freezed,
  }) {
    return _then(_$_ModelUpdaterDiff<T, TOther>(
      instancesToCreate: instancesToCreate == freezed
          ? _value._instancesToCreate
          : instancesToCreate // ignore: cast_nullable_to_non_nullable
              as Map<String, T>,
      otherInstancesToCreate: otherInstancesToCreate == freezed
          ? _value._otherInstancesToCreate
          : otherInstancesToCreate // ignore: cast_nullable_to_non_nullable
              as Map<String, TOther>,
      instancesToCheck: instancesToCheck == freezed
          ? _value._instancesToCheck
          : instancesToCheck // ignore: cast_nullable_to_non_nullable
              as Map<String, InstanceDiff<T, TOther>>,
      instancesToUpdate: instancesToUpdate == freezed
          ? _value._instancesToUpdate
          : instancesToUpdate // ignore: cast_nullable_to_non_nullable
              as Map<String, InstanceDiff<T, TOther>>,
      updatedInstances: updatedInstances == freezed
          ? _value._updatedInstances
          : updatedInstances // ignore: cast_nullable_to_non_nullable
              as Map<String, InstanceDiff<T, TOther>>,
      instancesToDelete: instancesToDelete == freezed
          ? _value._instancesToDelete
          : instancesToDelete // ignore: cast_nullable_to_non_nullable
              as Map<String, T>,
    ));
  }
}

/// @nodoc

class _$_ModelUpdaterDiff<T extends HasId, TOther extends HasId>
    extends _ModelUpdaterDiff<T, TOther> {
  const _$_ModelUpdaterDiff(
      {final Map<String, T> instancesToCreate = const {},
      final Map<String, TOther> otherInstancesToCreate = const {},
      final Map<String, InstanceDiff<T, TOther>> instancesToCheck = const {},
      final Map<String, InstanceDiff<T, TOther>> instancesToUpdate = const {},
      final Map<String, InstanceDiff<T, TOther>> updatedInstances = const {},
      final Map<String, T> instancesToDelete = const {}})
      : _instancesToCreate = instancesToCreate,
        _otherInstancesToCreate = otherInstancesToCreate,
        _instancesToCheck = instancesToCheck,
        _instancesToUpdate = instancesToUpdate,
        _updatedInstances = updatedInstances,
        _instancesToDelete = instancesToDelete,
        super._();

  final Map<String, T> _instancesToCreate;
  @override
  @JsonKey()
  Map<String, T> get instancesToCreate {
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_instancesToCreate);
  }

  final Map<String, TOther> _otherInstancesToCreate;
  @override
  @JsonKey()
  Map<String, TOther> get otherInstancesToCreate {
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_otherInstancesToCreate);
  }

  final Map<String, InstanceDiff<T, TOther>> _instancesToCheck;
  @override
  @JsonKey()
  Map<String, InstanceDiff<T, TOther>> get instancesToCheck {
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_instancesToCheck);
  }

  final Map<String, InstanceDiff<T, TOther>> _instancesToUpdate;
  @override
  @JsonKey()
  Map<String, InstanceDiff<T, TOther>> get instancesToUpdate {
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_instancesToUpdate);
  }

  final Map<String, InstanceDiff<T, TOther>> _updatedInstances;
  @override
  @JsonKey()
  Map<String, InstanceDiff<T, TOther>> get updatedInstances {
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_updatedInstances);
  }

  final Map<String, T> _instancesToDelete;
  @override
  @JsonKey()
  Map<String, T> get instancesToDelete {
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_instancesToDelete);
  }

  @override
  String toString() {
    return 'ModelUpdaterDiff<$T, $TOther>(instancesToCreate: $instancesToCreate, otherInstancesToCreate: $otherInstancesToCreate, instancesToCheck: $instancesToCheck, instancesToUpdate: $instancesToUpdate, updatedInstances: $updatedInstances, instancesToDelete: $instancesToDelete)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_ModelUpdaterDiff<T, TOther> &&
            const DeepCollectionEquality()
                .equals(other._instancesToCreate, _instancesToCreate) &&
            const DeepCollectionEquality().equals(
                other._otherInstancesToCreate, _otherInstancesToCreate) &&
            const DeepCollectionEquality()
                .equals(other._instancesToCheck, _instancesToCheck) &&
            const DeepCollectionEquality()
                .equals(other._instancesToUpdate, _instancesToUpdate) &&
            const DeepCollectionEquality()
                .equals(other._updatedInstances, _updatedInstances) &&
            const DeepCollectionEquality()
                .equals(other._instancesToDelete, _instancesToDelete));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_instancesToCreate),
      const DeepCollectionEquality().hash(_otherInstancesToCreate),
      const DeepCollectionEquality().hash(_instancesToCheck),
      const DeepCollectionEquality().hash(_instancesToUpdate),
      const DeepCollectionEquality().hash(_updatedInstances),
      const DeepCollectionEquality().hash(_instancesToDelete));

  @JsonKey(ignore: true)
  @override
  _$$_ModelUpdaterDiffCopyWith<T, TOther, _$_ModelUpdaterDiff<T, TOther>>
      get copyWith => __$$_ModelUpdaterDiffCopyWithImpl<T, TOther,
          _$_ModelUpdaterDiff<T, TOther>>(this, _$identity);
}

abstract class _ModelUpdaterDiff<T extends HasId, TOther extends HasId>
    extends ModelUpdaterDiff<T, TOther> {
  const factory _ModelUpdaterDiff(
      {final Map<String, T> instancesToCreate,
      final Map<String, TOther> otherInstancesToCreate,
      final Map<String, InstanceDiff<T, TOther>> instancesToCheck,
      final Map<String, InstanceDiff<T, TOther>> instancesToUpdate,
      final Map<String, InstanceDiff<T, TOther>> updatedInstances,
      final Map<String, T> instancesToDelete}) = _$_ModelUpdaterDiff<T, TOther>;
  const _ModelUpdaterDiff._() : super._();

  @override
  Map<String, T> get instancesToCreate => throw _privateConstructorUsedError;
  @override
  Map<String, TOther> get otherInstancesToCreate =>
      throw _privateConstructorUsedError;
  @override
  Map<String, InstanceDiff<T, TOther>> get instancesToCheck =>
      throw _privateConstructorUsedError;
  @override
  Map<String, InstanceDiff<T, TOther>> get instancesToUpdate =>
      throw _privateConstructorUsedError;
  @override
  Map<String, InstanceDiff<T, TOther>> get updatedInstances =>
      throw _privateConstructorUsedError;
  @override
  Map<String, T> get instancesToDelete => throw _privateConstructorUsedError;
  @override
  @JsonKey(ignore: true)
  _$$_ModelUpdaterDiffCopyWith<T, TOther, _$_ModelUpdaterDiff<T, TOther>>
      get copyWith => throw _privateConstructorUsedError;
}
