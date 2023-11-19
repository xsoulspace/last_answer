import 'dart:math' as math;

import 'package:intl/intl.dart' as intl;
import 'package:lastanswer/_library/widgets/widgets.dart';
import 'package:lastanswer/common_imports.dart';

Future<void> showNotificationDialog({
  required final BuildContext context,
  required final NotificationsNotifier notificationController,
}) async {
  await showAdaptiveDialog(
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
        child: NavigatorPopHandler(
          onPop: notificationController.readAllUpdates,
          child: SizedBox(
            height: height,
            width: width,
            child: const UpdateNotificationDialog(),
          ),
        ),
      );
    },
  );
}

class UpdateNotificationDialog extends StatelessWidget {
  const UpdateNotificationDialog({super.key});

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final notificationController = context.read<NotificationsNotifier>();
    final updates = notificationController.updates;
    final lastMessage = updates.first;
    void close() {
      unawaited(notificationController.readAllUpdates());
      Navigator.pop(context);
    }

    final screenLayout = ScreenLayout.of(context);

    return DecoratedBox(
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
                    padding: const EdgeInsets.all(14),
                    child: CloseButton(
                      onPressed: close,
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 18),
                    child: SelectableText(
                      lastMessage.title.localize(context),
                      textAlign: TextAlign.center,
                      style: textTheme.displayLarge,
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
                    notification.title.localize(context),
                    style: theme.textTheme.headlineSmall,
                  ),
                  subtitle: SelectableText(
                    intl.DateFormat.yMd()
                        .format(notification.created.toLocal()),
                    style: theme.textTheme.titleSmall,
                  ),
                );

                if (index == 0) {
                  child = Column(
                    children: [
                      Divider(color: theme.highlightColor),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 35),
                        child: Text(
                          'PREVIOUS UPDATES',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                      Divider(color: theme.highlightColor),
                      const SizedBox(height: 35),
                      child,
                    ],
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 95, bottom: 24),
                  child: child,
                );
              },
              shrinkWrap: true,
              itemCount: updates.length,
              padding: const EdgeInsets.all(24),
              itemBuilder: (final context, final i) {
                final notification = updates[i];

                return SelectableText(
                  notification.message.localize(context),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const DiscordButton(text: 'Discord'),
                const Spacer(),
                TextButton(
                  onPressed: close,
                  child: Text(
                    context.l10n.close.sentenceCase,
                    style: textTheme.bodyLarge,
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
