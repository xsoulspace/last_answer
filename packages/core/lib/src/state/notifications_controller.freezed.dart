// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notifications_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$NotificationControllerState {
  /// Should be ordered from newest to oldest and never be
  List<NotificationMessageModel> get updates =>
      throw _privateConstructorUsedError;
  bool get hasUnreadUpdates => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $NotificationControllerStateCopyWith<NotificationControllerState>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationControllerStateCopyWith<$Res> {
  factory $NotificationControllerStateCopyWith(
          NotificationControllerState value,
          $Res Function(NotificationControllerState) then) =
      _$NotificationControllerStateCopyWithImpl<$Res,
          NotificationControllerState>;
  @useResult
  $Res call({List<NotificationMessageModel> updates, bool hasUnreadUpdates});
}

/// @nodoc
class _$NotificationControllerStateCopyWithImpl<$Res,
        $Val extends NotificationControllerState>
    implements $NotificationControllerStateCopyWith<$Res> {
  _$NotificationControllerStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? updates = null,
    Object? hasUnreadUpdates = null,
  }) {
    return _then(_value.copyWith(
      updates: null == updates
          ? _value.updates
          : updates // ignore: cast_nullable_to_non_nullable
              as List<NotificationMessageModel>,
      hasUnreadUpdates: null == hasUnreadUpdates
          ? _value.hasUnreadUpdates
          : hasUnreadUpdates // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationControllerStateImplCopyWith<$Res>
    implements $NotificationControllerStateCopyWith<$Res> {
  factory _$$NotificationControllerStateImplCopyWith(
          _$NotificationControllerStateImpl value,
          $Res Function(_$NotificationControllerStateImpl) then) =
      __$$NotificationControllerStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<NotificationMessageModel> updates, bool hasUnreadUpdates});
}

/// @nodoc
class __$$NotificationControllerStateImplCopyWithImpl<$Res>
    extends _$NotificationControllerStateCopyWithImpl<$Res,
        _$NotificationControllerStateImpl>
    implements _$$NotificationControllerStateImplCopyWith<$Res> {
  __$$NotificationControllerStateImplCopyWithImpl(
      _$NotificationControllerStateImpl _value,
      $Res Function(_$NotificationControllerStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? updates = null,
    Object? hasUnreadUpdates = null,
  }) {
    return _then(_$NotificationControllerStateImpl(
      updates: null == updates
          ? _value._updates
          : updates // ignore: cast_nullable_to_non_nullable
              as List<NotificationMessageModel>,
      hasUnreadUpdates: null == hasUnreadUpdates
          ? _value.hasUnreadUpdates
          : hasUnreadUpdates // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$NotificationControllerStateImpl
    implements _NotificationControllerState {
  const _$NotificationControllerStateImpl(
      {final List<NotificationMessageModel> updates = const [],
      this.hasUnreadUpdates = false})
      : _updates = updates;

  /// Should be ordered from newest to oldest and never be
  final List<NotificationMessageModel> _updates;

  /// Should be ordered from newest to oldest and never be
  @override
  @JsonKey()
  List<NotificationMessageModel> get updates {
    if (_updates is EqualUnmodifiableListView) return _updates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_updates);
  }

  @override
  @JsonKey()
  final bool hasUnreadUpdates;

  @override
  String toString() {
    return 'NotificationControllerState(updates: $updates, hasUnreadUpdates: $hasUnreadUpdates)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationControllerStateImpl &&
            const DeepCollectionEquality().equals(other._updates, _updates) &&
            (identical(other.hasUnreadUpdates, hasUnreadUpdates) ||
                other.hasUnreadUpdates == hasUnreadUpdates));
  }

  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_updates), hasUnreadUpdates);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationControllerStateImplCopyWith<_$NotificationControllerStateImpl>
      get copyWith => __$$NotificationControllerStateImplCopyWithImpl<
          _$NotificationControllerStateImpl>(this, _$identity);
}

abstract class _NotificationControllerState
    implements NotificationControllerState {
  const factory _NotificationControllerState(
      {final List<NotificationMessageModel> updates,
      final bool hasUnreadUpdates}) = _$NotificationControllerStateImpl;

  @override

  /// Should be ordered from newest to oldest and never be
  List<NotificationMessageModel> get updates;
  @override
  bool get hasUnreadUpdates;
  @override
  @JsonKey(ignore: true)
  _$$NotificationControllerStateImplCopyWith<_$NotificationControllerStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
