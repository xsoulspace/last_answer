import 'package:lastanswer/data_monetization/data_monetization.dart';

abstract interface class AdsLocalDataSource {
  Future<void> saveState(final AdsStateModel ads);
  Future<AdsStateModel> getState();
}
