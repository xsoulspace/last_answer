import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:headless_core/headless_core.dart' as headless_core;
import 'package:lastanswer/agent_config/agent_config.dart';
import 'package:lastanswer/coding_agent/provider_configuration.dart';
import 'package:lastanswer/doc/acp_agent_runtime.dart' as acp_runtime;
import 'package:lastanswer/doc/acp_agent_runtime_registry.dart';
import 'package:lastanswer/doc/acp_doc_inference_port.dart';
import 'package:provider/provider.dart';
import 'package:universal_storage_interface/universal_storage_interface.dart';
import 'package:universal_storage_local_db/universal_storage_local_db.dart';
import 'package:xsoulspace_foundation/xsoulspace_foundation.dart';
import 'package:xsoulspace_installation_store/xsoulspace_installation_store.dart';
import 'package:xsoulspace_monetization_foundation/xsoulspace_monetization_foundation.dart';
import 'package:xsoulspace_monetization_rustore/xsoulspace_monetization_rustore.dart';

import '../../core.dart';

class GlobalStatesProvider extends StatelessWidget {
  const GlobalStatesProvider({required this.builder, super.key});
  final WidgetBuilder builder;

  static DocInferencePort? _createDocInferencePort(final BuildContext context) {
    if (Envs.acpAgentCommand.isEmpty) return null;
    return AcpDocInferencePort(
      config: AcpAgentConfig(
        command: Envs.acpAgentCommand,
        arguments: Envs.acpAgentArguments.isEmpty
            ? const []
            : Envs.acpAgentArguments.split(' '),
        workingDirectory: Directory.current.path,
      ),
    );
  }

  @override
  Widget build(final BuildContext context) => MultiProvider(
    providers: [
      /// dependentless state distributors
      ChangeNotifierProvider(create: RemoteUserNotifier.new),
      ChangeNotifierProvider(create: AppFeaturesNotifier.new),

      /// services, repos
      Provider<LocalDbI>(create: (final context) => PrefsDb()),
      Provider<StorageService>(
        create: (final context) => StorageService(
          LocalDbStorageProvider(localDb: context.read<LocalDbI>()),
        ),
      ),
      // ChangeNotifierProvider<PurchasesIapService>(
      //   create: PurchasesIapGoogleAppleImpl.new,
      // ),
      // ChangeNotifierProvider(create: PurchasesAdsService.new),
      // Provider(create: PurchasesRepository.new),
      Provider(create: EmojiRepository.new),
      Provider(create: LastUsedEmojiRepository.new),
      Provider(create: TagsRepository.new),
      Provider(create: UserRepository.new),
      Provider(create: NotificationsRepository.new),
      Provider(create: ProjectsRepository.new),
      Provider(create: AdsRepository.new),
      Provider<headless_core.DocumentRepository>(
        create: (final context) => headless_core.MeshAwareDocumentRepository(
          headless_core.StorageDocumentRepository(
            service: context.read<StorageService>(),
          ),
          // The live mesh replica store arrives when the user pairs the
          // device (LAN mesh); until then chats use the plain local store.
          // The seam is installed by the app shell (home screen) in
          // debug/profile builds, mirroring AgentDocSurface.meshWiring.
          () => headless_core.MeshAwareDocumentRepository.replicaStoreGetter
              ?.call(),
        ),
      ),
      Provider(
        create: (final context) => headless_core.ChatDocumentService(
          repository: context.read<headless_core.DocumentRepository>(),
        ),
      ),
      Provider<acp_runtime.AcpInstallationService>(
        create: (final _) => acp_runtime.AcpInstallationService(),
      ),
      Provider<acp_runtime.AcpAgentRuntime>(
        create: (final _) => acp_runtime.AcpAgentRuntime(),
      ),
      ListenableProvider<AgentConfigStore>(
        create: (final _) {
          final store = AgentConfigStore(
            environment: kIsWeb ? const {} : Platform.environment,
          );
          unawaited(store.load());
          return store;
        },
      ),
      Provider<ProviderConfigurationStore>(
        create: (final _) => ProviderConfigurationStore(),
      ),
      Provider<AcpAgentRuntimeRegistry>(
        create: (final _) => AcpAgentRuntimeRegistry(),
      ),
      Provider<DocInferencePort?>(create: _createDocInferencePort),

      /// notifiers & blocs
      ChangeNotifierProvider(create: EmojiStateNotifier.new),
      ChangeNotifierProvider(create: LastEmojiStateNotifier.new),
      ChangeNotifierProvider(create: SpecialEmojiStateNotifier.new),
      ChangeNotifierProvider(create: NotificationsNotifier.new),
      ChangeNotifierProvider(create: TagsNotifier.new),
      ChangeNotifierProvider(create: AdsNotifier.new),
      ChangeNotifierProvider(create: ProjectsNotifier.new),
      ChangeNotifierProvider(create: PurchasesNotifier.new),
      ChangeNotifierProvider(create: UserNotifier.new),
      ChangeNotifierProvider(create: AppNotifier.new),
      ChangeNotifierProvider(create: OpenedProjectNotifier.new),

      /// monetization
      ChangeNotifierProvider<MonetizationStoreStatusResource>(
        create: (final _) => MonetizationStoreStatusResource(),
      ),
      ChangeNotifierProvider<MonetizationTypeResource>(
        create: (final _) =>
            MonetizationTypeResource(MonetizationType.subscription),
      ),
      ChangeNotifierProvider<ActiveSubscriptionResource>(
        create: (final _) => ActiveSubscriptionResource(),
      ),
      ChangeNotifierProvider<SubscriptionStatusResource>(
        create: (final _) => SubscriptionStatusResource(),
      ),
      ChangeNotifierProvider<AvailableSubscriptionsResource>(
        create: (final _) => AvailableSubscriptionsResource(),
      ),
      ChangeNotifierProvider<PaywallSelectedSubscriptionResource>(
        create: (final _) => PaywallSelectedSubscriptionResource(),
      ),
      ChangeNotifierProvider<PurchasePaywallErrorResource>(
        create: (final _) => PurchasePaywallErrorResource(),
      ),
      Provider<PurchasesLocalApi>(
        create: (final context) =>
            PurchasesLocalApi(localDb: context.read<LocalDbI>()),
      ),
      Provider<MonetizationFoundation>(
        create: (final context) {
          final purchaseProvider = switch (monetizationStoreTarget) {
            InstallationTargetStore.rustore => RustorePurchaseProvider(
              consoleApplicationId: rustoreApplicationId,
              deeplinkScheme: appDeeplinkScheme,
              // ignore: avoid_redundant_argument_values
              enableLogging: kDebugMode,
              productTypeChecker: MonetizationProducts.productTypeChecker,
            ),
            _ => NoopPurchaseProvider(),
          };
          return MonetizationFoundation(
            resources: (
              status: context.read<MonetizationStoreStatusResource>(),
              type: context.read<MonetizationTypeResource>(),
              activeSubscription: context.read<ActiveSubscriptionResource>(),
              subscriptionStatus: context.read<SubscriptionStatusResource>(),
              availableSubscriptions: context
                  .read<AvailableSubscriptionsResource>(),
              paywallSelectedSubscription: context
                  .read<PaywallSelectedSubscriptionResource>(),
              purchasePaywallError: context
                  .read<PurchasePaywallErrorResource>(),
            ),
            purchasesLocalApi: context.read<PurchasesLocalApi>(),
            purchaseProvider: purchaseProvider,
          );
        },
        dispose: (final _, final foundation) => foundation.dispose(),
      ),
    ],
    child: Builder(builder: builder),
  );
}
