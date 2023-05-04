import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lastanswer/pack_core/pack_core.dart';

part 'instance_diff.freezed.dart';

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
class UpdatableInstanceDiff<T extends HasId, TOther extends HasId>
    with _$UpdatableInstanceDiff<T, TOther> {
  const factory UpdatableInstanceDiff({
    required final T original,
    required final TOther other,
    required final bool originalWasUpdated,
    required final bool otherWasUpdated,
  }) = _UpdatableInstanceDiff<T, TOther>;
}
