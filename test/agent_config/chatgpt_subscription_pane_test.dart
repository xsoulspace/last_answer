import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/agent_config/chatgpt_subscription_pane.dart';
import 'package:lastanswer/coding_agent/chatgpt_credentials.dart';
import 'package:lastanswer/coding_agent/chatgpt_subscription_controller.dart';

import '../coding_agent/chatgpt_credentials_test.dart' show SecureMemory;
import '../coding_agent/chatgpt_subscription_controller_test.dart'
    show FakeChatGptGateway;

Widget wrap(ChatGptSubscriptionController controller) => MaterialApp(
  localizationsDelegates: S.localizationsDelegates,
  supportedLocales: S.supportedLocales,
  home: Scaffold(
    body: SingleChildScrollView(
      child: ChatGptSubscriptionPane(controller: controller),
    ),
  ),
);

void main() {
  testWidgets('interrupted credentials can be signed out from the pane', (
    tester,
  ) async {
    final storeForRestart = SecureMemory();
    final store = ChatGptCredentials(secureValues: storeForRestart);
    final gateway = FakeChatGptGateway(store);
    await gateway.signIn();
    await store.selectAccount('fixture-client');
    await store.beginMutation('fixture-client');
    final state = ChatGptSubscriptionController(
      credentials: store,
      gateway: gateway,
    );
    addTearDown(state.dispose);
    await tester.pumpWidget(wrap(state));
    await tester.pumpAndSettle();
    expect(state.activeProfile!.recoveryRequired, true);
    expect(state.activeProfile!.signedIn, false);
    await tester.tap(find.byKey(const Key('chatgpt.sign_out')));
    await tester.pumpAndSettle();
    expect((await store.profiles()).single.recoveryRequired, false);
    expect(await store.read('fixture-client'), null);
    expect(find.byKey(const Key('chatgpt.revocation_status')), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    final restartedStore = ChatGptCredentials(secureValues: storeForRestart);
    final restarted = ChatGptSubscriptionController(
      credentials: restartedStore,
      gateway: FakeChatGptGateway(restartedStore),
    );
    addTearDown(restarted.dispose);
    await tester.pumpWidget(wrap(restarted));
    await tester.pumpAndSettle();
    expect(restarted.hasUnconfirmedCleanup, true);
    expect(find.byKey(const Key('chatgpt.revocation_status')), findsOneWidget);
  });

  testWidgets(
    'pane connects, selects, verifies and signs out through one controller',
    (tester) async {
      final store = ChatGptCredentials(secureValues: SecureMemory());
      final gateway = FakeChatGptGateway(store)..remoteRevoked = false;
      final state = ChatGptSubscriptionController(
        credentials: store,
        gateway: gateway,
      );
      addTearDown(state.dispose);
      await tester.pumpWidget(wrap(state));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('chatgpt.continue')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('chatgpt.account')), findsOneWidget);
      expect(state.accessReceipt, isNull);
      final check = tester.widget<TextButton>(
        find.byKey(const Key('chatgpt.verify_access')),
      );
      expect(check.onPressed, isNull);
      await tester.tap(find.byKey(const Key('chatgpt.model')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Fixture model').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('chatgpt.verify_access')));
      await tester.pumpAndSettle();
      expect(state.accessReceipt, isNotNull);
      expect(find.text('Model access verified.'), findsOneWidget);
      await tester.tap(find.byKey(const Key('chatgpt.sign_out')));
      await tester.pumpAndSettle();
      expect(await store.read('fixture-client'), isNull);
      expect(
        find.byKey(const Key('chatgpt.revocation_status')),
        findsOneWidget,
      );
      expect(find.textContaining('fixture-access'), findsNothing);
    },
  );

  testWidgets('pending browser sign-in is cancellable from the pane', (
    tester,
  ) async {
    final store = ChatGptCredentials(secureValues: SecureMemory());
    final gateway = FakeChatGptGateway(store)..signInGate = Completer<void>();
    final state = ChatGptSubscriptionController(
      credentials: store,
      gateway: gateway,
    );
    addTearDown(state.dispose);
    await tester.pumpWidget(wrap(state));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('chatgpt.continue')));
    await tester.pump();
    expect(find.byKey(const Key('chatgpt.cancel')), findsOneWidget);
    await tester.tap(find.byKey(const Key('chatgpt.cancel')));
    await tester.pumpAndSettle();
    expect(state.signingIn, false);
    expect(state.activeClientId, isNull);
  });
}
