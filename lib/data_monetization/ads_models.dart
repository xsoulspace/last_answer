import 'package:freezed_annotation/freezed_annotation.dart';

part 'ads_models.freezed.dart';
part 'ads_models.g.dart';

/// The persisted ads state: when the last reward was received (moved
/// from packages/shared_models, ADR 0038 — an app-domain model, never an
/// RPC payload).
@freezed
sealed class AdsStateModel with _$AdsStateModel {
  const factory AdsStateModel({
    final DateTime? lastDateWhenAdRewardReceived,
  }) = _AdsStateModel;
  const AdsStateModel._();
  factory AdsStateModel.fromJson(final Map<String, dynamic> json) =>
      _$AdsStateModelFromJson(json);
}
