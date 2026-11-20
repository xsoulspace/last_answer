import 'package:material_ui/material_ui.dart' show ThemeMode, Colors, Icons, Brightness, MaterialLocalizations, GlobalMaterialLocalizations, DefaultMaterialLocalizations;
import 'package:provider/provider.dart';

import 'package:lastanswer/common_imports.dart';

class NotificationsRepository implements NotificationsDataSource {
  NotificationsRepository(final BuildContext context)
      : _datasource = NotificationDataSourceImpl(
          localDbDataSource: context.read(),
          assetBundle: DefaultAssetBundle.of(context),
        );
  final NotificationsDataSource _datasource;
  @override
  Future<DateTime?> getLastReadDateTime() => _datasource.getLastReadDateTime();

  @override
  Future<List<NotificationMessageModel>> getUpdatesNotifications() =>
      _datasource.getUpdatesNotifications();

  @override
  Future<void> setLastReadTime() => _datasource.setLastReadTime();
}
