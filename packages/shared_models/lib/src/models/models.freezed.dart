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

PurchaseModel _$PurchaseModelFromJson(Map<String, dynamic> json) {
  switch (json['type']) {
    case 'oneTime':
      return PurchaseModelOneTime.fromJson(json);
    case 'subscription':
      return PurchaseModelSubscription.fromJson(json);

    default:
      throw CheckedFromJsonException(json, 'type', 'PurchaseModel',
          'Invalid union type "${json['type']}"!');
  }
}

/// @nodoc
mixin _$PurchaseModel {
  IAPId get productId => throw _privateConstructorUsedError;
  PurchasePaymentProvider get paymentProvider =>
      throw _privateConstructorUsedError;
  String get originalTransactionID => throw _privateConstructorUsedError;
  DateTime? get purchasedAt => throw _privateConstructorUsedError;

  /// can contain symbol, so it's not double
  String get price => throw _privateConstructorUsedError;
  PurchasePeriod get period => throw _privateConstructorUsedError;
  PurchaseAttributesModel get attributes => throw _privateConstructorUsedError;
  DateTime? get willExpireAt => throw _privateConstructorUsedError;
  UserModelId get userId => throw _privateConstructorUsedError;
  ProductType get type => throw _privateConstructorUsedError;
  Enum get status => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            IAPId productId,
            PurchasePaymentProvider paymentProvider,
            String originalTransactionID,
            DateTime? purchasedAt,
            String price,
            PurchasePeriod period,
            PurchaseAttributesModel attributes,
            DateTime? willExpireAt,
            UserModelId userId,
            ProductType type,
            OneTimePurchaseStatus status)
        oneTime,
    required TResult Function(
            IAPId productId,
            PurchasePaymentProvider paymentProvider,
            String originalTransactionID,
            DateTime? purchasedAt,
            String price,
            PurchasePeriod period,
            PurchaseAttributesModel attributes,
            DateTime? willExpireAt,
            UserModelId userId,
            ProductType type,
            SubscriptionStatus status)
        subscription,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            IAPId productId,
            PurchasePaymentProvider paymentProvider,
            String originalTransactionID,
            DateTime? purchasedAt,
            String price,
            PurchasePeriod period,
            PurchaseAttributesModel attributes,
            DateTime? willExpireAt,
            UserModelId userId,
            ProductType type,
            OneTimePurchaseStatus status)?
        oneTime,
    TResult? Function(
            IAPId productId,
            PurchasePaymentProvider paymentProvider,
            String originalTransactionID,
            DateTime? purchasedAt,
            String price,
            PurchasePeriod period,
            PurchaseAttributesModel attributes,
            DateTime? willExpireAt,
            UserModelId userId,
            ProductType type,
            SubscriptionStatus status)?
        subscription,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            IAPId productId,
            PurchasePaymentProvider paymentProvider,
            String originalTransactionID,
            DateTime? purchasedAt,
            String price,
            PurchasePeriod period,
            PurchaseAttributesModel attributes,
            DateTime? willExpireAt,
            UserModelId userId,
            ProductType type,
            OneTimePurchaseStatus status)?
        oneTime,
    TResult Function(
            IAPId productId,
            PurchasePaymentProvider paymentProvider,
            String originalTransactionID,
            DateTime? purchasedAt,
            String price,
            PurchasePeriod period,
            PurchaseAttributesModel attributes,
            DateTime? willExpireAt,
            UserModelId userId,
            ProductType type,
            SubscriptionStatus status)?
        subscription,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PurchaseModelOneTime value) oneTime,
    required TResult Function(PurchaseModelSubscription value) subscription,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PurchaseModelOneTime value)? oneTime,
    TResult? Function(PurchaseModelSubscription value)? subscription,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PurchaseModelOneTime value)? oneTime,
    TResult Function(PurchaseModelSubscription value)? subscription,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PurchaseModelCopyWith<PurchaseModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PurchaseModelCopyWith<$Res> {
  factory $PurchaseModelCopyWith(
          PurchaseModel value, $Res Function(PurchaseModel) then) =
      _$PurchaseModelCopyWithImpl<$Res, PurchaseModel>;
  @useResult
  $Res call(
      {IAPId productId,
      PurchasePaymentProvider paymentProvider,
      String originalTransactionID,
      DateTime? purchasedAt,
      String price,
      PurchasePeriod period,
      PurchaseAttributesModel attributes,
      DateTime? willExpireAt,
      UserModelId userId,
      ProductType type});

  $PurchaseAttributesModelCopyWith<$Res> get attributes;
  $UserModelIdCopyWith<$Res> get userId;
}

