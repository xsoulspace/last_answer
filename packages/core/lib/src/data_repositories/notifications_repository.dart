import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core.dart';

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
