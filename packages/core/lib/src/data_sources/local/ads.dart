import 'package:shared_models/shared_models.dart';

import '../data_sources.dart';

class AdsLocalDataSourceImpl implements AdsLocalDataSource {
  AdsLocalDataSourceImpl({required this.localDb});
  final LocalDbDataSource localDb;

  @override
  Future<void> saveState(final AdsStateModel ads) async {
    localDb.setItem(
      key: SharedPreferencesKeys.adsState.name,
      value: ads,
      convertToJson: (final v) => v.toJson(),
    );
  }

  @override
  Future<AdsStateModel> getState() async {
    final item = localDb.getItem(
      key: SharedPreferencesKeys.adsState.name,
      convertFromJson: AdsStateModel.fromJson,
    );
    return item ?? const AdsStateModel();
  }
}
