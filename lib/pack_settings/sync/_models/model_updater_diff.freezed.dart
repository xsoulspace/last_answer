// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'model_updater_diff.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$InstanceUpdaterDto<T extends HasId, TOther extends HasId> {
  InstancesUpdatesDto<T, TOther> get originalUpdates =>
      throw _privateConstructorUsedError;
  InstancesUpdatesDto<TOther, T> get otherUpdates =>
      throw _privateConstructorUsedError;
  Map<String, InstanceDiff<T, TOther>> get instancesToCheck =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $InstanceUpdaterDtoCopyWith<T, TOther, InstanceUpdaterDto<T, TOther>>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InstanceUpdaterDtoCopyWith<T extends HasId,
    TOther extends HasId, $Res> {
  factory $InstanceUpdaterDtoCopyWith(InstanceUpdaterDto<T, TOther> value,
          $Res Function(InstanceUpdaterDto<T, TOther>) then) =
      _$InstanceUpdaterDtoCopyWithImpl<T, TOther, $Res>;
  $Res call(
      {InstancesUpdatesDto<T, TOther> originalUpdates,
      InstancesUpdatesDto<TOther, T> otherUpdates,
      Map<String, InstanceDiff<T, TOther>> instancesToCheck});

  $InstancesUpdatesDtoCopyWith<T, TOther, $Res> get originalUpdates;
  $InstancesUpdatesDtoCopyWith<TOther, T, $Res> get otherUpdates;
}

/// @nodoc
class _$InstanceUpdaterDtoCopyWithImpl<T extends HasId, TOther extends HasId,
    $Res> implements $InstanceUpdaterDtoCopyWith<T, TOther, $Res> {
  _$InstanceUpdaterDtoCopyWithImpl(this._value, this._then);

  final InstanceUpdaterDto<T, TOther> _value;
  // ignore: unused_field
  final $Res Function(InstanceUpdaterDto<T, TOther>) _then;

  @override
  $Res call({
    Object? originalUpdates = freezed,
    Object? otherUpdates = freezed,
    Object? instancesToCheck = freezed,
  }) {
    return _then(_value.copyWith(
      originalUpdates: originalUpdates == freezed
          ? _value.originalUpdates
          : originalUpdates // ignore: cast_nullable_to_non_nullable
              as InstancesUpdatesDto<T, TOther>,
      otherUpdates: otherUpdates == freezed
          ? _value.otherUpdates
          : otherUpdates // ignore: cast_nullable_to_non_nullable
              as InstancesUpdatesDto<TOther, T>,
      instancesToCheck: instancesToCheck == freezed
          ? _value.instancesToCheck
          : instancesToCheck // ignore: cast_nullable_to_non_nullable
              as Map<String, InstanceDiff<T, TOther>>,
    ));
  }

  @override
  $InstancesUpdatesDtoCopyWith<T, TOther, $Res> get originalUpdates {
    return $InstancesUpdatesDtoCopyWith<T, TOther, $Res>(_value.originalUpdates,
        (value) {
      return _then(_value.copyWith(originalUpdates: value));
    });
  }

  @override
  $InstancesUpdatesDtoCopyWith<TOther, T, $Res> get otherUpdates {
    return $InstancesUpdatesDtoCopyWith<TOther, T, $Res>(_value.otherUpdates,
        (value) {
      return _then(_value.copyWith(otherUpdates: value));
    });
  }
}

/// @nodoc
abstract class _$$_InstanceUpdaterDtoCopyWith<
    T extends HasId,
    TOther extends HasId,
    $Res> implements $InstanceUpdaterDtoCopyWith<T, TOther, $Res> {
  factory _$$_InstanceUpdaterDtoCopyWith(_$_InstanceUpdaterDto<T, TOther> value,
          $Res Function(_$_InstanceUpdaterDto<T, TOther>) then) =
      __$$_InstanceUpdaterDtoCopyWithImpl<T, TOther, $Res>;
  @override
  $Res call(
      {InstancesUpdatesDto<T, TOther> originalUpdates,
      InstancesUpdatesDto<TOther, T> otherUpdates,
      Map<String, InstanceDiff<T, TOther>> instancesToCheck});

  @override
  $InstancesUpdatesDtoCopyWith<T, TOther, $Res> get originalUpdates;
  @override
  $InstancesUpdatesDtoCopyWith<TOther, T, $Res> get otherUpdates;
}

