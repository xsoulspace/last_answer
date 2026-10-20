import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/product_cloud_resource.dart';

void main() {
  test(
    'shared reservations prevent concurrent actor overspend and persist',
    () async {
      final dir = await Directory.systemTemp.createTemp('cloud-budget-');
      addTearDown(() => dir.deleteSync(recursive: true));
      final budget = ProductCloudBudget(File('${dir.path}/ledger.json'));
      final first = budget.reserve(800000, 2000);
      expect(() => budget.reserve(200000, 2000), throwsStateError);
      budget.settle(first, 0.1);
      expect(budget.spent, 0.1);
      expect(ProductCloudBudget(budget.file).spent, 0.1);
    },
  );
  test('unknown billing seals admission across restart', () async {
    final dir = await Directory.systemTemp.createTemp('cloud-budget-');
    addTearDown(() => dir.deleteSync(recursive: true));
    final budget = ProductCloudBudget(File('${dir.path}/ledger.json'));
    final held = budget.reserve(100, 100);
    budget.settle(held, null);
    expect(() => budget.reserve(1, 1), throwsStateError);
    expect(ProductCloudBudget(budget.file).unknown, true);
  });
  test(
    'unsettled dispatch survives restart without a second allowance',
    () async {
      final dir = await Directory.systemTemp.createTemp('cloud-budget-');
      addTearDown(() => dir.deleteSync(recursive: true));
      final file = File('${dir.path}/ledger.json');
      ProductCloudBudget(file).reserve(100, 100);
      expect(() => ProductCloudBudget(file).reserve(1, 1), throwsStateError);
    },
  );
}
