import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:la_core/la_core.dart';
import 'package:lastanswer/api/api.dart';
import 'package:lastanswer/library/theme/theme.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_app/notifications/notifications_controller.dart';
import 'package:lastanswer/pack_app/screens/app_loading/app_loading_screen.dart';
import 'package:lastanswer/pack_app/states/global_state_initializer.dart';
import 'package:lastanswer/pack_app/states/global_state_notifiers.dart';
import 'package:lastanswer/pack_auth/pack_auth.dart';
import 'package:lastanswer/pack_core/pack_core.dart';
import 'package:lastanswer/pack_purchases/abstract/purchases_abstract.dart';
import 'package:lastanswer/pack_settings/pack_settings.dart';
import 'package:lastanswer/state/state.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_lib;

class AppStateProvider extends StatelessWidget {
  const AppStateProvider({
    required final this.builder,
    final Key? key,
  }) : super(key: key);
  final WidgetBuilder builder;
  GeneralSettingsController get _settings => GlobalStateNotifiers.settings;

  @override
  Widget build(final BuildContext context) {
    final child = MultiProvider(
      providers: [
        /// ********************************************
        /// *      API START
        /// ********************************************
        Provider<supabase_lib.SupabaseClient>(
          create: (final context) => GlobalStateNotifiers.supabase,
        ),
        Provider(
          create: createApiProviderBuilder(FoldersApi.new),
        ),
        Provider(
          create: createApiProviderBuilder(ProjectsApi.new),
        ),
        Provider(
          create: createApiProviderBuilder(IdeaProjectAnswersApi.new),
        ),
        Provider(
          create: createApiProviderBuilder(IdeaProjectQuestionApi.new),
        ),
        Provider(
          create: createApiProviderBuilder(UsersApi.new),
        ),
        ChangeNotifierProvider(create: createConnectivityNotifier),
        ChangeNotifierProvider(create: createUsersNotifier),

        /// ********************************************
        /// *      API END
        /// ********************************************
        ///
        /// ********************************************
        /// *      IN MEMORY NOTIFIERS START
        /// ********************************************
        /// Keep _settings is global is important as it will not lose all
        /// changes during global rebuild
        ChangeNotifierProvider(create: (final context) => _settings),
        ChangeNotifierProvider(create: createEmojiProvider),
        ChangeNotifierProvider(create: createLastUsedEmojisProvider),
        ChangeNotifierProvider(create: createSpecialEmojisProvider),
        ChangeNotifierProvider(create: createFoldersNotifier),
        ChangeNotifierProvider(create: createCurrentFoldersNotifier),
        ChangeNotifierProvider(create: createIdeaProjectsNotifier),
        ChangeNotifierProvider(create: createIdeaProjectAnswersNotifier),
        ChangeNotifierProvider(create: createIdeaProjectQuestionsProvider),
        ChangeNotifierProvider(create: createNoteProjectsNotifier),
        ChangeNotifierProvider(create: createNotificationController),

        ChangeNotifierProvider<PaymentsControllerI>(
          create: (final context) => createMockPaymentsController(),
        ),

        /// ********************************************
        /// *      IN MEMORY NOTIFIERS END
        /// ********************************************
        ///
        /// ********************************************
        /// *      SERVER NOTIFIERS START
        /// ********************************************
        ///
        /// ********************************************
        /// *      SYNC SERVICES - CLIENT
        /// ********************************************
        Provider(create: ClientFolderSyncService.of),
        Provider(create: ClientIdeaSyncService.of),
        Provider(create: ClientIdeaAnswerSyncService.of),
        Provider(create: ClientIdeaQuestionSyncService.of),
        Provider(create: ClientNoteSyncService.of),

        /// ********************************************
        /// *      SYNC SERVICES - SERVER
        /// ********************************************
        Provider(create: createServerFolderSyncService),
        Provider(create: createServerProjectsSyncService),
        Provider(create: createServerIdeaAnswerSyncService),
        Provider(create: createServerIdeaQuestionSyncService),

        /// ********************************************
        /// *      UPDATERS
        /// ********************************************
        Provider(create: createFolderUpdater),
        Provider(create: createIdeaUpdater),
        Provider(create: createIdeaAnswerUpdater),
        Provider(create: createIdeaQuestionUpdater),
        Provider(create: createNoteUpdater),

        /// ********************************************
        /// *      SUBSCRIBERS
        /// ********************************************

        ChangeNotifierProvider(create: createFolderSubscriberNotifier),
        ChangeNotifierProvider(create: createProjectsSubscriberNotifier),
        ChangeNotifierProvider(create: createIdeaAnswerSubscriberNotifier),
        ChangeNotifierProvider(create: createIdeaQuestionSubscriberNotifier),

        /// ********************************************
        /// *      WORKER
        /// ********************************************
        ChangeNotifierProvider(create: createServerSyncWorkerNotifier)
      ],
      child: Portal(
        child: _AppStateInitializer(builder: builder),
      ),
    );
    if (DeviceRuntimeType.isNativeDesktop) {
      return child;
    }

    return Directionality(
      // TODO(arenukvern): replace with default device textDirection
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          Container(color: AppColors.black),
          child,
        ],
      ),
    );
  }
}

class _AppStateInitializer extends HookWidget {
  const _AppStateInitializer({
    required final this.builder,
    final Key? key,
  }) : super(key: key);
  final WidgetBuilder builder;

  @override
  Widget build(final BuildContext context) {
    final authState = useAppAuthState(
      supabaseClient: context.read(),
      usersNotifier: context.read(),
    );

    return Provider(
      create: (final context) => authState,
      child: StateLoader(
        initializer: GlobalStateInitializer(
          settings: context.read(),
          authState: authState,
        ),
        loader: const AppLoadingScreen(),
        child: builder(context),
      ),
    );
  }
}
