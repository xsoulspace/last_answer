import 'package:lastanswer/data_monetization/data_monetization.dart';
import 'package:lastanswer/foundation/foundation.dart';
import 'package:xsoulspace_foundation/xsoulspace_foundation.dart';

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
