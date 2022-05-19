part of pack_settings;

@immutable
@Freezed(
  fromJson: false,
  toJson: false,
  equal: true,
  addImplicitFinal: true,
  copyWith: true,
)
class ModelUpdaterDiff<T extends HasId, TOther extends HasId>
    with _$ModelUpdaterDiff<T, TOther> {
  const factory ModelUpdaterDiff({
    @Default({}) final Map<InstanceId, T> instancesToCreate,
    @Default({}) final Map<InstanceId, TOther> otherInstancesToCreate,
    @Default({})
        final Map<InstanceId, InstanceDiff<T, TOther>> instancesToCheck,
    @Default({})
        final Map<InstanceId, InstanceDiff<T, TOther>> updatedInstances,
    @Default({}) final Map<InstanceId, T> instancesToDelete,
  }) = _ModelUpdaterDiff<T, TOther>;
  const ModelUpdaterDiff._();
}
