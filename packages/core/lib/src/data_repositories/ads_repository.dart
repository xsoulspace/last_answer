import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shared_models/shared_models.dart';

import '../../core.dart';

class AdsRepository {
  AdsRepository(final BuildContext context)
      : _local = AdsLocalDataSourceImpl(
          localDb: context.read(),
        );
  final AdsLocalDataSource _local;
  Future<void> saveState(final AdsStateModel ads) => _local.saveState(ads);
  Future<AdsStateModel> getState() => _local.getState();
}
