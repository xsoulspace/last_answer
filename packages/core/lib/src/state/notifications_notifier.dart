import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:provider/provider.dart';

import '../../core.dart';

part 'notifications_notifier.freezed.dart';

@freezed
class NotificationsNotifierState with _$NotificationsNotifierState {
  const factory NotificationsNotifierState({
    /// Should be ordered from newest to oldest and never be
    @Default([]) final List<NotificationMessageModel> updates,
    @Default(false) final bool hasUnreadUpdates,
  }) = _NotificationsNotifierState;
}

class NotificationsNotifier extends ValueNotifier<NotificationsNotifierState>
    implements Loadable {
  NotificationsNotifier({
    required this.notificationRepository,
  }) : super(const NotificationsNotifierState());
  factory NotificationsNotifier.provide(final BuildContext context) =>
      NotificationsNotifier(
        notificationRepository: context.read(),
      );
  final NotificationsRepository notificationRepository;

  Future<void> readAllUpdates() async {
    setValue(value.copyWith(hasUnreadUpdates: false));
    await notificationRepository.setLastReadTime();
  }

  List<NotificationMessageModel> get updates => value.updates;
  bool get hasUnreadUpdates => value.hasUnreadUpdates;
  Future<void> determineUnreadUpdates() async {
    final lastReadTime = await notificationRepository.getLastReadDateTime();
    if (lastReadTime == null) {
      setValue(value.copyWith(hasUnreadUpdates: true));
    } else {
      if (updates.isEmpty) {
        setValue(value.copyWith(hasUnreadUpdates: false));

        return;
      }
      final dateTimeComparation =
          updates.firstOrNull?.created.toUtc().compareTo(lastReadTime) ?? 0;
      setValue(value.copyWith(hasUnreadUpdates: dateTimeComparation > 0));
    }
  }

  @override
  Future<void> onLoad() async {
    final notifications =
        await notificationRepository.getUpdatesNotifications();
    await determineUnreadUpdates();
    setValue(value.copyWith(updates: notifications));
  }
}
