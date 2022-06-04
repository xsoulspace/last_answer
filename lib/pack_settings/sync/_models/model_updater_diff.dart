part of pack_settings;

@immutable
@Freezed(
  fromJson: false,
  toJson: false,
  equal: true,
  addImplicitFinal: true,
  copyWith: true,
)
class InstanceUpdaterDto<T extends HasId, TOther extends HasId>
    with _$InstanceUpdaterDto<T, TOther> {
  const factory InstanceUpdaterDto({
    required final InstancesUpdatesDto<T, TOther> originalUpdates,
    required final InstancesUpdatesDto<TOther, T> otherUpdates,
    @Default({})
        final Map<InstanceId, InstanceDiff<T, TOther>> instancesToCheck,
  }) = _InstanceUpdaterDto<T, TOther>;
  const InstanceUpdaterDto._();
}

@immutable
@Freezed(
  fromJson: false,
  toJson: false,
  equal: true,
  addImplicitFinal: true,
  copyWith: true,
)
class InstancesUpdatesDto<T extends HasId, TOther extends HasId>
    with _$InstancesUpdatesDto<T, TOther> {
  const factory InstancesUpdatesDto({
    @Default([]) final Iterable<TOther> toCreateFromOther,
    @Default([]) final Iterable<T> toUpdate,
    @Default([]) final Iterable<T> toDelete,
  }) = _InstancesUpdatesDto<T, TOther>;
  const InstancesUpdatesDto._();
}
