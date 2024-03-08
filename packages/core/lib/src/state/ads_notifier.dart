import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_models/shared_models.dart';

import '../../core.dart';
import '../data_repositories/ads_repository.dart';

class AdsNotifier extends LoadableStateNotifier<AdsStateModel> {
  AdsNotifier(final BuildContext context)
      : _adsRepository = context.read(),
        super(const AdsStateModel());
  final AdsRepository _adsRepository;

  Future<void> onLoad() async {
    state = await _adsRepository.getState();
  }

  bool get isAllowedToWatchRewarded =>
      todayDate == state.lastDateWhenAdRewardReceived;

  Future<void> onAwareded() async {
    final updatedState =
        state.copyWith(lastDateWhenAdRewardReceived: todayDate);
    await _adsRepository.saveState(updatedState);
  }
}
