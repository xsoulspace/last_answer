import '../../core.dart';

class NotificationsRepository implements NotificationsDataSource {
  NotificationsRepository({
    required this.datasource,
  });
  final NotificationsDataSource datasource;
  @override
  Future<DateTime?> getLastReadDateTime() => datasource.getLastReadDateTime();

  @override
  Future<List<NotificationMessageModel>> getUpdatesNotifications() =>
      datasource.getUpdatesNotifications();

  @override
  Future<void> setLastReadTime() => datasource.setLastReadTime();
}
