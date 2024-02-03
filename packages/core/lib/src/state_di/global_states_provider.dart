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
          Provider<RemoteClient>(
            create: (final context) => RemoteClientServerpodImpl(
              host: Envs.serverHost,
            ),
          ),
          Provider<ComplexLocalDbIsarImpl>(
            create: (final context) => ComplexLocalDbIsarImpl(),
          ),
          Provider<LocalDbDataSource>(
            create: (final context) => SharedPreferencesDbDataSourceImpl(),
          ),
          Provider<ComplexLocalDb>(
            /// for initialization
            create: (final context) => context.read<ComplexLocalDbIsarImpl>(),
          ),
          ChangeNotifierProvider<PurchasesIapService>(
            /// for initialization
            create: (final context) => PurchasesIapGoogleAppleImpl(),
          ),
          Provider(create: PurchasesRepository.new),
          Provider(create: EmojiRepository.new),
          Provider(create: LastUsedEmojiRepository.new),
          Provider(create: UserRepository.new),
          Provider(create: NotificationsRepository.new),
          Provider(create: ProjectsRepository.new),
          ChangeNotifierProvider(create: RemoteUserNotifier.new),
          ChangeNotifierProvider(create: EmojiStateNotifier.provide),
          ChangeNotifierProvider(create: LastEmojiStateNotifier.provide),
          ChangeNotifierProvider(create: SpecialEmojiStateNotifier.provide),
          ChangeNotifierProvider(create: NotificationsNotifier.provide),
          ChangeNotifierProvider(create: ProjectsNotifier.provide),
          ChangeNotifierProvider(create: PurchasesNotifier.provide),
          ChangeNotifierProvider(create: UserNotifier.new),
          ChangeNotifierProvider(create: AppNotifier.provide),
          ChangeNotifierProvider(create: OpenedProjectNotifier.provide),
        ],
        child: Builder(builder: builder),
      );
}
