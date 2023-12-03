import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core.dart';

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
            create: (final context) => RemoteClientServerpodImpl(),
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
          Provider(create: EmojiRepository.provide),
          Provider(create: LastUsedEmojiRepository.provide),
          Provider(create: UserRepository.provide),
          Provider(create: NotificationsRepository.provide),
          Provider(create: ProjectsRepository.provide),
          ChangeNotifierProvider(create: EmojiStateNotifier.provide),
          ChangeNotifierProvider(create: LastEmojiStateNotifier.provide),
          ChangeNotifierProvider(create: SpecialEmojiStateNotifier.provide),
          ChangeNotifierProvider(create: NotificationsNotifier.provide),
          ChangeNotifierProvider(create: ProjectsNotifier.provide),
          ChangeNotifierProvider(create: UserNotifier.provide),
          ChangeNotifierProvider(create: AppNotifier.provide),
          ChangeNotifierProvider(create: OpenedProjectNotifier.provide),
        ],
        child: Builder(builder: builder),
      );
}
