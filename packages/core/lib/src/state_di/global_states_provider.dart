import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:universal_storage_interface/universal_storage_interface.dart';
import 'package:universal_storage_local_db/universal_storage_local_db.dart';
import 'package:xsoulspace_foundation/xsoulspace_foundation.dart';

import '../../core.dart';

class GlobalStatesProvider extends StatelessWidget {
  const GlobalStatesProvider({required this.builder, super.key});
  final WidgetBuilder builder;
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
      Provider<DocInferencePort?>(create: (_) => null),

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
    ],
    child: Builder(builder: builder),
  );
}