/// @nodoc
class _$PurchaseModelCopyWithImpl<$Res, $Val extends PurchaseModel>
    implements $PurchaseModelCopyWith<$Res> {
  _$PurchaseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? paymentProvider = null,
    Object? originalTransactionID = null,
    Object? purchasedAt = freezed,
    Object? price = null,
    Object? period = null,
    Object? attributes = null,
    Object? willExpireAt = freezed,
    Object? userId = null,
    Object? type = null,
  }) {
    return _then(_value.copyWith(
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as IAPId,
      paymentProvider: null == paymentProvider
          ? _value.paymentProvider
          : paymentProvider // ignore: cast_nullable_to_non_nullable
              as PurchasePaymentProvider,
      originalTransactionID: null == originalTransactionID
          ? _value.originalTransactionID
          : originalTransactionID // ignore: cast_nullable_to_non_nullable
              as String,
      purchasedAt: freezed == purchasedAt
          ? _value.purchasedAt
          : purchasedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as String,
      period: null == period
          ? _value.period
          : period // ignore: cast_nullable_to_non_nullable
              as PurchasePeriod,
      attributes: null == attributes
          ? _value.attributes
          : attributes // ignore: cast_nullable_to_non_nullable
              as PurchaseAttributesModel,
      willExpireAt: freezed == willExpireAt
          ? _value.willExpireAt
          : willExpireAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as UserModelId,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ProductType,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $PurchaseAttributesModelCopyWith<$Res> get attributes {
    return $PurchaseAttributesModelCopyWith<$Res>(_value.attributes, (value) {
      return _then(_value.copyWith(attributes: value) as $Val);
    });
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
abstract class _$$PurchaseModelOneTimeImplCopyWith<$Res>
    implements $PurchaseModelCopyWith<$Res> {
  factory _$$PurchaseModelOneTimeImplCopyWith(_$PurchaseModelOneTimeImpl value,
          $Res Function(_$PurchaseModelOneTimeImpl) then) =
      __$$PurchaseModelOneTimeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {IAPId productId,
      PurchasePaymentProvider paymentProvider,
      String originalTransactionID,
      DateTime? purchasedAt,
      String price,
      PurchasePeriod period,
      PurchaseAttributesModel attributes,
      DateTime? willExpireAt,
      UserModelId userId,
      ProductType type,
      OneTimePurchaseStatus status});

  @override
  $PurchaseAttributesModelCopyWith<$Res> get attributes;
  @override
  $UserModelIdCopyWith<$Res> get userId;
}

/// @nodoc
class __$$PurchaseModelOneTimeImplCopyWithImpl<$Res>
    extends _$PurchaseModelCopyWithImpl<$Res, _$PurchaseModelOneTimeImpl>
    implements _$$PurchaseModelOneTimeImplCopyWith<$Res> {
  __$$PurchaseModelOneTimeImplCopyWithImpl(_$PurchaseModelOneTimeImpl _value,
      $Res Function(_$PurchaseModelOneTimeImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? paymentProvider = null,
    Object? originalTransactionID = null,
    Object? purchasedAt = freezed,
    Object? price = null,
    Object? period = null,
    Object? attributes = null,
    Object? willExpireAt = freezed,
    Object? userId = null,
    Object? type = null,
    Object? status = null,
  }) {
    return _then(_$PurchaseModelOneTimeImpl(
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as IAPId,
      paymentProvider: null == paymentProvider
          ? _value.paymentProvider
          : paymentProvider // ignore: cast_nullable_to_non_nullable
              as PurchasePaymentProvider,
      originalTransactionID: null == originalTransactionID
          ? _value.originalTransactionID
          : originalTransactionID // ignore: cast_nullable_to_non_nullable
              as String,
      purchasedAt: freezed == purchasedAt
          ? _value.purchasedAt
          : purchasedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as String,
      period: null == period
          ? _value.period
          : period // ignore: cast_nullable_to_non_nullable
              as PurchasePeriod,
      attributes: null == attributes
          ? _value.attributes
          : attributes // ignore: cast_nullable_to_non_nullable
              as PurchaseAttributesModel,
      willExpireAt: freezed == willExpireAt
          ? _value.willExpireAt
          : willExpireAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as UserModelId,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ProductType,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as OneTimePurchaseStatus,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PurchaseModelOneTimeImpl extends PurchaseModelOneTime {
  const _$PurchaseModelOneTimeImpl(
      {this.productId = IAPId.proOneTimePurchase,
      this.paymentProvider = PurchasePaymentProvider.googlePlay,
      this.originalTransactionID = '',
      this.purchasedAt,
      this.price = '',
      this.period = PurchasePeriod.monthly,
      this.attributes = PurchaseAttributesModel.empty,
      this.willExpireAt,
      this.userId = UserModelId.empty,
      this.type = ProductType.oneTime,
      this.status = OneTimePurchaseStatus.pending})
      : super._();

  factory _$PurchaseModelOneTimeImpl.fromJson(Map<String, dynamic> json) =>
      _$$PurchaseModelOneTimeImplFromJson(json);

  @override
  @JsonKey()
  final IAPId productId;
  @override
  @JsonKey()
  final PurchasePaymentProvider paymentProvider;
  @override
  @JsonKey()
  final String originalTransactionID;
  @override
  final DateTime? purchasedAt;

  /// can contain symbol, so it's not double
  @override
  @JsonKey()
  final String price;
  @override
  @JsonKey()
  final PurchasePeriod period;
  @override
  @JsonKey()
  final PurchaseAttributesModel attributes;
  @override
  final DateTime? willExpireAt;
  @override
  @JsonKey()
  final UserModelId userId;
  @override
  @JsonKey()
  final ProductType type;
  @override
  @JsonKey()
  final OneTimePurchaseStatus status;

  @override
  String toString() {
    return 'PurchaseModel.oneTime(productId: $productId, paymentProvider: $paymentProvider, originalTransactionID: $originalTransactionID, purchasedAt: $purchasedAt, price: $price, period: $period, attributes: $attributes, willExpireAt: $willExpireAt, userId: $userId, type: $type, status: $status)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PurchaseModelOneTimeImpl &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.paymentProvider, paymentProvider) ||
                other.paymentProvider == paymentProvider) &&
            (identical(other.originalTransactionID, originalTransactionID) ||
                other.originalTransactionID == originalTransactionID) &&
            (identical(other.purchasedAt, purchasedAt) ||
                other.purchasedAt == purchasedAt) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.period, period) || other.period == period) &&
            (identical(other.attributes, attributes) ||
                other.attributes == attributes) &&
            (identical(other.willExpireAt, willExpireAt) ||
                other.willExpireAt == willExpireAt) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      productId,
      paymentProvider,
      originalTransactionID,
      purchasedAt,
      price,
      period,
      attributes,
      willExpireAt,
      userId,
      type,
      status);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PurchaseModelOneTimeImplCopyWith<_$PurchaseModelOneTimeImpl>
      get copyWith =>
          __$$PurchaseModelOneTimeImplCopyWithImpl<_$PurchaseModelOneTimeImpl>(
              this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            IAPId productId,
            PurchasePaymentProvider paymentProvider,
            String originalTransactionID,
            DateTime? purchasedAt,
            String price,
            PurchasePeriod period,
            PurchaseAttributesModel attributes,
            DateTime? willExpireAt,
            UserModelId userId,
            ProductType type,
            OneTimePurchaseStatus status)
        oneTime,
    required TResult Function(
            IAPId productId,
            PurchasePaymentProvider paymentProvider,
            String originalTransactionID,
            DateTime? purchasedAt,
            String price,
            PurchasePeriod period,
            PurchaseAttributesModel attributes,
            DateTime? willExpireAt,
            UserModelId userId,
            ProductType type,
            SubscriptionStatus status)
        subscription,
  }) {
    return oneTime(
        productId,
        paymentProvider,
        originalTransactionID,
        purchasedAt,
        price,
        period,
        attributes,
        willExpireAt,
        userId,
        type,
        status);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            IAPId productId,
            PurchasePaymentProvider paymentProvider,
            String originalTransactionID,
            DateTime? purchasedAt,
            String price,
            PurchasePeriod period,
            PurchaseAttributesModel attributes,
            DateTime? willExpireAt,
            UserModelId userId,
            ProductType type,
            OneTimePurchaseStatus status)?
        oneTime,
    TResult? Function(
            IAPId productId,
            PurchasePaymentProvider paymentProvider,
            String originalTransactionID,
            DateTime? purchasedAt,
            String price,
            PurchasePeriod period,
            PurchaseAttributesModel attributes,
            DateTime? willExpireAt,
            UserModelId userId,
            ProductType type,
            SubscriptionStatus status)?
        subscription,
  }) {
    return oneTime?.call(
        productId,
        paymentProvider,
        originalTransactionID,
        purchasedAt,
        price,
        period,
        attributes,
        willExpireAt,
        userId,
        type,
        status);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            IAPId productId,
            PurchasePaymentProvider paymentProvider,
            String originalTransactionID,
            DateTime? purchasedAt,
            String price,
            PurchasePeriod period,
            PurchaseAttributesModel attributes,
            DateTime? willExpireAt,
            UserModelId userId,
            ProductType type,
            OneTimePurchaseStatus status)?
        oneTime,
    TResult Function(
            IAPId productId,
            PurchasePaymentProvider paymentProvider,
            String originalTransactionID,
            DateTime? purchasedAt,
            String price,
            PurchasePeriod period,
            PurchaseAttributesModel attributes,
            DateTime? willExpireAt,
            UserModelId userId,
            ProductType type,
            SubscriptionStatus status)?
        subscription,
    required TResult orElse(),
  }) {
    if (oneTime != null) {
      return oneTime(
          productId,
          paymentProvider,
          originalTransactionID,
          purchasedAt,
          price,
          period,
          attributes,
          willExpireAt,
          userId,
          type,
          status);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PurchaseModelOneTime value) oneTime,
    required TResult Function(PurchaseModelSubscription value) subscription,
  }) {
    return oneTime(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PurchaseModelOneTime value)? oneTime,
    TResult? Function(PurchaseModelSubscription value)? subscription,
  }) {
    return oneTime?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PurchaseModelOneTime value)? oneTime,
    TResult Function(PurchaseModelSubscription value)? subscription,
    required TResult orElse(),
  }) {
    if (oneTime != null) {
      return oneTime(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$PurchaseModelOneTimeImplToJson(
      this,
    );
  }
}

abstract class PurchaseModelOneTime extends PurchaseModel {
  const factory PurchaseModelOneTime(
      {final IAPId productId,
      final PurchasePaymentProvider paymentProvider,
      final String originalTransactionID,
      final DateTime? purchasedAt,
      final String price,
      final PurchasePeriod period,
      final PurchaseAttributesModel attributes,
      final DateTime? willExpireAt,
      final UserModelId userId,
      final ProductType type,
      final OneTimePurchaseStatus status}) = _$PurchaseModelOneTimeImpl;
  const PurchaseModelOneTime._() : super._();

  factory PurchaseModelOneTime.fromJson(Map<String, dynamic> json) =
      _$PurchaseModelOneTimeImpl.fromJson;

  @override
  IAPId get productId;
  @override
  PurchasePaymentProvider get paymentProvider;
  @override
  String get originalTransactionID;
  @override
  DateTime? get purchasedAt;
  @override

  /// can contain symbol, so it's not double
  String get price;
  @override
  PurchasePeriod get period;
  @override
  PurchaseAttributesModel get attributes;
  @override
  DateTime? get willExpireAt;
  @override
  UserModelId get userId;
  @override
  ProductType get type;
  @override
  OneTimePurchaseStatus get status;
  @override
  @JsonKey(ignore: true)
  _$$PurchaseModelOneTimeImplCopyWith<_$PurchaseModelOneTimeImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PurchaseModelSubscriptionImplCopyWith<$Res>
    implements $PurchaseModelCopyWith<$Res> {
  factory _$$PurchaseModelSubscriptionImplCopyWith(
          _$PurchaseModelSubscriptionImpl value,
          $Res Function(_$PurchaseModelSubscriptionImpl) then) =
      __$$PurchaseModelSubscriptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {IAPId productId,
      PurchasePaymentProvider paymentProvider,
      String originalTransactionID,
      DateTime? purchasedAt,
      String price,
      PurchasePeriod period,
      PurchaseAttributesModel attributes,
      DateTime? willExpireAt,
      UserModelId userId,
      ProductType type,
      SubscriptionStatus status});

  @override
  $PurchaseAttributesModelCopyWith<$Res> get attributes;
  @override
  $UserModelIdCopyWith<$Res> get userId;
}

/// @nodoc
class __$$PurchaseModelSubscriptionImplCopyWithImpl<$Res>
    extends _$PurchaseModelCopyWithImpl<$Res, _$PurchaseModelSubscriptionImpl>
    implements _$$PurchaseModelSubscriptionImplCopyWith<$Res> {
  __$$PurchaseModelSubscriptionImplCopyWithImpl(
      _$PurchaseModelSubscriptionImpl _value,
      $Res Function(_$PurchaseModelSubscriptionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? paymentProvider = null,
    Object? originalTransactionID = null,
    Object? purchasedAt = freezed,
    Object? price = null,
    Object? period = null,
    Object? attributes = null,
    Object? willExpireAt = freezed,
    Object? userId = null,
    Object? type = null,
    Object? status = null,
  }) {
    return _then(_$PurchaseModelSubscriptionImpl(
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as IAPId,
      paymentProvider: null == paymentProvider
          ? _value.paymentProvider
          : paymentProvider // ignore: cast_nullable_to_non_nullable
              as PurchasePaymentProvider,
      originalTransactionID: null == originalTransactionID
          ? _value.originalTransactionID
          : originalTransactionID // ignore: cast_nullable_to_non_nullable
              as String,
      purchasedAt: freezed == purchasedAt
          ? _value.purchasedAt
          : purchasedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as String,
      period: null == period
          ? _value.period
          : period // ignore: cast_nullable_to_non_nullable
              as PurchasePeriod,
      attributes: null == attributes
          ? _value.attributes
          : attributes // ignore: cast_nullable_to_non_nullable
              as PurchaseAttributesModel,
      willExpireAt: freezed == willExpireAt
          ? _value.willExpireAt
          : willExpireAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as UserModelId,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ProductType,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as SubscriptionStatus,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PurchaseModelSubscriptionImpl extends PurchaseModelSubscription {
  const _$PurchaseModelSubscriptionImpl(
      {this.productId = IAPId.proOneTimePurchase,
      this.paymentProvider = PurchasePaymentProvider.googlePlay,
      this.originalTransactionID = '',
      this.purchasedAt,
      this.price = '',
      this.period = PurchasePeriod.monthly,
      this.attributes = PurchaseAttributesModel.empty,
      this.willExpireAt,
      this.userId = UserModelId.empty,
      this.type = ProductType.subscription,
      this.status = SubscriptionStatus.pending})
      : super._();

  factory _$PurchaseModelSubscriptionImpl.fromJson(Map<String, dynamic> json) =>
      _$$PurchaseModelSubscriptionImplFromJson(json);

  @override
  @JsonKey()
  final IAPId productId;
  @override
  @JsonKey()
  final PurchasePaymentProvider paymentProvider;
  @override
  @JsonKey()
  final String originalTransactionID;
  @override
  final DateTime? purchasedAt;

  /// can contain symbol, so it's not double
  @override
  @JsonKey()
  final String price;
  @override
  @JsonKey()
  final PurchasePeriod period;
  @override
  @JsonKey()
  final PurchaseAttributesModel attributes;
  @override
  final DateTime? willExpireAt;
  @override
  @JsonKey()
  final UserModelId userId;
  @override
  @JsonKey()
  final ProductType type;
  @override
  @JsonKey()
  final SubscriptionStatus status;

  @override
  String toString() {
    return 'PurchaseModel.subscription(productId: $productId, paymentProvider: $paymentProvider, originalTransactionID: $originalTransactionID, purchasedAt: $purchasedAt, price: $price, period: $period, attributes: $attributes, willExpireAt: $willExpireAt, userId: $userId, type: $type, status: $status)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PurchaseModelSubscriptionImpl &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.paymentProvider, paymentProvider) ||
                other.paymentProvider == paymentProvider) &&
            (identical(other.originalTransactionID, originalTransactionID) ||
                other.originalTransactionID == originalTransactionID) &&
            (identical(other.purchasedAt, purchasedAt) ||
                other.purchasedAt == purchasedAt) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.period, period) || other.period == period) &&
            (identical(other.attributes, attributes) ||
                other.attributes == attributes) &&
            (identical(other.willExpireAt, willExpireAt) ||
                other.willExpireAt == willExpireAt) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      productId,
      paymentProvider,
      originalTransactionID,
      purchasedAt,
      price,
      period,
      attributes,
      willExpireAt,
      userId,
      type,
      status);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PurchaseModelSubscriptionImplCopyWith<_$PurchaseModelSubscriptionImpl>
      get copyWith => __$$PurchaseModelSubscriptionImplCopyWithImpl<
          _$PurchaseModelSubscriptionImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            IAPId productId,
            PurchasePaymentProvider paymentProvider,
            String originalTransactionID,
            DateTime? purchasedAt,
            String price,
            PurchasePeriod period,
            PurchaseAttributesModel attributes,
            DateTime? willExpireAt,
            UserModelId userId,
            ProductType type,
            OneTimePurchaseStatus status)
        oneTime,
    required TResult Function(
            IAPId productId,
            PurchasePaymentProvider paymentProvider,
            String originalTransactionID,
            DateTime? purchasedAt,
            String price,
            PurchasePeriod period,
            PurchaseAttributesModel attributes,
            DateTime? willExpireAt,
            UserModelId userId,
            ProductType type,
            SubscriptionStatus status)
        subscription,
  }) {
    return subscription(
        productId,
        paymentProvider,
        originalTransactionID,
        purchasedAt,
        price,
        period,
        attributes,
        willExpireAt,
        userId,
        type,
        status);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            IAPId productId,
            PurchasePaymentProvider paymentProvider,
            String originalTransactionID,
            DateTime? purchasedAt,
            String price,
            PurchasePeriod period,
            PurchaseAttributesModel attributes,
            DateTime? willExpireAt,
            UserModelId userId,
            ProductType type,
            OneTimePurchaseStatus status)?
        oneTime,
    TResult? Function(
            IAPId productId,
            PurchasePaymentProvider paymentProvider,
            String originalTransactionID,
            DateTime? purchasedAt,
            String price,
            PurchasePeriod period,
            PurchaseAttributesModel attributes,
            DateTime? willExpireAt,
            UserModelId userId,
            ProductType type,
            SubscriptionStatus status)?
        subscription,
  }) {
    return subscription?.call(
        productId,
        paymentProvider,
        originalTransactionID,
        purchasedAt,
        price,
        period,
        attributes,
        willExpireAt,
        userId,
        type,
        status);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            IAPId productId,
            PurchasePaymentProvider paymentProvider,
            String originalTransactionID,
            DateTime? purchasedAt,
            String price,
            PurchasePeriod period,
            PurchaseAttributesModel attributes,
            DateTime? willExpireAt,
            UserModelId userId,
            ProductType type,
            OneTimePurchaseStatus status)?
        oneTime,
    TResult Function(
            IAPId productId,
            PurchasePaymentProvider paymentProvider,
            String originalTransactionID,
            DateTime? purchasedAt,
            String price,
            PurchasePeriod period,
            PurchaseAttributesModel attributes,
            DateTime? willExpireAt,
            UserModelId userId,
            ProductType type,
            SubscriptionStatus status)?
        subscription,
    required TResult orElse(),
  }) {
    if (subscription != null) {
      return subscription(
          productId,
          paymentProvider,
          originalTransactionID,
          purchasedAt,
          price,
          period,
          attributes,
          willExpireAt,
          userId,
          type,
          status);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PurchaseModelOneTime value) oneTime,
    required TResult Function(PurchaseModelSubscription value) subscription,
  }) {
    return subscription(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PurchaseModelOneTime value)? oneTime,
    TResult? Function(PurchaseModelSubscription value)? subscription,
  }) {
    return subscription?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PurchaseModelOneTime value)? oneTime,
    TResult Function(PurchaseModelSubscription value)? subscription,
    required TResult orElse(),
  }) {
    if (subscription != null) {
      return subscription(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$PurchaseModelSubscriptionImplToJson(
      this,
    );
  }
}

abstract class PurchaseModelSubscription extends PurchaseModel {
  const factory PurchaseModelSubscription(
      {final IAPId productId,
      final PurchasePaymentProvider paymentProvider,
      final String originalTransactionID,
      final DateTime? purchasedAt,
      final String price,
      final PurchasePeriod period,
      final PurchaseAttributesModel attributes,
      final DateTime? willExpireAt,
      final UserModelId userId,
      final ProductType type,
      final SubscriptionStatus status}) = _$PurchaseModelSubscriptionImpl;
  const PurchaseModelSubscription._() : super._();

  factory PurchaseModelSubscription.fromJson(Map<String, dynamic> json) =
      _$PurchaseModelSubscriptionImpl.fromJson;

  @override
  IAPId get productId;
  @override
  PurchasePaymentProvider get paymentProvider;
  @override
  String get originalTransactionID;
  @override
  DateTime? get purchasedAt;
  @override

  /// can contain symbol, so it's not double
  String get price;
  @override
  PurchasePeriod get period;
  @override
  PurchaseAttributesModel get attributes;
  @override
  DateTime? get willExpireAt;
  @override
  UserModelId get userId;
  @override
  ProductType get type;
  @override
  SubscriptionStatus get status;
  @override
  @JsonKey(ignore: true)
  _$$PurchaseModelSubscriptionImplCopyWith<_$PurchaseModelSubscriptionImpl>
      get copyWith => throw _privateConstructorUsedError;
}

PurchaseAttributesModel _$PurchaseAttributesModelFromJson(
    Map<String, dynamic> json) {
  return _PurchaseAttributesModel.fromJson(json);
}

/// @nodoc
mixin _$PurchaseAttributesModel {
  bool get isCancelled => throw _privateConstructorUsedError;
  UserModelId get customerId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PurchaseAttributesModelCopyWith<PurchaseAttributesModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PurchaseAttributesModelCopyWith<$Res> {
  factory $PurchaseAttributesModelCopyWith(PurchaseAttributesModel value,
          $Res Function(PurchaseAttributesModel) then) =
      _$PurchaseAttributesModelCopyWithImpl<$Res, PurchaseAttributesModel>;
  @useResult
  $Res call({bool isCancelled, UserModelId customerId});

  $UserModelIdCopyWith<$Res> get customerId;
}

/// @nodoc
class _$PurchaseAttributesModelCopyWithImpl<$Res,
        $Val extends PurchaseAttributesModel>
    implements $PurchaseAttributesModelCopyWith<$Res> {
  _$PurchaseAttributesModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isCancelled = null,
    Object? customerId = null,
  }) {
    return _then(_value.copyWith(
      isCancelled: null == isCancelled
          ? _value.isCancelled
          : isCancelled // ignore: cast_nullable_to_non_nullable
              as bool,
      customerId: null == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as UserModelId,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $UserModelIdCopyWith<$Res> get customerId {
    return $UserModelIdCopyWith<$Res>(_value.customerId, (value) {
      return _then(_value.copyWith(customerId: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PurchaseAttributesModelImplCopyWith<$Res>
    implements $PurchaseAttributesModelCopyWith<$Res> {
  factory _$$PurchaseAttributesModelImplCopyWith(
          _$PurchaseAttributesModelImpl value,
          $Res Function(_$PurchaseAttributesModelImpl) then) =
      __$$PurchaseAttributesModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool isCancelled, UserModelId customerId});

  @override
  $UserModelIdCopyWith<$Res> get customerId;
}

/// @nodoc
class __$$PurchaseAttributesModelImplCopyWithImpl<$Res>
    extends _$PurchaseAttributesModelCopyWithImpl<$Res,
        _$PurchaseAttributesModelImpl>
    implements _$$PurchaseAttributesModelImplCopyWith<$Res> {
  __$$PurchaseAttributesModelImplCopyWithImpl(
      _$PurchaseAttributesModelImpl _value,
      $Res Function(_$PurchaseAttributesModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isCancelled = null,
    Object? customerId = null,
  }) {
    return _then(_$PurchaseAttributesModelImpl(
      isCancelled: null == isCancelled
          ? _value.isCancelled
          : isCancelled // ignore: cast_nullable_to_non_nullable
              as bool,
      customerId: null == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as UserModelId,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PurchaseAttributesModelImpl implements _PurchaseAttributesModel {
  const _$PurchaseAttributesModelImpl(
      {this.isCancelled = false, this.customerId = UserModelId.empty});

  factory _$PurchaseAttributesModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PurchaseAttributesModelImplFromJson(json);

  @override
  @JsonKey()
  final bool isCancelled;
  @override
  @JsonKey()
  final UserModelId customerId;

  @override
  String toString() {
    return 'PurchaseAttributesModel(isCancelled: $isCancelled, customerId: $customerId)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PurchaseAttributesModelImpl &&
            (identical(other.isCancelled, isCancelled) ||
                other.isCancelled == isCancelled) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, isCancelled, customerId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PurchaseAttributesModelImplCopyWith<_$PurchaseAttributesModelImpl>
      get copyWith => __$$PurchaseAttributesModelImplCopyWithImpl<
          _$PurchaseAttributesModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PurchaseAttributesModelImplToJson(
      this,
    );
  }
}

abstract class _PurchaseAttributesModel implements PurchaseAttributesModel {
  const factory _PurchaseAttributesModel(
      {final bool isCancelled,
      final UserModelId customerId}) = _$PurchaseAttributesModelImpl;

  factory _PurchaseAttributesModel.fromJson(Map<String, dynamic> json) =
      _$PurchaseAttributesModelImpl.fromJson;

  @override
  bool get isCancelled;
  @override
  UserModelId get customerId;
  @override
  @JsonKey(ignore: true)
  _$$PurchaseAttributesModelImplCopyWith<_$PurchaseAttributesModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

RemoteUserModel _$RemoteUserModelFromJson(Map<String, dynamic> json) {
  return _RemoteUserModel.fromJson(json);
}

/// @nodoc
mixin _$RemoteUserModel {
  UserModelId get id => throw _privateConstructorUsedError;
  PurchasesModel get purchases => throw _privateConstructorUsedError;

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
  $Res call({UserModelId id, PurchasesModel purchases});

  $UserModelIdCopyWith<$Res> get id;
  $PurchasesModelCopyWith<$Res> get purchases;
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
    Object? purchases = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as UserModelId,
      purchases: null == purchases
          ? _value.purchases
          : purchases // ignore: cast_nullable_to_non_nullable
              as PurchasesModel,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $UserModelIdCopyWith<$Res> get id {
    return $UserModelIdCopyWith<$Res>(_value.id, (value) {
      return _then(_value.copyWith(id: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $PurchasesModelCopyWith<$Res> get purchases {
    return $PurchasesModelCopyWith<$Res>(_value.purchases, (value) {
      return _then(_value.copyWith(purchases: value) as $Val);
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
  $Res call({UserModelId id, PurchasesModel purchases});

  @override
  $UserModelIdCopyWith<$Res> get id;
  @override
  $PurchasesModelCopyWith<$Res> get purchases;
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
    Object? purchases = null,
  }) {
    return _then(_$RemoteUserModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as UserModelId,
      purchases: null == purchases
          ? _value.purchases
          : purchases // ignore: cast_nullable_to_non_nullable
              as PurchasesModel,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$RemoteUserModelImpl extends _RemoteUserModel {
  const _$RemoteUserModelImpl(
      {this.id = UserModelId.empty, this.purchases = PurchasesModel.empty})
      : super._();

  factory _$RemoteUserModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$RemoteUserModelImplFromJson(json);

  @override
  @JsonKey()
  final UserModelId id;
  @override
  @JsonKey()
  final PurchasesModel purchases;

  @override
  String toString() {
    return 'RemoteUserModel(id: $id, purchases: $purchases)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RemoteUserModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.purchases, purchases) ||
                other.purchases == purchases));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, purchases);

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
  const factory _RemoteUserModel(
      {final UserModelId id,
      final PurchasesModel purchases}) = _$RemoteUserModelImpl;
  const _RemoteUserModel._() : super._();

  factory _RemoteUserModel.fromJson(Map<String, dynamic> json) =
      _$RemoteUserModelImpl.fromJson;

  @override
  UserModelId get id;
  @override
  PurchasesModel get purchases;
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
  bool get hasOneTimePurchase => throw _privateConstructorUsedError;

  /// If user purchased the app for subscription
  /// then he should have access until the end of subscription
  DateTime? get subscriptionEndDate => throw _privateConstructorUsedError;

  /// If user purchased certain amount of days
  /// then he should have access until [purchasedDaysLeft] > 0
  int get purchasedDaysLeft => throw _privateConstructorUsedError;

  /// may be empty, for example in case if there is no payments made,
  /// or if user canceled subscription
  @JsonKey(fromJson: PurchaseModel.fromRawJson)
  PurchaseModel get activePurchase => throw _privateConstructorUsedError;

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
      {bool hasOneTimePurchase,
      DateTime? subscriptionEndDate,
      int purchasedDaysLeft,
      @JsonKey(fromJson: PurchaseModel.fromRawJson)
      PurchaseModel activePurchase});

  $PurchaseModelCopyWith<$Res> get activePurchase;
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
    Object? hasOneTimePurchase = null,
    Object? subscriptionEndDate = freezed,
    Object? purchasedDaysLeft = null,
    Object? activePurchase = null,
  }) {
    return _then(_value.copyWith(
      hasOneTimePurchase: null == hasOneTimePurchase
          ? _value.hasOneTimePurchase
          : hasOneTimePurchase // ignore: cast_nullable_to_non_nullable
              as bool,
      subscriptionEndDate: freezed == subscriptionEndDate
          ? _value.subscriptionEndDate
          : subscriptionEndDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      purchasedDaysLeft: null == purchasedDaysLeft
          ? _value.purchasedDaysLeft
          : purchasedDaysLeft // ignore: cast_nullable_to_non_nullable
              as int,
      activePurchase: null == activePurchase
          ? _value.activePurchase
          : activePurchase // ignore: cast_nullable_to_non_nullable
              as PurchaseModel,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $PurchaseModelCopyWith<$Res> get activePurchase {
    return $PurchaseModelCopyWith<$Res>(_value.activePurchase, (value) {
      return _then(_value.copyWith(activePurchase: value) as $Val);
    });
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
      {bool hasOneTimePurchase,
      DateTime? subscriptionEndDate,
      int purchasedDaysLeft,
      @JsonKey(fromJson: PurchaseModel.fromRawJson)
      PurchaseModel activePurchase});

  @override
  $PurchaseModelCopyWith<$Res> get activePurchase;
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
    Object? hasOneTimePurchase = null,
    Object? subscriptionEndDate = freezed,
    Object? purchasedDaysLeft = null,
    Object? activePurchase = null,
  }) {
    return _then(_$PurchasesModelImpl(
      hasOneTimePurchase: null == hasOneTimePurchase
          ? _value.hasOneTimePurchase
          : hasOneTimePurchase // ignore: cast_nullable_to_non_nullable
              as bool,
      subscriptionEndDate: freezed == subscriptionEndDate
          ? _value.subscriptionEndDate
          : subscriptionEndDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      purchasedDaysLeft: null == purchasedDaysLeft
          ? _value.purchasedDaysLeft
          : purchasedDaysLeft // ignore: cast_nullable_to_non_nullable
              as int,
      activePurchase: null == activePurchase
          ? _value.activePurchase
          : activePurchase // ignore: cast_nullable_to_non_nullable
              as PurchaseModel,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$PurchasesModelImpl extends _PurchasesModel {
  const _$PurchasesModelImpl(
      {this.hasOneTimePurchase = false,
      this.subscriptionEndDate,
      this.purchasedDaysLeft = 0,
      @JsonKey(fromJson: PurchaseModel.fromRawJson)
      this.activePurchase = PurchaseModel.empty})
      : super._();

  factory _$PurchasesModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PurchasesModelImplFromJson(json);

  /// If user purchased the app for one time
  /// he should have all access indefinitely
  ///
  /// Priority one to develop.
  @override
  @JsonKey()
  final bool hasOneTimePurchase;

  /// If user purchased the app for subscription
  /// then he should have access until the end of subscription
  @override
  final DateTime? subscriptionEndDate;

  /// If user purchased certain amount of days
  /// then he should have access until [purchasedDaysLeft] > 0
  @override
  @JsonKey()
  final int purchasedDaysLeft;

  /// may be empty, for example in case if there is no payments made,
  /// or if user canceled subscription
  @override
  @JsonKey(fromJson: PurchaseModel.fromRawJson)
  final PurchaseModel activePurchase;

  @override
  String toString() {
    return 'PurchasesModel(hasOneTimePurchase: $hasOneTimePurchase, subscriptionEndDate: $subscriptionEndDate, purchasedDaysLeft: $purchasedDaysLeft, activePurchase: $activePurchase)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PurchasesModelImpl &&
            (identical(other.hasOneTimePurchase, hasOneTimePurchase) ||
                other.hasOneTimePurchase == hasOneTimePurchase) &&
            (identical(other.subscriptionEndDate, subscriptionEndDate) ||
                other.subscriptionEndDate == subscriptionEndDate) &&
            (identical(other.purchasedDaysLeft, purchasedDaysLeft) ||
                other.purchasedDaysLeft == purchasedDaysLeft) &&
            (identical(other.activePurchase, activePurchase) ||
                other.activePurchase == activePurchase));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, hasOneTimePurchase,
      subscriptionEndDate, purchasedDaysLeft, activePurchase);

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
      {final bool hasOneTimePurchase,
      final DateTime? subscriptionEndDate,
      final int purchasedDaysLeft,
      @JsonKey(fromJson: PurchaseModel.fromRawJson)
      final PurchaseModel activePurchase}) = _$PurchasesModelImpl;
  const _PurchasesModel._() : super._();

  factory _PurchasesModel.fromJson(Map<String, dynamic> json) =
      _$PurchasesModelImpl.fromJson;

  @override

  /// If user purchased the app for one time
  /// he should have all access indefinitely
  ///
  /// Priority one to develop.
  bool get hasOneTimePurchase;
  @override

  /// If user purchased the app for subscription
  /// then he should have access until the end of subscription
  DateTime? get subscriptionEndDate;
  @override

  /// If user purchased certain amount of days
  /// then he should have access until [purchasedDaysLeft] > 0
  int get purchasedDaysLeft;
  @override

  /// may be empty, for example in case if there is no payments made,
  /// or if user canceled subscription
  @JsonKey(fromJson: PurchaseModel.fromRawJson)
  PurchaseModel get activePurchase;
  @override
  @JsonKey(ignore: true)
  _$$PurchasesModelImplCopyWith<_$PurchasesModelImpl> get copyWith =>
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
