part of pack_app;

Future<void> showNotificationDialog({
  required final BuildContext context,
}) async {
  await showFrostedDialog(
    context: context,
    builder: (final context) => const UpdateNotificaionDialogContent(),
  );
}

class UpdateNotificaionDialogContent extends StatelessWidget {
  const UpdateNotificaionDialogContent({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context) {
    final notificationController = context.watch<NotificationController>();
    final updates = notificationController.updates;
    final lastMessage = updates.first;
    final language = intl.Intl.getCurrentLocale();
    final theme = Theme.of(context);

    return FrostedDialogContent(
      onClose: (final context) {
        notificationController.readAllUpdates();
      },
      title: lastMessage.title.getByLanguage(language),
      onWillPop: () async {
        await notificationController.readAllUpdates();

        return true;
      },
      content: ListView.separated(
        separatorBuilder: (final _, final index) {
          final notification = updates[index + 1];
          Widget child = ListTile(
            title: SelectableText(
              notification.title.getByLanguage(language),
              style: theme.textTheme.headline5,
            ),
            subtitle: SelectableText(
              intl.DateFormat.yMd().format(notification.created.toLocal()),
              style: theme.textTheme.subtitle2,
            ),
          );

          if (index == 0) {
            child = Column(
              children: [
                Divider(color: theme.highlightColor),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 35.0),
                  child: Text(
                    'PREVIOUS UPDATES',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.subtitle2,
                  ),
                ),
                Divider(color: theme.highlightColor),
                const SizedBox(height: 35),
                child,
              ],
            );
          }

          return Padding(
            padding: const EdgeInsets.only(top: 95.0, bottom: 24),
            child: child,
          );
        },
        shrinkWrap: true,
        itemCount: updates.length,
        padding: const EdgeInsets.all(24),
        itemBuilder: (final context, final i) {
          final notification = updates[i];

          return SelectableText(
            notification.message.getByLanguage(language),
            key: ValueKey(notification.id),
          );
        },
      ),
      leftAction: const JoinDiscordButton(text: 'Discord'),
    );
  }
}