/// @nodoc
class __$$_InstanceUpdaterDtoCopyWithImpl<T extends HasId, TOther extends HasId,
        $Res> extends _$InstanceUpdaterDtoCopyWithImpl<T, TOther, $Res>
    implements _$$_InstanceUpdaterDtoCopyWith<T, TOther, $Res> {
  __$$_InstanceUpdaterDtoCopyWithImpl(_$_InstanceUpdaterDto<T, TOther> _value,
      $Res Function(_$_InstanceUpdaterDto<T, TOther>) _then)
      : super(_value, (v) => _then(v as _$_InstanceUpdaterDto<T, TOther>));

  @override
  _$_InstanceUpdaterDto<T, TOther> get _value =>
      super._value as _$_InstanceUpdaterDto<T, TOther>;

  @override
  $Res call({
    Object? originalUpdates = freezed,
    Object? otherUpdates = freezed,
    Object? instancesToCheck = freezed,
  }) {
    return _then(_$_InstanceUpdaterDto<T, TOther>(
      originalUpdates: originalUpdates == freezed
          ? _value.originalUpdates
          : originalUpdates // ignore: cast_nullable_to_non_nullable
              as InstancesUpdatesDto<T, TOther>,
      otherUpdates: otherUpdates == freezed
          ? _value.otherUpdates
          : otherUpdates // ignore: cast_nullable_to_non_nullable
              as InstancesUpdatesDto<TOther, T>,
      instancesToCheck: instancesToCheck == freezed
          ? _value._instancesToCheck
          : instancesToCheck // ignore: cast_nullable_to_non_nullable
              as Map<String, InstanceDiff<T, TOther>>,
    ));
  }
}

/// @nodoc

class _$_InstanceUpdaterDto<T extends HasId, TOther extends HasId>
    extends _InstanceUpdaterDto<T, TOther> {
  const _$_InstanceUpdaterDto(
      {required this.originalUpdates,
      required this.otherUpdates,
      final Map<String, InstanceDiff<T, TOther>> instancesToCheck = const {}})
      : _instancesToCheck = instancesToCheck,
        super._();

  @override
  final InstancesUpdatesDto<T, TOther> originalUpdates;
  @override
  final InstancesUpdatesDto<TOther, T> otherUpdates;
  final Map<String, InstanceDiff<T, TOther>> _instancesToCheck;
  @override
  @JsonKey()
  Map<String, InstanceDiff<T, TOther>> get instancesToCheck {
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_instancesToCheck);
  }

  @override
  String toString() {
    return 'InstanceUpdaterDto<$T, $TOther>(originalUpdates: $originalUpdates, otherUpdates: $otherUpdates, instancesToCheck: $instancesToCheck)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_InstanceUpdaterDto<T, TOther> &&
            const DeepCollectionEquality()
                .equals(other.originalUpdates, originalUpdates) &&
            const DeepCollectionEquality()
                .equals(other.otherUpdates, otherUpdates) &&
            const DeepCollectionEquality()
                .equals(other._instancesToCheck, _instancesToCheck));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(originalUpdates),
      const DeepCollectionEquality().hash(otherUpdates),
      const DeepCollectionEquality().hash(_instancesToCheck));

  @JsonKey(ignore: true)
  @override
  _$$_InstanceUpdaterDtoCopyWith<T, TOther, _$_InstanceUpdaterDto<T, TOther>>
      get copyWith => __$$_InstanceUpdaterDtoCopyWithImpl<T, TOther,
          _$_InstanceUpdaterDto<T, TOther>>(this, _$identity);
}

