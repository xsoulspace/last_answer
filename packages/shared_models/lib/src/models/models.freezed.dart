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

/// @nodoc
mixin _$ProductModelId {
  String get value => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ProductModelIdCopyWith<ProductModelId> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductModelIdCopyWith<$Res> {
  factory $ProductModelIdCopyWith(
          ProductModelId value, $Res Function(ProductModelId) then) =
      _$ProductModelIdCopyWithImpl<$Res, ProductModelId>;
  @useResult
  $Res call({String value});
}

/// @nodoc
class _$ProductModelIdCopyWithImpl<$Res, $Val extends ProductModelId>
    implements $ProductModelIdCopyWith<$Res> {
  _$ProductModelIdCopyWithImpl(this._value, this._then);

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
abstract class _$$ProductModelIdImplCopyWith<$Res>
    implements $ProductModelIdCopyWith<$Res> {
  factory _$$ProductModelIdImplCopyWith(_$ProductModelIdImpl value,
          $Res Function(_$ProductModelIdImpl) then) =
      __$$ProductModelIdImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String value});
}

/// @nodoc
class __$$ProductModelIdImplCopyWithImpl<$Res>
    extends _$ProductModelIdCopyWithImpl<$Res, _$ProductModelIdImpl>
    implements _$$ProductModelIdImplCopyWith<$Res> {
  __$$ProductModelIdImplCopyWithImpl(
      _$ProductModelIdImpl _value, $Res Function(_$ProductModelIdImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
  }) {
    return _then(_$ProductModelIdImpl(
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ProductModelIdImpl extends _ProductModelId {
  const _$ProductModelIdImpl({required this.value}) : super._();

  @override
  final String value;

  @override
  String toString() {
    return 'ProductModelId(value: $value)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductModelIdImpl &&
            (identical(other.value, value) || other.value == value));
  }

  @override
  int get hashCode => Object.hash(runtimeType, value);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductModelIdImplCopyWith<_$ProductModelIdImpl> get copyWith =>
      __$$ProductModelIdImplCopyWithImpl<_$ProductModelIdImpl>(
          this, _$identity);
}

abstract class _ProductModelId extends ProductModelId {
  const factory _ProductModelId({required final String value}) =
      _$ProductModelIdImpl;
  const _ProductModelId._() : super._();

  @override
  String get value;
  @override
  @JsonKey(ignore: true)
  _$$ProductModelIdImplCopyWith<_$ProductModelIdImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PurchaseModel _$PurchaseModelFromJson(Map<String, dynamic> json) {
  return _PurchaseModel.fromJson(json);
}

/// @nodoc
mixin _$PurchaseModel {
  ProductModelId get productId => throw _privateConstructorUsedError;
  PurchasePaymentProvider get paymentProvider =>
      throw _privateConstructorUsedError;
  String get originalTransactionID => throw _privateConstructorUsedError;

  /// can contain symbol, so it's not double
  String get price => throw _privateConstructorUsedError;
  PurchasePeriod get period => throw _privateConstructorUsedError;
  PurchaseAttributesModel get attributes => throw _privateConstructorUsedError;
  DateTime? get willExpireAt => throw _privateConstructorUsedError;

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
      {ProductModelId productId,
      PurchasePaymentProvider paymentProvider,
      String originalTransactionID,
      String price,
      PurchasePeriod period,
      PurchaseAttributesModel attributes,
      DateTime? willExpireAt});

  $ProductModelIdCopyWith<$Res> get productId;
  $PurchaseAttributesModelCopyWith<$Res> get attributes;
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
    Object? price = null,
    Object? period = null,
    Object? attributes = null,
    Object? willExpireAt = freezed,
  }) {
    return _then(_value.copyWith(
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as ProductModelId,
      paymentProvider: null == paymentProvider
          ? _value.paymentProvider
          : paymentProvider // ignore: cast_nullable_to_non_nullable
              as PurchasePaymentProvider,
      originalTransactionID: null == originalTransactionID
          ? _value.originalTransactionID
          : originalTransactionID // ignore: cast_nullable_to_non_nullable
              as String,
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
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ProductModelIdCopyWith<$Res> get productId {
    return $ProductModelIdCopyWith<$Res>(_value.productId, (value) {
      return _then(_value.copyWith(productId: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $PurchaseAttributesModelCopyWith<$Res> get attributes {
    return $PurchaseAttributesModelCopyWith<$Res>(_value.attributes, (value) {
      return _then(_value.copyWith(attributes: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PurchaseModelImplCopyWith<$Res>
    implements $PurchaseModelCopyWith<$Res> {
  factory _$$PurchaseModelImplCopyWith(
          _$PurchaseModelImpl value, $Res Function(_$PurchaseModelImpl) then) =
      __$$PurchaseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {ProductModelId productId,
      PurchasePaymentProvider paymentProvider,
      String originalTransactionID,
      String price,
      PurchasePeriod period,
      PurchaseAttributesModel attributes,
      DateTime? willExpireAt});

  @override
  $ProductModelIdCopyWith<$Res> get productId;
  @override
  $PurchaseAttributesModelCopyWith<$Res> get attributes;
}

/// @nodoc
class __$$PurchaseModelImplCopyWithImpl<$Res>
    extends _$PurchaseModelCopyWithImpl<$Res, _$PurchaseModelImpl>
    implements _$$PurchaseModelImplCopyWith<$Res> {
  __$$PurchaseModelImplCopyWithImpl(
      _$PurchaseModelImpl _value, $Res Function(_$PurchaseModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? paymentProvider = null,
    Object? originalTransactionID = null,
    Object? price = null,
    Object? period = null,
    Object? attributes = null,
    Object? willExpireAt = freezed,
  }) {
    return _then(_$PurchaseModelImpl(
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as ProductModelId,
      paymentProvider: null == paymentProvider
          ? _value.paymentProvider
          : paymentProvider // ignore: cast_nullable_to_non_nullable
              as PurchasePaymentProvider,
      originalTransactionID: null == originalTransactionID
          ? _value.originalTransactionID
          : originalTransactionID // ignore: cast_nullable_to_non_nullable
              as String,
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
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PurchaseModelImpl extends _PurchaseModel {
  const _$PurchaseModelImpl(
      {this.productId = ProductModelId.empty,
      this.paymentProvider = PurchasePaymentProvider.googlePlay,
      this.originalTransactionID = '',
      this.price = '',
      this.period = PurchasePeriod.monthly,
      this.attributes = PurchaseAttributesModel.empty,
      this.willExpireAt})
      : super._();

  factory _$PurchaseModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PurchaseModelImplFromJson(json);

  @override
  @JsonKey()
  final ProductModelId productId;
  @override
  @JsonKey()
  final PurchasePaymentProvider paymentProvider;
  @override
  @JsonKey()
  final String originalTransactionID;

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
  String toString() {
    return 'PurchaseModel(productId: $productId, paymentProvider: $paymentProvider, originalTransactionID: $originalTransactionID, price: $price, period: $period, attributes: $attributes, willExpireAt: $willExpireAt)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PurchaseModelImpl &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.paymentProvider, paymentProvider) ||
                other.paymentProvider == paymentProvider) &&
            (identical(other.originalTransactionID, originalTransactionID) ||
                other.originalTransactionID == originalTransactionID) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.period, period) || other.period == period) &&
            (identical(other.attributes, attributes) ||
                other.attributes == attributes) &&
            (identical(other.willExpireAt, willExpireAt) ||
                other.willExpireAt == willExpireAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, productId, paymentProvider,
      originalTransactionID, price, period, attributes, willExpireAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PurchaseModelImplCopyWith<_$PurchaseModelImpl> get copyWith =>
      __$$PurchaseModelImplCopyWithImpl<_$PurchaseModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PurchaseModelImplToJson(
      this,
    );
  }
}

abstract class _PurchaseModel extends PurchaseModel {
  const factory _PurchaseModel(
      {final ProductModelId productId,
      final PurchasePaymentProvider paymentProvider,
      final String originalTransactionID,
      final String price,
      final PurchasePeriod period,
      final PurchaseAttributesModel attributes,
      final DateTime? willExpireAt}) = _$PurchaseModelImpl;
  const _PurchaseModel._() : super._();

  factory _PurchaseModel.fromJson(Map<String, dynamic> json) =
      _$PurchaseModelImpl.fromJson;

  @override
  ProductModelId get productId;
  @override
  PurchasePaymentProvider get paymentProvider;
  @override
  String get originalTransactionID;
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
  @JsonKey(ignore: true)
  _$$PurchaseModelImplCopyWith<_$PurchaseModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
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
      int purchasedDaysLeft});
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
      {bool hasOneTimePurchase,
      DateTime? subscriptionEndDate,
      int purchasedDaysLeft});
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
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$PurchasesModelImpl extends _PurchasesModel {
  const _$PurchasesModelImpl(
      {this.hasOneTimePurchase = false,
      this.subscriptionEndDate,
      this.purchasedDaysLeft = 0})
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

  @override
  String toString() {
    return 'PurchasesModel(hasOneTimePurchase: $hasOneTimePurchase, subscriptionEndDate: $subscriptionEndDate, purchasedDaysLeft: $purchasedDaysLeft)';
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
                other.purchasedDaysLeft == purchasedDaysLeft));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, hasOneTimePurchase, subscriptionEndDate, purchasedDaysLeft);

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
      final int purchasedDaysLeft}) = _$PurchasesModelImpl;
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
