import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core.dart';
import '../data_repositories/purchases_repository.dart';

class GlobalStatesProvider extends StatelessWidget {
  const GlobalStatesProvider({
    required this.builder,
    super.key,
  });
  final WidgetBuilder builder;
  @override
  Widget build(final BuildContext context) => MultiProvider(
        providers: [
          /// dependentless state distributors
          ChangeNotifierProvider(create: RemoteUserNotifier.new),
          ChangeNotifierProvider(create: AppFeaturesNotifier.new),

          /// services, repos
          Provider<RemoteClient>(
            create: (final context) => RemoteClientServerpodImpl(
              host: Envs.serverHost,
            ),
          ),
          Provider(create: ComplexLocalDbIsarImpl.new),
          Provider<LocalDbDataSource>(
            create: SharedPreferencesDbDataSourceImpl.new,
          ),
          Provider<ComplexLocalDb>(
            create: (final context) => context.read<ComplexLocalDbIsarImpl>(),
          ),
          ChangeNotifierProvider<PurchasesIapService>(
            create: PurchasesIapGoogleAppleImpl.new,
          ),
          ChangeNotifierProvider(create: PurchasesAdsService.new),
          Provider(create: PurchasesRepository.new),
          Provider(create: EmojiRepository.new),
          Provider(create: LastUsedEmojiRepository.new),
          Provider(create: UserRepository.new),
          Provider(create: NotificationsRepository.new),
          Provider(create: ProjectsRepository.new),

          /// notifiers & blocs
          ChangeNotifierProvider(create: EmojiStateNotifier.new),
          ChangeNotifierProvider(create: LastEmojiStateNotifier.new),
          ChangeNotifierProvider(create: SpecialEmojiStateNotifier.new),
          ChangeNotifierProvider(create: NotificationsNotifier.new),
          ChangeNotifierProvider(create: ProjectsNotifier.new),
          ChangeNotifierProvider(create: PurchasesNotifier.new),
          ChangeNotifierProvider(create: UserNotifier.new),
          ChangeNotifierProvider(create: AppNotifier.new),
          ChangeNotifierProvider(create: OpenedProjectNotifier.new),
        ],
        child: Builder(builder: builder),
      );
}