abstract class _InstanceUpdaterDto<T extends HasId, TOther extends HasId>
    extends InstanceUpdaterDto<T, TOther> {
  const factory _InstanceUpdaterDto(
          {required final InstancesUpdatesDto<T, TOther> originalUpdates,
          required final InstancesUpdatesDto<TOther, T> otherUpdates,
          final Map<String, InstanceDiff<T, TOther>> instancesToCheck}) =
      _$_InstanceUpdaterDto<T, TOther>;
  const _InstanceUpdaterDto._() : super._();

  @override
  InstancesUpdatesDto<T, TOther> get originalUpdates =>
      throw _privateConstructorUsedError;
  @override
  InstancesUpdatesDto<TOther, T> get otherUpdates =>
      throw _privateConstructorUsedError;
  @override
  Map<String, InstanceDiff<T, TOther>> get instancesToCheck =>
      throw _privateConstructorUsedError;
  @override
  @JsonKey(ignore: true)
  _$$_InstanceUpdaterDtoCopyWith<T, TOther, _$_InstanceUpdaterDto<T, TOther>>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$InstancesUpdatesDto<T extends HasId, TOther extends HasId> {
  Iterable<TOther> get toCreateFromOther => throw _privateConstructorUsedError;
  Iterable<T> get toUpdate => throw _privateConstructorUsedError;
  Iterable<T> get toDelete => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $InstancesUpdatesDtoCopyWith<T, TOther, InstancesUpdatesDto<T, TOther>>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InstancesUpdatesDtoCopyWith<T extends HasId,
    TOther extends HasId, $Res> {
  factory $InstancesUpdatesDtoCopyWith(InstancesUpdatesDto<T, TOther> value,
          $Res Function(InstancesUpdatesDto<T, TOther>) then) =
      _$InstancesUpdatesDtoCopyWithImpl<T, TOther, $Res>;
  $Res call(
      {Iterable<TOther> toCreateFromOther,
      Iterable<T> toUpdate,
      Iterable<T> toDelete});
}

/// @nodoc
class _$InstancesUpdatesDtoCopyWithImpl<T extends HasId, TOther extends HasId,
    $Res> implements $InstancesUpdatesDtoCopyWith<T, TOther, $Res> {
  _$InstancesUpdatesDtoCopyWithImpl(this._value, this._then);

  final InstancesUpdatesDto<T, TOther> _value;
  // ignore: unused_field
  final $Res Function(InstancesUpdatesDto<T, TOther>) _then;

  @override
  $Res call({
    Object? toCreateFromOther = freezed,
    Object? toUpdate = freezed,
    Object? toDelete = freezed,
  }) {
    return _then(_value.copyWith(
      toCreateFromOther: toCreateFromOther == freezed
          ? _value.toCreateFromOther
          : toCreateFromOther // ignore: cast_nullable_to_non_nullable
              as Iterable<TOther>,
      toUpdate: toUpdate == freezed
          ? _value.toUpdate
          : toUpdate // ignore: cast_nullable_to_non_nullable
              as Iterable<T>,
      toDelete: toDelete == freezed
          ? _value.toDelete
          : toDelete // ignore: cast_nullable_to_non_nullable
              as Iterable<T>,
    ));
  }
}

/// @nodoc
abstract class _$$_InstancesUpdatesDtoCopyWith<
    T extends HasId,
    TOther extends HasId,
    $Res> implements $InstancesUpdatesDtoCopyWith<T, TOther, $Res> {
  factory _$$_InstancesUpdatesDtoCopyWith(
          _$_InstancesUpdatesDto<T, TOther> value,
          $Res Function(_$_InstancesUpdatesDto<T, TOther>) then) =
      __$$_InstancesUpdatesDtoCopyWithImpl<T, TOther, $Res>;
  @override
  $Res call(
      {Iterable<TOther> toCreateFromOther,
      Iterable<T> toUpdate,
      Iterable<T> toDelete});
}

/// @nodoc
class __$$_InstancesUpdatesDtoCopyWithImpl<
        T extends HasId,
        TOther extends HasId,
        $Res> extends _$InstancesUpdatesDtoCopyWithImpl<T, TOther, $Res>
    implements _$$_InstancesUpdatesDtoCopyWith<T, TOther, $Res> {
  __$$_InstancesUpdatesDtoCopyWithImpl(_$_InstancesUpdatesDto<T, TOther> _value,
      $Res Function(_$_InstancesUpdatesDto<T, TOther>) _then)
      : super(_value, (v) => _then(v as _$_InstancesUpdatesDto<T, TOther>));

  @override
  _$_InstancesUpdatesDto<T, TOther> get _value =>
      super._value as _$_InstancesUpdatesDto<T, TOther>;

  @override
  $Res call({
    Object? toCreateFromOther = freezed,
    Object? toUpdate = freezed,
    Object? toDelete = freezed,
  }) {
    return _then(_$_InstancesUpdatesDto<T, TOther>(
      toCreateFromOther: toCreateFromOther == freezed
          ? _value.toCreateFromOther
          : toCreateFromOther // ignore: cast_nullable_to_non_nullable
              as Iterable<TOther>,
      toUpdate: toUpdate == freezed
          ? _value.toUpdate
          : toUpdate // ignore: cast_nullable_to_non_nullable
              as Iterable<T>,
      toDelete: toDelete == freezed
          ? _value.toDelete
          : toDelete // ignore: cast_nullable_to_non_nullable
              as Iterable<T>,
    ));
  }
}

/// @nodoc

class _$_InstancesUpdatesDto<T extends HasId, TOther extends HasId>
    extends _InstancesUpdatesDto<T, TOther> {
  const _$_InstancesUpdatesDto(
      {this.toCreateFromOther = const [],
      this.toUpdate = const [],
      this.toDelete = const []})
      : super._();

  @override
  @JsonKey()
  final Iterable<TOther> toCreateFromOther;
  @override
  @JsonKey()
  final Iterable<T> toUpdate;
  @override
  @JsonKey()
  final Iterable<T> toDelete;

  @override
  String toString() {
    return 'InstancesUpdatesDto<$T, $TOther>(toCreateFromOther: $toCreateFromOther, toUpdate: $toUpdate, toDelete: $toDelete)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_InstancesUpdatesDto<T, TOther> &&
            const DeepCollectionEquality()
                .equals(other.toCreateFromOther, toCreateFromOther) &&
            const DeepCollectionEquality().equals(other.toUpdate, toUpdate) &&
            const DeepCollectionEquality().equals(other.toDelete, toDelete));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(toCreateFromOther),
      const DeepCollectionEquality().hash(toUpdate),
      const DeepCollectionEquality().hash(toDelete));

  @JsonKey(ignore: true)
  @override
  _$$_InstancesUpdatesDtoCopyWith<T, TOther, _$_InstancesUpdatesDto<T, TOther>>
      get copyWith => __$$_InstancesUpdatesDtoCopyWithImpl<T, TOther,
          _$_InstancesUpdatesDto<T, TOther>>(this, _$identity);
}

abstract class _InstancesUpdatesDto<T extends HasId, TOther extends HasId>
    extends InstancesUpdatesDto<T, TOther> {
  const factory _InstancesUpdatesDto(
      {final Iterable<TOther> toCreateFromOther,
      final Iterable<T> toUpdate,
      final Iterable<T> toDelete}) = _$_InstancesUpdatesDto<T, TOther>;
  const _InstancesUpdatesDto._() : super._();

  @override
  Iterable<TOther> get toCreateFromOther => throw _privateConstructorUsedError;
  @override
  Iterable<T> get toUpdate => throw _privateConstructorUsedError;
  @override
  Iterable<T> get toDelete => throw _privateConstructorUsedError;
  @override
  @JsonKey(ignore: true)
  _$$_InstancesUpdatesDtoCopyWith<T, TOther, _$_InstancesUpdatesDto<T, TOther>>
      get copyWith => throw _privateConstructorUsedError;
}
