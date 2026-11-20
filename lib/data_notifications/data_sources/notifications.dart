import 'package:lastanswer/common_imports.dart';

abstract interface class NotificationsDataSource {
  Future<DateTime?> getLastReadDateTime();
  Future<void> setLastReadTime();
  Future<List<NotificationMessageModel>> getUpdatesNotifications();
}
