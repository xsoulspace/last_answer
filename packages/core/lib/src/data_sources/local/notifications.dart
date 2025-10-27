import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:xsoulspace_foundation/xsoulspace_foundation.dart';

import '../../../core.dart';

class NotificationDataSourceImpl implements NotificationsDataSource {
  NotificationDataSourceImpl({
    required this.localDbDataSource,
    required this.assetBundle,
  });
  final LocalDbI localDbDataSource;

  /// DefaultAssetBundle.of
  final AssetBundle assetBundle;
  @override
  Future<DateTime?> getLastReadDateTime() async {
    final datetimeStr = await localDbDataSource.getString(
      key: SharedPreferencesKeys.notificationUpdatesReadDateTime.name,
    );
    final milliseconds = int.tryParse(datetimeStr);
    if (milliseconds == null) return null;

    return DateTime.fromMillisecondsSinceEpoch(milliseconds);
  }

  @override
  Future<void> setLastReadTime() async {
    await localDbDataSource.setString(
      key: SharedPreferencesKeys.notificationUpdatesReadDateTime.name,
      value: DateTime.now().toUtc().millisecondsSinceEpoch.toString(),
    );
  }

  @override
  Future<List<NotificationMessageModel>> getUpdatesNotifications() async {
    final jsonStr = await assetBundle.loadString(
      Assets.json.updatesNotifications,
    );
    if (jsonStr.isEmpty) return [];
    final jsonList = List.castFrom<dynamic, Map<String, dynamic>>(
      jsonDecode(jsonStr) as List<dynamic>,
    );

    return jsonList.map(NotificationMessageModel.fromJson).toList();
  }
}
