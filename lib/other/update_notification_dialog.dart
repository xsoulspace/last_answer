import 'dart:math' as math;

import 'package:intl/intl.dart' as intl;
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/widgets/legacy_kit/legacy_kit.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

/// The community invite (was `DiscordButton` in the legacy kit).
const _discordLink = 'https://discord.gg/y54DpJwmAn';

Future<void> showNotificationDialog({
  required final BuildContext context,
  required final NotificationsNotifier notificationController,
}) async {
  await showLaDialog(
    context: context,
    builder: (final context) {
      final theme = context.laUi;
      final isDark = theme.isDark;
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

      return LaBox(
        floating: true,
        color: theme.surfaceOverlay,
        radius: defaultPopupBorderRadius,
        border: BorderSide(
          color: isDark ? theme.ink : theme.rule.withValues(alpha: 0.2),
        ),
        width: width,
        height: height,
        child: NavigatorPopHandler(
          onPop: notificationController.readAllUpdates,
          child: const ChangelogDialog(),
        ),
      );
    },
  );
}

class ChangelogDialog extends StatelessWidget {
  const ChangelogDialog({super.key});

  @override
  Widget build(final BuildContext context) {
    final theme = context.laUi;
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
                    padding: const EdgeInsets.all(8),
                    child: LaButton.icon(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: close,
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 18),
                    child: LaSelectableText(
                      lastMessage.title.localize(context),
                      textAlign: TextAlign.center,
                      style: theme.display,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                LaButton(
                  variant: LaButtonVariant.link,
                  label: 'Discord',
                  onPressed: () async {
                    final uri = Uri.parse(_discordLink);
                    if (await url_launcher.canLaunchUrl(uri)) {
                      await url_launcher.launchUrl(uri);
                    }
                  },
                ),
                const Spacer(),
                LaButton(
                  variant: LaButtonVariant.ghost,
                  onPressed: close,
                  label: context.l10n.close.sentenceCase,
                ),
              ],
            ),
          ),
          const Expanded(child: ChangelogBody()),
          const BottomSafeArea(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class ChangelogBody extends StatelessWidget {
  const ChangelogBody({super.key});
  @override
  Widget build(final BuildContext context) {
    final notificationController = context.read<NotificationsNotifier>();
    final updates = notificationController.updates;
    final theme = context.laUi;
    return ListView.separated(
      separatorBuilder: (final context, final index) {
        final notification = updates[index + 1];
        Widget child = ChangelogTile(notification: notification);

        if (index == 0) {
          child = Column(
            children: [
              const LaHairline(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 35),
                child: Text(
                  'PREVIOUS UPDATES',
                  textAlign: TextAlign.center,
                  style: theme.emphasis,
                ),
              ),
              const LaHairline(),
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

        return LaSelectableText(
          notification.message.localize(context),
        );
      },
    );
  }
}

class ChangelogTile extends StatelessWidget {
  const ChangelogTile({
    required this.notification,
    super.key,
  });
  final NotificationMessageModel notification;
  @override
  Widget build(final BuildContext context) {
    final theme = context.laUi;
    return LaRow(
      title: LaSelectableText(
        notification.title.localize(context),
        style: theme.section,
      ),
      meta: LaSelectableText(
        intl.DateFormat.yMd().format(notification.created.toLocal()),
        style: theme.emphasis,
      ),
    );
  }
}
