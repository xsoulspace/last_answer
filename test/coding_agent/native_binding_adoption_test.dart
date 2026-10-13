import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lastanswer/coding_agent/agent_doc_surface.dart';
import 'package:lastanswer/coding_agent/chatgpt_credentials.dart';
import 'package:lastanswer/coding_agent/chatgpt_gateway_contract.dart';
import 'package:lastanswer/coding_agent/chatgpt_gateway_io.dart';
import 'package:lastanswer/coding_agent/chatgpt_harness_binding.dart';
import 'package:lastanswer/coding_agent/chatgpt_subscription_controller.dart';
import 'package:lastanswer/coding_agent/harness_host.dart';
import 'package:lastanswer/coding_agent/product_workspace_tooling.dart';
import 'package:lastanswer/coding_agent/provider_configuration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xsoulspace_inference_core/xsoulspace_inference_core.dart';
import 'package:xsoulspace_inference_openai/xsoulspace_inference_openai.dart';

import 'chatgpt_credentials_test.dart' show SecureMemory, record;
import 'pump_until.dart';

/// Catalog-only fixture. Client construction uses the real product binding;
/// no model/runtime load or remote request occurs in this control.
class OfflineCatalog implements ChatGptGateway {
  OfflineCatalog(this.native);
  final NativeChatGptGateway native;
  final clientAccounts = <String>[];
  final clients = <OpenAiResponsesClient>[];
  @override
  bool get supported => native.supported;
  @override
  bool get hasUnconfirmedCleanup => native.hasUnconfirmedCleanup;
  @override
  Future<List<SubscriptionModel>> models(String clientId) async => const [
    SubscriptionModel(slug: 'fixture-model', displayName: 'Fixture model'),
  ];
  @override
  InferenceClient inferenceClient(String clientId, String model) {
    clientAccounts.add(clientId);
    final client = OpenAiResponsesClient(
      auth: native.auth,
      clientId: clientId,
      model: model,
      client: MockClient((_) async => http.Response('{"models":[]}', 200)),
    );
    clients.add(client);
    return client;
  }

  @override
  Future<void> releaseClient(InferenceClient client) async {
    (client as CancellableInferenceClient).cancelActive();
    await client.settleActive();
    client.close();
  }

  @override
  Future<void> dispose() async {
    for (final client in clients) {
      await releaseClient(client);
    }
    await native.dispose();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('failed preparation cannot relabel the old account binding', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final root = (await tester.runAsync(
      () => Directory.systemTemp.createTemp('native_binding_adoption_'),
    ))!;
    final first = Directory('${root.path}/first')..createSync();
    final second = Directory('${root.path}/second')..createSync();
    for (final workspace in [first, second]) {
      File('${workspace.path}/main.dart').writeAsStringSync('void main() {}\n');
    }
    final credentials = ChatGptCredentials(secureValues: SecureMemory());
    final hostId = await credentials.ensureHostId();
    for (final account in ['account-a', 'account-b']) {
      await credentials.write(record(hostId, account));
      await credentials.selectModel(account, 'fixture-model');
    }
    await credentials.selectAccount('account-a');
    final native = NativeChatGptGateway(credentials: credentials);
    final gateway = OfflineCatalog(native);
    final subscription = ChatGptSubscriptionController(
      credentials: credentials,
      gateway: gateway,
    );
    final provider = ProviderConfigurationStore(secureValues: SecureMemory());
    var failPreparation = false;
    final tooling = ProductWorkspaceTooling(
      supportDirectory: () async {
        if (failPreparation) throw StateError('controlled preparation refusal');
        return Directory('${root.path}/support')..createSync(recursive: true);
      },
    );
    final doc = (ProjectModel.emptyAgent() as ProjectModelDoc).copyWith(
      agent: AgentDocModel(backend: chatGptBackend, workspaces: [first.path]),
    );
    for (final choice in [
      ('account-a', first.path),
      ('account-b', second.path),
    ]) {
      await provider.grantHostedConsent(
        documentId: doc.id.value,
        provider: chatGptConsentProvider(choice.$1),
        model: 'fixture-model',
        workspace: choice.$2,
      );
    }
    await subscription.load();
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        home: Scaffold(
          body: AgentDocSurface(
            doc: doc,
            config: const HarnessHostConfig(scripted: true),
            subscription: subscription,
            providerConfiguration: provider,
            workspaceTooling: tooling,
          ),
        ),
      ),
    );
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox());
      subscription.dispose();
      await gateway.dispose();
      await tester.runAsync(() => root.delete(recursive: true));
    });
    Future<void> openSessionWithoutInference() async {
      var finished = false;
      final status = AgentDocSurface.debugSurface!
          .meaningAction('status')
          .whenComplete(() => finished = true);
      await pumpUntil(tester, () => finished);
      expect(finished, true, reason: 'status preparation did not settle');
      await status;
    }

    await openSessionWithoutInference();
    expect(gateway.clientAccounts.last, 'account-a');
    await subscription.selectAccount('account-b');
    failPreparation = true;
    AgentDocSurface.debugSurface!.bindFromIntent(workspace: second.path);
    await pumpUntil(
      tester,
      () => find
          .textContaining('controlled preparation refusal')
          .evaluate()
          .isNotEmpty,
    );
    expect(
      find.textContaining('controlled preparation refusal'),
      findsOneWidget,
    );
    expect(gateway.clientAccounts.last, 'account-a');
    failPreparation = false;
    AgentDocSurface.debugSurface!.bindFromIntent(workspace: second.path);
    await openSessionWithoutInference();
    expect(gateway.clientAccounts.last, 'account-b');
  });
}
