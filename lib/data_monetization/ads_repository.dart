import 'package:lastanswer/common_imports.dart';

class AdsRepository {
  AdsRepository(final BuildContext context)
      : _local = AdsLocalDataSourceImpl(
          localDb: context.read(),
        );
  final AdsLocalDataSource _local;
  Future<void> saveState(final AdsStateModel ads) => _local.saveState(ads);
  Future<AdsStateModel> getState() => _local.getState();
}
