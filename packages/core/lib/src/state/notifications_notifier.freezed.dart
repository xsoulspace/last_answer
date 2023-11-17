// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notifications_notifier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$NotificationsNotifierState {
  /// Should be ordered from newest to oldest and never be
  List<NotificationMessageModel> get updates =>
      throw _privateConstructorUsedError;
  bool get hasUnreadUpdates => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $NotificationsNotifierStateCopyWith<NotificationsNotifierState>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationsNotifierStateCopyWith<$Res> {
  factory $NotificationsNotifierStateCopyWith(NotificationsNotifierState value,
          $Res Function(NotificationsNotifierState) then) =
      _$NotificationsNotifierStateCopyWithImpl<$Res,
          NotificationsNotifierState>;
  @useResult
  $Res call({List<NotificationMessageModel> updates, bool hasUnreadUpdates});
}

/// @nodoc
class _$NotificationsNotifierStateCopyWithImpl<$Res,
        $Val extends NotificationsNotifierState>
    implements $NotificationsNotifierStateCopyWith<$Res> {
  _$NotificationsNotifierStateCopyWithImpl(this._value, this._then);

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
abstract class _$$NotificationsNotifierStateImplCopyWith<$Res>
    implements $NotificationsNotifierStateCopyWith<$Res> {
  factory _$$NotificationsNotifierStateImplCopyWith(
          _$NotificationsNotifierStateImpl value,
          $Res Function(_$NotificationsNotifierStateImpl) then) =
      __$$NotificationsNotifierStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<NotificationMessageModel> updates, bool hasUnreadUpdates});
}

/// @nodoc
class __$$NotificationsNotifierStateImplCopyWithImpl<$Res>
    extends _$NotificationsNotifierStateCopyWithImpl<$Res,
        _$NotificationsNotifierStateImpl>
    implements _$$NotificationsNotifierStateImplCopyWith<$Res> {
  __$$NotificationsNotifierStateImplCopyWithImpl(
      _$NotificationsNotifierStateImpl _value,
      $Res Function(_$NotificationsNotifierStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? updates = null,
    Object? hasUnreadUpdates = null,
  }) {
    return _then(_$NotificationsNotifierStateImpl(
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

class _$NotificationsNotifierStateImpl implements _NotificationsNotifierState {
  const _$NotificationsNotifierStateImpl(
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
    return 'NotificationsNotifierState(updates: $updates, hasUnreadUpdates: $hasUnreadUpdates)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationsNotifierStateImpl &&
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
  _$$NotificationsNotifierStateImplCopyWith<_$NotificationsNotifierStateImpl>
      get copyWith => __$$NotificationsNotifierStateImplCopyWithImpl<
          _$NotificationsNotifierStateImpl>(this, _$identity);
}

abstract class _NotificationsNotifierState
    implements NotificationsNotifierState {
  const factory _NotificationsNotifierState(
      {final List<NotificationMessageModel> updates,
      final bool hasUnreadUpdates}) = _$NotificationsNotifierStateImpl;

  @override

  /// Should be ordered from newest to oldest and never be
  List<NotificationMessageModel> get updates;
  @override
  bool get hasUnreadUpdates;
  @override
  @JsonKey(ignore: true)
  _$$NotificationsNotifierStateImplCopyWith<_$NotificationsNotifierStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
