// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

EmojiModel _$EmojiModelFromJson(Map<String, dynamic> json) {
  return _EmojiModel.fromJson(json);
}

/// @nodoc
mixin _$EmojiModel {
  String get category => throw _privateConstructorUsedError;
  String get emoji => throw _privateConstructorUsedError;
  String get keywords => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $EmojiModelCopyWith<EmojiModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EmojiModelCopyWith<$Res> {
  factory $EmojiModelCopyWith(
          EmojiModel value, $Res Function(EmojiModel) then) =
      _$EmojiModelCopyWithImpl<$Res, EmojiModel>;
  @useResult
  $Res call({String category, String emoji, String keywords});
}

/// @nodoc
class _$EmojiModelCopyWithImpl<$Res, $Val extends EmojiModel>
    implements $EmojiModelCopyWith<$Res> {
  _$EmojiModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = null,
    Object? emoji = null,
    Object? keywords = null,
  }) {
    return _then(_value.copyWith(
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      emoji: null == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
      keywords: null == keywords
          ? _value.keywords
          : keywords // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EmojiModelImplCopyWith<$Res>
    implements $EmojiModelCopyWith<$Res> {
  factory _$$EmojiModelImplCopyWith(
          _$EmojiModelImpl value, $Res Function(_$EmojiModelImpl) then) =
      __$$EmojiModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String category, String emoji, String keywords});
}

/// @nodoc
class __$$EmojiModelImplCopyWithImpl<$Res>
    extends _$EmojiModelCopyWithImpl<$Res, _$EmojiModelImpl>
    implements _$$EmojiModelImplCopyWith<$Res> {
  __$$EmojiModelImplCopyWithImpl(
      _$EmojiModelImpl _value, $Res Function(_$EmojiModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = null,
    Object? emoji = null,
    Object? keywords = null,
  }) {
    return _then(_$EmojiModelImpl(
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      emoji: null == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
      keywords: null == keywords
          ? _value.keywords
          : keywords // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EmojiModelImpl implements _EmojiModel {
  const _$EmojiModelImpl(
      {required this.category, required this.emoji, required this.keywords});

  factory _$EmojiModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$EmojiModelImplFromJson(json);

  @override
  final String category;
  @override
  final String emoji;
  @override
  final String keywords;

  @override
  String toString() {
    return 'EmojiModel(category: $category, emoji: $emoji, keywords: $keywords)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EmojiModelImpl &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.emoji, emoji) || other.emoji == emoji) &&
            (identical(other.keywords, keywords) ||
                other.keywords == keywords));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, category, emoji, keywords);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$EmojiModelImplCopyWith<_$EmojiModelImpl> get copyWith =>
      __$$EmojiModelImplCopyWithImpl<_$EmojiModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EmojiModelImplToJson(
      this,
    );
  }
}

abstract class _EmojiModel implements EmojiModel {
  const factory _EmojiModel(
      {required final String category,
      required final String emoji,
      required final String keywords}) = _$EmojiModelImpl;

  factory _EmojiModel.fromJson(Map<String, dynamic> json) =
      _$EmojiModelImpl.fromJson;

  @override
  String get category;
  @override
  String get emoji;
  @override
  String get keywords;
  @override
  @JsonKey(ignore: true)
  _$$EmojiModelImplCopyWith<_$EmojiModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PurchaseRequestDtoModel _$PurchaseRequestDtoModelFromJson(
    Map<String, dynamic> json) {
  return _PurchaseRequestDtoModel.fromJson(json);
}

/// @nodoc
mixin _$PurchaseRequestDtoModel {
  IAPId get productId => throw _privateConstructorUsedError;
  PurchasePaymentProvider get provider => throw _privateConstructorUsedError;
  PurchaseType get type => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PurchaseRequestDtoModelCopyWith<PurchaseRequestDtoModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PurchaseRequestDtoModelCopyWith<$Res> {
  factory $PurchaseRequestDtoModelCopyWith(PurchaseRequestDtoModel value,
          $Res Function(PurchaseRequestDtoModel) then) =
      _$PurchaseRequestDtoModelCopyWithImpl<$Res, PurchaseRequestDtoModel>;
  @useResult
  $Res call(
      {IAPId productId, PurchasePaymentProvider provider, PurchaseType type});
}

/// @nodoc
class _$PurchaseRequestDtoModelCopyWithImpl<$Res,
        $Val extends PurchaseRequestDtoModel>
    implements $PurchaseRequestDtoModelCopyWith<$Res> {
  _$PurchaseRequestDtoModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? provider = null,
    Object? type = null,
  }) {
    return _then(_value.copyWith(
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as IAPId,
      provider: null == provider
          ? _value.provider
          : provider // ignore: cast_nullable_to_non_nullable
              as PurchasePaymentProvider,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as PurchaseType,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PurchaseRequestDtoModelImplCopyWith<$Res>
    implements $PurchaseRequestDtoModelCopyWith<$Res> {
  factory _$$PurchaseRequestDtoModelImplCopyWith(
          _$PurchaseRequestDtoModelImpl value,
          $Res Function(_$PurchaseRequestDtoModelImpl) then) =
      __$$PurchaseRequestDtoModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {IAPId productId, PurchasePaymentProvider provider, PurchaseType type});
}

/// @nodoc
class __$$PurchaseRequestDtoModelImplCopyWithImpl<$Res>
    extends _$PurchaseRequestDtoModelCopyWithImpl<$Res,
        _$PurchaseRequestDtoModelImpl>
    implements _$$PurchaseRequestDtoModelImplCopyWith<$Res> {
  __$$PurchaseRequestDtoModelImplCopyWithImpl(
      _$PurchaseRequestDtoModelImpl _value,
      $Res Function(_$PurchaseRequestDtoModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? provider = null,
    Object? type = null,
  }) {
    return _then(_$PurchaseRequestDtoModelImpl(
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as IAPId,
      provider: null == provider
          ? _value.provider
          : provider // ignore: cast_nullable_to_non_nullable
              as PurchasePaymentProvider,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as PurchaseType,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PurchaseRequestDtoModelImpl extends _PurchaseRequestDtoModel {
  const _$PurchaseRequestDtoModelImpl(
      {required this.productId, required this.provider, required this.type})
      : super._();

  factory _$PurchaseRequestDtoModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PurchaseRequestDtoModelImplFromJson(json);

  @override
  final IAPId productId;
  @override
  final PurchasePaymentProvider provider;
  @override
  final PurchaseType type;

  @override
  String toString() {
    return 'PurchaseRequestDtoModel(productId: $productId, provider: $provider, type: $type)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PurchaseRequestDtoModelImpl &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.provider, provider) ||
                other.provider == provider) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, productId, provider, type);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PurchaseRequestDtoModelImplCopyWith<_$PurchaseRequestDtoModelImpl>
      get copyWith => __$$PurchaseRequestDtoModelImplCopyWithImpl<
          _$PurchaseRequestDtoModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PurchaseRequestDtoModelImplToJson(
      this,
    );
  }
}

abstract class _PurchaseRequestDtoModel extends PurchaseRequestDtoModel {
  const factory _PurchaseRequestDtoModel(
      {required final IAPId productId,
      required final PurchasePaymentProvider provider,
      required final PurchaseType type}) = _$PurchaseRequestDtoModelImpl;
  const _PurchaseRequestDtoModel._() : super._();

  factory _PurchaseRequestDtoModel.fromJson(Map<String, dynamic> json) =
      _$PurchaseRequestDtoModelImpl.fromJson;

  @override
  IAPId get productId;
  @override
  PurchasePaymentProvider get provider;
  @override
  PurchaseType get type;
  @override
  @JsonKey(ignore: true)
  _$$PurchaseRequestDtoModelImplCopyWith<_$PurchaseRequestDtoModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

PurchaseActionModel _$PurchaseActionModelFromJson(Map<String, dynamic> json) {
  return PurchaseActionModelVideoAward.fromJson(json);
}

/// @nodoc
mixin _$PurchaseActionModel {
  UserModelId get userId => throw _privateConstructorUsedError;
  PurchaseType get type => throw _privateConstructorUsedError;
  int get rewardDaysQuantity => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(UserModelId userId, PurchaseType type,
            int rewardDaysQuantity, DateTime? createdAt)
        videoAward,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(UserModelId userId, PurchaseType type,
            int rewardDaysQuantity, DateTime? createdAt)?
        videoAward,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(UserModelId userId, PurchaseType type,
            int rewardDaysQuantity, DateTime? createdAt)?
        videoAward,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PurchaseActionModelVideoAward value) videoAward,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PurchaseActionModelVideoAward value)? videoAward,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PurchaseActionModelVideoAward value)? videoAward,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PurchaseActionModelCopyWith<PurchaseActionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PurchaseActionModelCopyWith<$Res> {
  factory $PurchaseActionModelCopyWith(
          PurchaseActionModel value, $Res Function(PurchaseActionModel) then) =
      _$PurchaseActionModelCopyWithImpl<$Res, PurchaseActionModel>;
  @useResult
  $Res call(
      {UserModelId userId,
      PurchaseType type,
      int rewardDaysQuantity,
      DateTime? createdAt});

  $UserModelIdCopyWith<$Res> get userId;
}

/// @nodoc
class _$PurchaseActionModelCopyWithImpl<$Res, $Val extends PurchaseActionModel>
    implements $PurchaseActionModelCopyWith<$Res> {
  _$PurchaseActionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? type = null,
    Object? rewardDaysQuantity = null,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as UserModelId,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as PurchaseType,
      rewardDaysQuantity: null == rewardDaysQuantity
          ? _value.rewardDaysQuantity
          : rewardDaysQuantity // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $UserModelIdCopyWith<$Res> get userId {
    return $UserModelIdCopyWith<$Res>(_value.userId, (value) {
      return _then(_value.copyWith(userId: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PurchaseActionModelVideoAwardImplCopyWith<$Res>
    implements $PurchaseActionModelCopyWith<$Res> {
  factory _$$PurchaseActionModelVideoAwardImplCopyWith(
          _$PurchaseActionModelVideoAwardImpl value,
          $Res Function(_$PurchaseActionModelVideoAwardImpl) then) =
      __$$PurchaseActionModelVideoAwardImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {UserModelId userId,
      PurchaseType type,
      int rewardDaysQuantity,
      DateTime? createdAt});

  @override
  $UserModelIdCopyWith<$Res> get userId;
}

/// @nodoc
class __$$PurchaseActionModelVideoAwardImplCopyWithImpl<$Res>
    extends _$PurchaseActionModelCopyWithImpl<$Res,
        _$PurchaseActionModelVideoAwardImpl>
    implements _$$PurchaseActionModelVideoAwardImplCopyWith<$Res> {
  __$$PurchaseActionModelVideoAwardImplCopyWithImpl(
      _$PurchaseActionModelVideoAwardImpl _value,
      $Res Function(_$PurchaseActionModelVideoAwardImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? type = null,
    Object? rewardDaysQuantity = null,
    Object? createdAt = freezed,
  }) {
    return _then(_$PurchaseActionModelVideoAwardImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as UserModelId,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as PurchaseType,
      rewardDaysQuantity: null == rewardDaysQuantity
          ? _value.rewardDaysQuantity
          : rewardDaysQuantity // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PurchaseActionModelVideoAwardImpl
    extends PurchaseActionModelVideoAward {
  const _$PurchaseActionModelVideoAwardImpl(
      {this.userId = UserModelId.empty,
      this.type = PurchaseType.videoAward,
      this.rewardDaysQuantity = 0,
      this.createdAt})
      : super._();

  factory _$PurchaseActionModelVideoAwardImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$PurchaseActionModelVideoAwardImplFromJson(json);

  @override
  @JsonKey()
  final UserModelId userId;
  @override
  @JsonKey()
  final PurchaseType type;
  @override
  @JsonKey()
  final int rewardDaysQuantity;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'PurchaseActionModel.videoAward(userId: $userId, type: $type, rewardDaysQuantity: $rewardDaysQuantity, createdAt: $createdAt)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PurchaseActionModelVideoAwardImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.rewardDaysQuantity, rewardDaysQuantity) ||
                other.rewardDaysQuantity == rewardDaysQuantity) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, userId, type, rewardDaysQuantity, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PurchaseActionModelVideoAwardImplCopyWith<
          _$PurchaseActionModelVideoAwardImpl>
      get copyWith => __$$PurchaseActionModelVideoAwardImplCopyWithImpl<
          _$PurchaseActionModelVideoAwardImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(UserModelId userId, PurchaseType type,
            int rewardDaysQuantity, DateTime? createdAt)
        videoAward,
  }) {
    return videoAward(userId, type, rewardDaysQuantity, createdAt);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(UserModelId userId, PurchaseType type,
            int rewardDaysQuantity, DateTime? createdAt)?
        videoAward,
  }) {
    return videoAward?.call(userId, type, rewardDaysQuantity, createdAt);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(UserModelId userId, PurchaseType type,
            int rewardDaysQuantity, DateTime? createdAt)?
        videoAward,
    required TResult orElse(),
  }) {
    if (videoAward != null) {
      return videoAward(userId, type, rewardDaysQuantity, createdAt);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PurchaseActionModelVideoAward value) videoAward,
  }) {
    return videoAward(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PurchaseActionModelVideoAward value)? videoAward,
  }) {
    return videoAward?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PurchaseActionModelVideoAward value)? videoAward,
    required TResult orElse(),
  }) {
    if (videoAward != null) {
      return videoAward(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$PurchaseActionModelVideoAwardImplToJson(
      this,
    );
  }
}

abstract class PurchaseActionModelVideoAward extends PurchaseActionModel {
  const factory PurchaseActionModelVideoAward(
      {final UserModelId userId,
      final PurchaseType type,
      final int rewardDaysQuantity,
      final DateTime? createdAt}) = _$PurchaseActionModelVideoAwardImpl;
  const PurchaseActionModelVideoAward._() : super._();

  factory PurchaseActionModelVideoAward.fromJson(Map<String, dynamic> json) =
      _$PurchaseActionModelVideoAwardImpl.fromJson;

  @override
  UserModelId get userId;
  @override
  PurchaseType get type;
  @override
  int get rewardDaysQuantity;
  @override
  DateTime? get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$PurchaseActionModelVideoAwardImplCopyWith<
          _$PurchaseActionModelVideoAwardImpl>
      get copyWith => throw _privateConstructorUsedError;
}

RemoteUserModel _$RemoteUserModelFromJson(Map<String, dynamic> json) {
  return _RemoteUserModel.fromJson(json);
}

/// @nodoc
mixin _$RemoteUserModel {
  UserModelId get id => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RemoteUserModelCopyWith<RemoteUserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RemoteUserModelCopyWith<$Res> {
  factory $RemoteUserModelCopyWith(
          RemoteUserModel value, $Res Function(RemoteUserModel) then) =
      _$RemoteUserModelCopyWithImpl<$Res, RemoteUserModel>;
  @useResult
  $Res call({UserModelId id});

  $UserModelIdCopyWith<$Res> get id;
}

/// @nodoc
class _$RemoteUserModelCopyWithImpl<$Res, $Val extends RemoteUserModel>
    implements $RemoteUserModelCopyWith<$Res> {
  _$RemoteUserModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as UserModelId,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $UserModelIdCopyWith<$Res> get id {
    return $UserModelIdCopyWith<$Res>(_value.id, (value) {
      return _then(_value.copyWith(id: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RemoteUserModelImplCopyWith<$Res>
    implements $RemoteUserModelCopyWith<$Res> {
  factory _$$RemoteUserModelImplCopyWith(_$RemoteUserModelImpl value,
          $Res Function(_$RemoteUserModelImpl) then) =
      __$$RemoteUserModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({UserModelId id});

  @override
  $UserModelIdCopyWith<$Res> get id;
}

/// @nodoc
class __$$RemoteUserModelImplCopyWithImpl<$Res>
    extends _$RemoteUserModelCopyWithImpl<$Res, _$RemoteUserModelImpl>
    implements _$$RemoteUserModelImplCopyWith<$Res> {
  __$$RemoteUserModelImplCopyWithImpl(
      _$RemoteUserModelImpl _value, $Res Function(_$RemoteUserModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
  }) {
    return _then(_$RemoteUserModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as UserModelId,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$RemoteUserModelImpl extends _RemoteUserModel {
  const _$RemoteUserModelImpl({this.id = UserModelId.empty}) : super._();

  factory _$RemoteUserModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$RemoteUserModelImplFromJson(json);

  @override
  @JsonKey()
  final UserModelId id;

  @override
  String toString() {
    return 'RemoteUserModel(id: $id)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RemoteUserModelImpl &&
            (identical(other.id, id) || other.id == id));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RemoteUserModelImplCopyWith<_$RemoteUserModelImpl> get copyWith =>
      __$$RemoteUserModelImplCopyWithImpl<_$RemoteUserModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RemoteUserModelImplToJson(
      this,
    );
  }
}

abstract class _RemoteUserModel extends RemoteUserModel {
  const factory _RemoteUserModel({final UserModelId id}) =
      _$RemoteUserModelImpl;
  const _RemoteUserModel._() : super._();

  factory _RemoteUserModel.fromJson(Map<String, dynamic> json) =
      _$RemoteUserModelImpl.fromJson;

  @override
  UserModelId get id;
  @override
  @JsonKey(ignore: true)
  _$$RemoteUserModelImplCopyWith<_$RemoteUserModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PurchasesModel _$PurchasesModelFromJson(Map<String, dynamic> json) {
  return _PurchasesModel.fromJson(json);
}

/// @nodoc
mixin _$PurchasesModel {
  /// If user purchased the app for one time
  /// he should have all access indefinitely
  ///
  /// Priority one to develop.
  bool get isOneTimePurchased => throw _privateConstructorUsedError;

  /// If user purchased the app for subscription
  /// then he should have access until the end of subscription
  DateTime? get subscriptionEndDate => throw _privateConstructorUsedError;

  /// If user purchased certain amount of days
  /// then he should have access until [daysOfSupporterLeft] > 0
  int get daysOfSupporterLeft => throw _privateConstructorUsedError;

  /// Summary of any supporter days that user had.
  /// This is a sum of all [daysOfSupporterLeft] or
  /// received by subscription [subscriptionEndDate] that
  /// was used.
  int get supporterDaysCount => throw _privateConstructorUsedError;
  int get usedDaysCount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PurchasesModelCopyWith<PurchasesModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PurchasesModelCopyWith<$Res> {
  factory $PurchasesModelCopyWith(
          PurchasesModel value, $Res Function(PurchasesModel) then) =
      _$PurchasesModelCopyWithImpl<$Res, PurchasesModel>;
  @useResult
  $Res call(
      {bool isOneTimePurchased,
      DateTime? subscriptionEndDate,
      int daysOfSupporterLeft,
      int supporterDaysCount,
      int usedDaysCount});
}

/// @nodoc
class _$PurchasesModelCopyWithImpl<$Res, $Val extends PurchasesModel>
    implements $PurchasesModelCopyWith<$Res> {
  _$PurchasesModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isOneTimePurchased = null,
    Object? subscriptionEndDate = freezed,
    Object? daysOfSupporterLeft = null,
    Object? supporterDaysCount = null,
    Object? usedDaysCount = null,
  }) {
    return _then(_value.copyWith(
      isOneTimePurchased: null == isOneTimePurchased
          ? _value.isOneTimePurchased
          : isOneTimePurchased // ignore: cast_nullable_to_non_nullable
              as bool,
      subscriptionEndDate: freezed == subscriptionEndDate
          ? _value.subscriptionEndDate
          : subscriptionEndDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      daysOfSupporterLeft: null == daysOfSupporterLeft
          ? _value.daysOfSupporterLeft
          : daysOfSupporterLeft // ignore: cast_nullable_to_non_nullable
              as int,
      supporterDaysCount: null == supporterDaysCount
          ? _value.supporterDaysCount
          : supporterDaysCount // ignore: cast_nullable_to_non_nullable
              as int,
      usedDaysCount: null == usedDaysCount
          ? _value.usedDaysCount
          : usedDaysCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PurchasesModelImplCopyWith<$Res>
    implements $PurchasesModelCopyWith<$Res> {
  factory _$$PurchasesModelImplCopyWith(_$PurchasesModelImpl value,
          $Res Function(_$PurchasesModelImpl) then) =
      __$$PurchasesModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isOneTimePurchased,
      DateTime? subscriptionEndDate,
      int daysOfSupporterLeft,
      int supporterDaysCount,
      int usedDaysCount});
}

/// @nodoc
class __$$PurchasesModelImplCopyWithImpl<$Res>
    extends _$PurchasesModelCopyWithImpl<$Res, _$PurchasesModelImpl>
    implements _$$PurchasesModelImplCopyWith<$Res> {
  __$$PurchasesModelImplCopyWithImpl(
      _$PurchasesModelImpl _value, $Res Function(_$PurchasesModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isOneTimePurchased = null,
    Object? subscriptionEndDate = freezed,
    Object? daysOfSupporterLeft = null,
    Object? supporterDaysCount = null,
    Object? usedDaysCount = null,
  }) {
    return _then(_$PurchasesModelImpl(
      isOneTimePurchased: null == isOneTimePurchased
          ? _value.isOneTimePurchased
          : isOneTimePurchased // ignore: cast_nullable_to_non_nullable
              as bool,
      subscriptionEndDate: freezed == subscriptionEndDate
          ? _value.subscriptionEndDate
          : subscriptionEndDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      daysOfSupporterLeft: null == daysOfSupporterLeft
          ? _value.daysOfSupporterLeft
          : daysOfSupporterLeft // ignore: cast_nullable_to_non_nullable
              as int,
      supporterDaysCount: null == supporterDaysCount
          ? _value.supporterDaysCount
          : supporterDaysCount // ignore: cast_nullable_to_non_nullable
              as int,
      usedDaysCount: null == usedDaysCount
          ? _value.usedDaysCount
          : usedDaysCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$PurchasesModelImpl extends _PurchasesModel {
  const _$PurchasesModelImpl(
      {this.isOneTimePurchased = false,
      this.subscriptionEndDate,
      this.daysOfSupporterLeft = 0,
      this.supporterDaysCount = 0,
      this.usedDaysCount = 0})
      : super._();

  factory _$PurchasesModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PurchasesModelImplFromJson(json);

  /// If user purchased the app for one time
  /// he should have all access indefinitely
  ///
  /// Priority one to develop.
  @override
  @JsonKey()
  final bool isOneTimePurchased;

  /// If user purchased the app for subscription
  /// then he should have access until the end of subscription
  @override
  final DateTime? subscriptionEndDate;

  /// If user purchased certain amount of days
  /// then he should have access until [daysOfSupporterLeft] > 0
  @override
  @JsonKey()
  final int daysOfSupporterLeft;

  /// Summary of any supporter days that user had.
  /// This is a sum of all [daysOfSupporterLeft] or
  /// received by subscription [subscriptionEndDate] that
  /// was used.
  @override
  @JsonKey()
  final int supporterDaysCount;
  @override
  @JsonKey()
  final int usedDaysCount;

  @override
  String toString() {
    return 'PurchasesModel(isOneTimePurchased: $isOneTimePurchased, subscriptionEndDate: $subscriptionEndDate, daysOfSupporterLeft: $daysOfSupporterLeft, supporterDaysCount: $supporterDaysCount, usedDaysCount: $usedDaysCount)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PurchasesModelImpl &&
            (identical(other.isOneTimePurchased, isOneTimePurchased) ||
                other.isOneTimePurchased == isOneTimePurchased) &&
            (identical(other.subscriptionEndDate, subscriptionEndDate) ||
                other.subscriptionEndDate == subscriptionEndDate) &&
            (identical(other.daysOfSupporterLeft, daysOfSupporterLeft) ||
                other.daysOfSupporterLeft == daysOfSupporterLeft) &&
            (identical(other.supporterDaysCount, supporterDaysCount) ||
                other.supporterDaysCount == supporterDaysCount) &&
            (identical(other.usedDaysCount, usedDaysCount) ||
                other.usedDaysCount == usedDaysCount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      isOneTimePurchased,
      subscriptionEndDate,
      daysOfSupporterLeft,
      supporterDaysCount,
      usedDaysCount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PurchasesModelImplCopyWith<_$PurchasesModelImpl> get copyWith =>
      __$$PurchasesModelImplCopyWithImpl<_$PurchasesModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PurchasesModelImplToJson(
      this,
    );
  }
}

abstract class _PurchasesModel extends PurchasesModel {
  const factory _PurchasesModel(
      {final bool isOneTimePurchased,
      final DateTime? subscriptionEndDate,
      final int daysOfSupporterLeft,
      final int supporterDaysCount,
      final int usedDaysCount}) = _$PurchasesModelImpl;
  const _PurchasesModel._() : super._();

  factory _PurchasesModel.fromJson(Map<String, dynamic> json) =
      _$PurchasesModelImpl.fromJson;

  @override

  /// If user purchased the app for one time
  /// he should have all access indefinitely
  ///
  /// Priority one to develop.
  bool get isOneTimePurchased;
  @override

  /// If user purchased the app for subscription
  /// then he should have access until the end of subscription
  DateTime? get subscriptionEndDate;
  @override

  /// If user purchased certain amount of days
  /// then he should have access until [daysOfSupporterLeft] > 0
  int get daysOfSupporterLeft;
  @override

  /// Summary of any supporter days that user had.
  /// This is a sum of all [daysOfSupporterLeft] or
  /// received by subscription [subscriptionEndDate] that
  /// was used.
  int get supporterDaysCount;
  @override
  int get usedDaysCount;
  @override
  @JsonKey(ignore: true)
  _$$PurchasesModelImplCopyWith<_$PurchasesModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AdsStateModel _$AdsStateModelFromJson(Map<String, dynamic> json) {
  return _AdsStateModel.fromJson(json);
}

/// @nodoc
mixin _$AdsStateModel {
  DateTime? get lastDateWhenAdRewardReceived =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AdsStateModelCopyWith<AdsStateModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdsStateModelCopyWith<$Res> {
  factory $AdsStateModelCopyWith(
          AdsStateModel value, $Res Function(AdsStateModel) then) =
      _$AdsStateModelCopyWithImpl<$Res, AdsStateModel>;
  @useResult
  $Res call({DateTime? lastDateWhenAdRewardReceived});
}

/// @nodoc
class _$AdsStateModelCopyWithImpl<$Res, $Val extends AdsStateModel>
    implements $AdsStateModelCopyWith<$Res> {
  _$AdsStateModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lastDateWhenAdRewardReceived = freezed,
  }) {
    return _then(_value.copyWith(
      lastDateWhenAdRewardReceived: freezed == lastDateWhenAdRewardReceived
          ? _value.lastDateWhenAdRewardReceived
          : lastDateWhenAdRewardReceived // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AdsStateModelImplCopyWith<$Res>
    implements $AdsStateModelCopyWith<$Res> {
  factory _$$AdsStateModelImplCopyWith(
          _$AdsStateModelImpl value, $Res Function(_$AdsStateModelImpl) then) =
      __$$AdsStateModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime? lastDateWhenAdRewardReceived});
}

/// @nodoc
class __$$AdsStateModelImplCopyWithImpl<$Res>
    extends _$AdsStateModelCopyWithImpl<$Res, _$AdsStateModelImpl>
    implements _$$AdsStateModelImplCopyWith<$Res> {
  __$$AdsStateModelImplCopyWithImpl(
      _$AdsStateModelImpl _value, $Res Function(_$AdsStateModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lastDateWhenAdRewardReceived = freezed,
  }) {
    return _then(_$AdsStateModelImpl(
      lastDateWhenAdRewardReceived: freezed == lastDateWhenAdRewardReceived
          ? _value.lastDateWhenAdRewardReceived
          : lastDateWhenAdRewardReceived // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AdsStateModelImpl implements _AdsStateModel {
  const _$AdsStateModelImpl({this.lastDateWhenAdRewardReceived});

  factory _$AdsStateModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AdsStateModelImplFromJson(json);

  @override
  final DateTime? lastDateWhenAdRewardReceived;

  @override
  String toString() {
    return 'AdsStateModel(lastDateWhenAdRewardReceived: $lastDateWhenAdRewardReceived)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdsStateModelImpl &&
            (identical(other.lastDateWhenAdRewardReceived,
                    lastDateWhenAdRewardReceived) ||
                other.lastDateWhenAdRewardReceived ==
                    lastDateWhenAdRewardReceived));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, lastDateWhenAdRewardReceived);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AdsStateModelImplCopyWith<_$AdsStateModelImpl> get copyWith =>
      __$$AdsStateModelImplCopyWithImpl<_$AdsStateModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AdsStateModelImplToJson(
      this,
    );
  }
}

abstract class _AdsStateModel implements AdsStateModel {
  const factory _AdsStateModel({final DateTime? lastDateWhenAdRewardReceived}) =
      _$AdsStateModelImpl;

  factory _AdsStateModel.fromJson(Map<String, dynamic> json) =
      _$AdsStateModelImpl.fromJson;

  @override
  DateTime? get lastDateWhenAdRewardReceived;
  @override
  @JsonKey(ignore: true)
  _$$AdsStateModelImplCopyWith<_$AdsStateModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$UserModelId {
  String get value => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $UserModelIdCopyWith<UserModelId> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserModelIdCopyWith<$Res> {
  factory $UserModelIdCopyWith(
          UserModelId value, $Res Function(UserModelId) then) =
      _$UserModelIdCopyWithImpl<$Res, UserModelId>;
  @useResult
  $Res call({String value});
}

/// @nodoc
class _$UserModelIdCopyWithImpl<$Res, $Val extends UserModelId>
    implements $UserModelIdCopyWith<$Res> {
  _$UserModelIdCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
  }) {
    return _then(_value.copyWith(
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserModelIdImplCopyWith<$Res>
    implements $UserModelIdCopyWith<$Res> {
  factory _$$UserModelIdImplCopyWith(
          _$UserModelIdImpl value, $Res Function(_$UserModelIdImpl) then) =
      __$$UserModelIdImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String value});
}

/// @nodoc
class __$$UserModelIdImplCopyWithImpl<$Res>
    extends _$UserModelIdCopyWithImpl<$Res, _$UserModelIdImpl>
    implements _$$UserModelIdImplCopyWith<$Res> {
  __$$UserModelIdImplCopyWithImpl(
      _$UserModelIdImpl _value, $Res Function(_$UserModelIdImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
  }) {
    return _then(_$UserModelIdImpl(
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$UserModelIdImpl extends _UserModelId {
  const _$UserModelIdImpl({required this.value}) : super._();

  @override
  final String value;

  @override
  String toString() {
    return 'UserModelId(value: $value)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserModelIdImpl &&
            (identical(other.value, value) || other.value == value));
  }

  @override
  int get hashCode => Object.hash(runtimeType, value);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserModelIdImplCopyWith<_$UserModelIdImpl> get copyWith =>
      __$$UserModelIdImplCopyWithImpl<_$UserModelIdImpl>(this, _$identity);
}

abstract class _UserModelId extends UserModelId {
  const factory _UserModelId({required final String value}) = _$UserModelIdImpl;
  const _UserModelId._() : super._();

  @override
  String get value;
  @override
  @JsonKey(ignore: true)
  _$$UserModelIdImplCopyWith<_$UserModelIdImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
