import 'package:la_design_core/la_design_core.dart';

import '../base/widget.dart';

void main() {
  Widget bar(final BuildContext context) {
    final theme = AppTheme.of(context);
    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: theme.radius.asBorderRadius().small,
        color: theme.colors.actionBarBackground,
      ),
    );
  }

  AppNotification notification(final BuildContext context) {
    final theme = AppTheme.of(context);
    return AppNotification(
      title: 'Save 50% on shields this week',
      description: 'See the offer',
      icon: theme.icons.characters.tag,
    );
  }

  testAppWidgets(
    'notifiable_bar',
    {
      'opened': Builder(
        builder: (final context) {
          return AppNotifiableBarLayout.opened(
            notification: notification(context),
            child: bar(context),
          );
        },
      ),
      'closed': Builder(
        builder: (final context) {
          return AppNotifiableBarLayout.closed(
            child: bar(context),
          );
        },
      ),
    },
  );
}
