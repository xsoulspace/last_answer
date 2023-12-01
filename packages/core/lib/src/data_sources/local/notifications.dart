import 'dart:convert';

import 'package:flutter/widgets.dart';

import '../../../core.dart';
import '../interfaces/notifications.dart';

class NotificationDataSourceImpl implements NotificationsDataSource {
  NotificationDataSourceImpl({
    required this.localDbDataSource,
    required this.assetBundle,
  });
  final LocalDbDataSource localDbDataSource;

  /// DefaultAssetBundle.of
  final AssetBundle assetBundle;
  @override
  Future<DateTime?> getLastReadDateTime() async {
    final datetimeStr = localDbDataSource.getString(
      key: SharedPreferencesKeys.notificationUpdatesReadDateTime.name,
    );
    final miliseconds = int.tryParse(datetimeStr);
    if (miliseconds == null) return null;

    return DateTime.fromMillisecondsSinceEpoch(miliseconds);
  }

  @override
  Future<void> setLastReadTime() async {
    localDbDataSource.setString(
      key: SharedPreferencesKeys.notificationUpdatesReadDateTime.name,
      value: DateTime.now().toUtc().millisecondsSinceEpoch.toString(),
    );
  }

  @override
  Future<List<NotificationMessageModel>> getUpdatesNotifications() async {
    final jsonStr =
        await assetBundle.loadString(Assets.json.updatesNotifications);
    if (jsonStr.isEmpty) return [];
    final jsonList =
        List.castFrom<dynamic, Map<String, dynamic>>(jsonDecode(jsonStr));

    return jsonList.map(NotificationMessageModel.fromJson).toList();
  }
}
