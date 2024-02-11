import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/other/other.dart';

class ChangelogView extends StatelessWidget {
  const ChangelogView({super.key});

  @override
  Widget build(final BuildContext context) {
    final notificationController = context.read<NotificationsNotifier>();
    final updates = notificationController.updates;
    return ListView.builder(
      itemCount: updates.length,
      padding: const EdgeInsets.all(24),
      itemBuilder: (final context, final i) {
        final notification = updates[i];

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : 32, bottom: 24),
              child: ChangelogTile(notification: notification),
            ),
            Text(notification.message.localize(context)),
          ],
        );
      },
    );
  }
}
