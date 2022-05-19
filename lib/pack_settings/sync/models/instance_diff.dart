part of pack_settings;

@immutable
@Freezed(
  fromJson: false,
  toJson: false,
  equal: true,
  addImplicitFinal: true,
  copyWith: true,
)
class InstanceDiff<T extends HasId, TOther extends HasId>
    with _$InstanceDiff<T, TOther> {
  const factory InstanceDiff({
    required final T original,
    required final TOther other,
  }) = _InstanceDiff<T, TOther>;
  const InstanceDiff._();
}

@immutable
@Freezed(
  fromJson: false,
  toJson: false,
  equal: true,
  addImplicitFinal: true,
  copyWith: true,
)
class OptionalInstanceDiff<T extends HasId, TOther extends HasId>
    with _$OptionalInstanceDiff<T, TOther> {
  const factory OptionalInstanceDiff({
    required final T original,
    required final TOther? other,
  }) = _OptionalInstanceDiff<T, TOther>;
  const OptionalInstanceDiff._();
}
