import 'payments_controller_i.dart';

PaymentsControllerI createMockPaymentsController() => MockPaymentsController();

class MockPaymentsController extends PaymentsControllerI {
  @override
  String get annualSubscriptionTitle => '';

  @override
  String get monthlySubscriptionTitle => '';

  @override
  bool get paymentsAccessable => false;
}
