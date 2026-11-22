import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/store/bindings/noop.dart';
import 'package:lastanswer/store/store_posture.dart';
import 'package:lastanswer/store/store_keys.dart';
import 'package:xsoulspace_monetization_foundation/xsoulspace_monetization_foundation.dart';
import 'package:xsoulspace_monetization_interface/xsoulspace_monetization_interface.dart';

/// A hand-typed RuStore-shaped binding (no backend import — posture is
/// about the KEY, so the test needs no purchase backend).
final class _RuStoreShapedBinding implements MonetizationStoreBinding {
  const _RuStoreShapedBinding();

  @override
  String get key => storeKeyRuStore;

  @override
  PurchaseProvider? Function() get purchaseProviderFactory => () => null;
}

void main() {
  group('StorePosture (ADR 0037 amendment — named capabilities, one key '
      'mapping)', () {
    test('the RuStore key maps to the login wall and RU market posture',
        () {
      const binding = _RuStoreShapedBinding();
      expect(binding.requiresStoreLogin, isTrue);
      expect(binding.isRuMarket, isTrue);
    });

    test('other keys carry neither posture', () {
      const binding = noopStoreBinding;
      expect(binding.requiresStoreLogin, isFalse);
      expect(binding.isRuMarket, isFalse);
    });
  });
}
