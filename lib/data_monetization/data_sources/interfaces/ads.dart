import 'package:shared_models/shared_models.dart';

abstract interface class AdsLocalDataSource {
  Future<void> saveState(final AdsStateModel ads);
  Future<AdsStateModel> getState();
}
