import 'package:shared_models/shared_models.dart';

abstract base class AdInstance implements Disposable {
  void show();
  @override
  void dispose();
}

class RewardModel {
  RewardModel({
    required this.amount,
    required this.isRewarded,
  });
  final int amount;
  final bool isRewarded;
}
