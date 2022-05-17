part of pack_purchases_i;

PaymentsControllerI createMockPaymentsController() => MockPaymentsController();

class MockPaymentsController extends PaymentsControllerI {
  @override
  String get annualSubscriptionTitle => '';

  @override
  String get monthlySubscriptionTitle => '';

  @override
  bool get paymentsAccessable => false;
}
