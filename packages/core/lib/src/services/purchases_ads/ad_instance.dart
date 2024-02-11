import 'package:shared_models/shared_models.dart';

abstract base class AdInstance implements Disposable {
  Future<AdRewardModel> show();
  @override
  void dispose();
}

class AdRewardModel {
  AdRewardModel({
    required this.amount,
    required this.isRewarded,
  });
  final int amount;
  final bool isRewarded;
}

typedef AdUnitTuple = ({String desktop, String mobile, bool isDarkMode});
