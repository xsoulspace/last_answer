import 'package:flutter/cupertino.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xsoulspace_foundation/xsoulspace_foundation.dart';

import 'ad_instance.dart';

abstract base class PurchasesAdsBase extends ChangeNotifier
    implements Loadable {
  Future<AdInstance> prepareAdInstance({required final AdUnitTuple unitIds});
  bool get isLoaded => _isLoaded;
  bool _isLoaded = false;
  void onLoadingFailed() {
    _isLoaded = false;
    notifyListeners();
  }

  @override
  @mustCallSuper
  @mustBeOverridden
  Future<void> onLoad() async {
    _isLoaded = true;
    notifyListeners();
  }
}
