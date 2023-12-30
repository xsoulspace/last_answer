import 'package:serverpod/serverpod.dart';
import 'package:shared_models/shared_models.dart';

class IapPurchasesRepository {
  IapPurchasesRepository();

  Future<void> createOrUpdatePurchase({
    required final Session session,
    required final PurchaseModel purchase,
  }) async {
    print('createOrUpdatePurchase $purchase');
    final purchaseId = purchase.id;
    // TODO(arenukvern): upsert databse record,
  }

  Future<void> updatePurchase({
    required final Session session,
    required final PurchaseModel purchase,
  }) async {
    print('Updating $purchase');
    final purchaseId = purchase.id;

    // TODO(arenukvern): update databse record,
  }

  Future<List<PurchaseModel>> getPurchases() async => [];
}
