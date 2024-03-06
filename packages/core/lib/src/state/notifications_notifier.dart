part of 'state.dart';

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
  NotificationsNotifier(final BuildContext context)
      : _notificationRepository = context.read(),
        _projectsRepository = context.read(),
        super(const NotificationsNotifierState());
  final NotificationsRepository _notificationRepository;
  final ProjectsRepository _projectsRepository;

  Future<void> readAllUpdates() async {
    setValue(value.copyWith(hasUnreadUpdates: false));
    await _notificationRepository.setLastReadTime();
  }

  List<NotificationMessageModel> get updates => value.updates;
  bool get hasUnreadUpdates => value.hasUnreadUpdates;
  Future<void> determineUnreadUpdates() async {
    final lastReadTime = await _notificationRepository.getLastReadDateTime();
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
        await _notificationRepository.getUpdatesNotifications();
    await determineUnreadUpdates();
    setValue(value.copyWith(updates: notifications));

    /// always update project, to make sure, it is up to date
    /// That's absolutely okay if project is not created yet
    /// or it is different in projects
    final project = ProjectModel.getSystemChangelogFromNotifications(
      notifications: notifications,
    );
    await _projectsRepository.put(project: project);
  }
}
