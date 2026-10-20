import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/harness_host.dart';
import 'package:xsoulspace_agentic_harness/xsoulspace_agentic_harness.dart';

void main() {
  test(
    'context order is explicit, preserved on config copy and backend creation',
    () {
      const legacy = HarnessHostConfig();
      expect(legacy.actorContextOrder, ActorContextOrder.legacy);
      expect(legacy.buildBackend().actorContextOrder, ActorContextOrder.legacy);
      final selected = legacy.copyWith(
        actorContextOrder: ActorContextOrder.coderStablePrefixV1,
      );
      expect(
        selected.copyWith(model: 'same-provider').actorContextOrder,
        ActorContextOrder.coderStablePrefixV1,
      );
      expect(
        selected.buildBackend().actorContextOrder,
        ActorContextOrder.coderStablePrefixV1,
      );
      expect(
        selected
            .copyWith(actorContextOrder: ActorContextOrder.legacy)
            .buildBackend()
            .actorContextOrder,
        ActorContextOrder.legacy,
      );
    },
  );
}
