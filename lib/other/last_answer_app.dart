import 'dart:convert';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/other/feedback.dart';
import 'package:lastanswer/router.dart';
import 'package:lastanswer/settings/features/features.dart';

class LastAnswerApp extends StatelessWidget {
  const LastAnswerApp({super.key});
  @override
  Widget build(final BuildContext context) => FeedbackProvider(
    child: GlobalStatesProvider(
      builder: (final context) => const Portal(child: _AppScaffold()),
    ),
  );
}

class _AppScaffold extends StatefulWidget {
  const _AppScaffold();

  @override
  State<_AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<_AppScaffold> {
  late final _initializer = GlobalStatesInitializer(
    dto: GlobalStatesInitializerDto(context: context),
    router: appRouter,
  );
  @override
  void initState() {
    super.initState();
    unawaited(_initializer.onLoad());
    _initStorageBackends();
  }

  /// Loads persisted storage-backend selection and wires the payload
  /// hooks so MCP tools can back up / restore without the widget tree.
  void _initStorageBackends() {
    final notifier = StorageBackendsNotifier.instance;
    unawaited(notifier.load());
    assert(() {
      StorageBackendsNotifier.payloadBuilder = () async => jsonEncode(
        DbSaveModel(
          projects: await context.read<ProjectsRepository>().getAll(),
          tags: (await context.read<TagsRepository>().getAll())
              .values
              .toList(),
        ).toJson(),
      );
      StorageBackendsNotifier.restoreApplier = (final jsonPayload) async {
        if (!mounted) return;
        final dbSave = DbSaveModel.fromJson(
          jsonDecode(jsonPayload) as Map<String, dynamic>,
        );
        if (dbSave.isEmpty) return;
        await context.read<AppNotifier>().restoreFromDbSave(
          dbSave: dbSave,
          context: context,
        );
      };
      return true;
    }());
  }

  @override
  Widget build(final BuildContext context) {
    final locale = context.select<UserNotifier, Locale>(
      (final c) => c.locale.value,
    );
    final themeMode = context.select<UserNotifier, ThemeMode>(
      (final c) => c.settings.themeMode,
    );
    return MaterialApp.router(
      /// Providing a restorationScopeId allows the Navigator built by
      /// the MaterialApp to restore the navigation stack when a user
      /// leaves and returns to the app after it has been killed while
      /// running in the background.
      restorationScopeId: 'app',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: locale,
      supportedLocales: Locales.values,
      onGenerateTitle: (final context) => context.l10n.lastAnswer,
      theme: lightThemeData,
      darkTheme: darkThemeData,
      themeMode: themeMode,
      routerDelegate: appRouter.routerDelegate,
      routeInformationProvider: appRouter.routeInformationProvider,
      routeInformationParser: appRouter.routeInformationParser,
    );
  }
}
