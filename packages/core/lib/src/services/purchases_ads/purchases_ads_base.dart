import 'package:shared_models/shared_models.dart';

import 'ad_instance.dart';

abstract base class PurchasesAdsBase implements Loadable {
  Future<AdInstance> prepareAdInstance({required final AdUnitTuple unitIds});
}
