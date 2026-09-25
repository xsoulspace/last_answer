import 'package:shared_models/shared_models.dart';
import 'package:xsoulspace_foundation/xsoulspace_foundation.dart';

import '../data_sources.dart';

class AdsLocalDataSourceImpl implements AdsLocalDataSource {
  AdsLocalDataSourceImpl({required this.localDb});
  final LocalDbI localDb;

  @override
  Future<void> saveState(final AdsStateModel ads) async {
    await localDb.setItem(
      key: SharedPreferencesKeys.adsState.name,
      value: ads,
      toJson: (final v) => v.toJson(),
    );
  }

  @override
  Future<AdsStateModel> getState() async {
    final item = await localDb.getItem(
      key: SharedPreferencesKeys.adsState.name,
      fromJson: AdsStateModel.fromJson,
      defaultValue: const AdsStateModel(),
    );
    return item;
  }
}
