part of '../pack_app.dart';

class NotificationController extends ChangeNotifier implements Loadable {
  NotificationController({
    required this.context,
    required this.notificationService,
  });
  final NotificationService notificationService;
  final BuildContext context;

  Future<void> readAllUpdates() async {
    _hasUnreadUpdates = false;
    notifyListeners();
    await notificationService.readUpdates();
  }

  bool _hasUnreadUpdates = true;
  bool get hasUnreadUpdates => _hasUnreadUpdates;
  Future<void> determineUnreadUpdates() async {
    final lastReadTime =
        await notificationService.notificationUpdatesReadDateTime;
    if (lastReadTime == null) {
      _hasUnreadUpdates = true;
    } else {
      if (updates.isEmpty) {
        _hasUnreadUpdates = false;

        return;
      }
      final dateTimeComparation =
          updates.first.created.toUtc().compareTo(lastReadTime);
      _hasUnreadUpdates = dateTimeComparation > 0;
    }
  }

  /// Should be ordered from newest to oldest and never be
  final List<NotificationMessage> updates = [];

  @override
  Future<void> onLoad() async {
    final notifications = await notificationService.getUpdatesNotifications(
      context: context,
    );
    updates.addAll(notifications);
    await determineUnreadUpdates();
    notifyListeners();
  }
}

NotificationController createNotificationController(
  final BuildContext context,
) =>
    NotificationController(
      notificationService: NotificationService(),
      context: context,
    );
