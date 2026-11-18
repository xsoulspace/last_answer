import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:la_ui/la_ui.dart';
import 'package:lastanswer/agent_config/grok_subscription_pane.dart';
import 'package:lastanswer/coding_agent/grok_credentials.dart';
import 'package:lastanswer/coding_agent/grok_subscription_controller.dart';
import 'package:xsoulspace_inference_xai/xsoulspace_inference_xai.dart';

import '../coding_agent/chatgpt_credentials_test.dart' show SecureMemory;
import '../coding_agent/grok_subscription_controller_test.dart'
    show FakeGrokGateway;

Widget wrap(GrokSubscriptionController controller) => Portal(
  child: MaterialApp(
    localizationsDelegates: S.localizationsDelegates,
    supportedLocales: S.supportedLocales,
    home: Scaffold(
      body: SingleChildScrollView(
        child: GrokSubscriptionPane(controller: controller),
      ),
    ),
  ),
);

void main() {
  testWidgets('an unregistered client shows the facts and stays closed', (
    tester,
  ) async {
    final store = GrokCredentials(secureValues: SecureMemory());
    final gateway = FakeGrokGateway(store)..isRegistered = false;
    final state = GrokSubscriptionController(
      credentials: store,
      gateway: gateway,
    );
    addTearDown(state.dispose);
    await tester.pumpWidget(wrap(state));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('grok.registration')), findsOneWidget);
    expect(find.byKey(const Key('grok.registration_facts')), findsOneWidget);
    expect(find.textContaining('last-answer'), findsOneWidget);
    expect(
      find.textContaining(LastAnswerGrokRegistration.redirectUri),
      findsOneWidget,
    );
    final button = tester.widget<LaButton>(
      find.byKey(const Key('grok.continue')),
    );
    expect(button.onPressed, isNull);
    expect(find.byKey(const Key('grok.error')), findsNothing);
  });

  testWidgets('pane connects, selects, verifies and signs out', (tester) async {
    final store = GrokCredentials(secureValues: SecureMemory());
    final gateway = FakeGrokGateway(store)..remoteRevoked = false;
    final state = GrokSubscriptionController(
      credentials: store,
      gateway: gateway,
    );
    addTearDown(state.dispose);
    await tester.pumpWidget(wrap(state));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('grok.registration')), findsNothing);
    await tester.tap(find.byKey(const Key('grok.continue')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('grok.account')), findsOneWidget);
    expect(state.accessReceipt, isNull);
    final check = tester.widget<LaButton>(
      find.byKey(const Key('grok.verify_access')),
    );
    expect(check.onPressed, isNull);
    await tester.tap(find.byKey(const Key('grok.model')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fixture model').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('grok.verify_access')));
    await tester.pumpAndSettle();
    expect(state.accessReceipt, isNotNull);
    expect(find.text('Access verified on this device'), findsOneWidget);
    await tester.tap(find.byKey(const Key('grok.sign_out')));
    await tester.pumpAndSettle();
    expect(await store.read('fixture-subject'), isNull);
    expect(find.byKey(const Key('grok.revocation_status')), findsOneWidget);
    expect(find.textContaining('fixture-access'), findsNothing);
  });

  testWidgets('a device code can be cancelled before an account is stored', (
    tester,
  ) async {
    final store = GrokCredentials(secureValues: SecureMemory());
    final gateway = FakeGrokGateway(store)..deviceGate = Completer<void>();
    final state = GrokSubscriptionController(
      credentials: store,
      gateway: gateway,
    );
    addTearDown(state.dispose);
    await tester.pumpWidget(wrap(state));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('grok.device')));
    await tester.pump();
    expect(find.byKey(const Key('grok.device_code')), findsOneWidget);
    expect(find.textContaining('ABCD-EFGH'), findsOneWidget);
    await tester.tap(find.byKey(const Key('grok.cancel')));
    await tester.pumpAndSettle();
    expect(state.busy, false);
    expect(state.devicePrompt, isNull);
    expect(state.activeAccountId, isNull);
    expect(find.byKey(const Key('grok.error')), findsNothing);
  });
}
