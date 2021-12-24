part of pack_app;

Future<void> showNotificationPopup({
  required final BuildContext context,
  required final NotificationController notificationController,
}) async {
  await showDialog(
    context: context,
    builder: (final context) {
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;
      final size = MediaQuery.of(context).size;
      final screenLayout = ScreenLayout.of(context);
      final double? width = screenLayout.small
          ? null
          : math.min(
              size.width * 0.6,
              600,
            );
      final double? height = screenLayout.small
          ? null
          : math.min(
              size.height * 0.85,
              600,
            );

      return Dialog(
        insetPadding: screenLayout.small ? EdgeInsets.zero : null,
        shape: RoundedRectangleBorder(
          borderRadius: defaultPopupBorderRadius,
          side: BorderSide(
            color: (isDark ? AppColors.cleanBlack : AppColors.grey4)
                .withOpacity(0.2),
          ),
        ),
        child: WillPopScope(
          onWillPop: () async {
            await notificationController.readAllUpdates();

            return true;
          },
          child: SizedBox(
            height: height,
            width: width,
            child: const UpdateNotificaionPopup(),
          ),
        ),
      );
    },
  );
}

class UpdateNotificaionPopup extends StatelessWidget {
  const UpdateNotificaionPopup({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final notificationController = context.read<NotificationController>();
    final updates = notificationController.updates;
    final lastMessage = updates.first;
    final language = intl.Intl.getCurrentLocale();
    void close() {
      notificationController.readAllUpdates();
      Navigator.pop(context);
    }

    final screenLayout = ScreenLayout.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: defaultPopupBorderRadius,
      ),
      child: Column(
        children: [
          if (screenLayout.small) const SizedBox(height: 10),
          SizedBox(
            height: 50,
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: CloseButton(
                      onPressed: close,
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 18.0),
                    child: SelectableText(
                      lastMessage.title.getByLanguage(language),
                      textAlign: TextAlign.center,
                      style: textTheme.headline1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: ListView.separated(
              separatorBuilder: (final _, final index) {
                final notification = updates[index + 1];
                Widget child = ListTile(
                  title: SelectableText(
                    notification.title.getByLanguage(language),
                    style: theme.textTheme.headline5,
                  ),
                  subtitle: SelectableText(
                    intl.DateFormat.yMd()
                        .format(notification.created.toLocal()),
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
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                const DiscordButton(text: 'Discord'),
                const Spacer(),
                TextButton(
                  onPressed: close,
                  child: Text(
                    S.current.close.sentenceCase,
                    style: textTheme.bodyText1,
                  ),
                ),
              ],
            ),
          ),
          const BottomSafeArea(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
