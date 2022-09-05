import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lastanswer/pack_app/notifications/notification_message.dart';
import 'package:lastanswer/pack_app/notifications/notifications_service.dart';
import 'package:life_hooks/life_hooks.dart';

class NotificationController extends ChangeNotifier
    implements ContextfulLoadable {
  NotificationController({
    required this.notificationService,
  });
  final NotificationService notificationService;

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
  Future<void> onLoad(final BuildContext context) async {
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
    );
