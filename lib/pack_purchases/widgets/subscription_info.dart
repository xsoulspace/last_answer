import 'package:flutter/material.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_purchases/pack_purchases.dart';
import 'package:lastanswer/pack_settings/pack_settings.dart';
import 'package:provider/provider.dart';

class SubscriptionInfo extends StatelessWidget {
  const SubscriptionInfo({super.key});

  @override
  Widget build(final BuildContext context) {
    final paymentsController = context.read<PaymentsController>();

    return SettingsListContainer(
      builder: paymentsController.isPatronSubscription
          ? getPatronSubscriptionBlocks
          : getFreeSubscriptionBlocks,
    );
  }

  // TODO(arenkuvern): refactor to different widgets
  // ignore: long-method
  List<Widget> getFreeSubscriptionBlocks(
    final BuildContext context,
    final double leftColumnWidth,
  ) {
    final paymentsController = context.read<PaymentsController>();
    final theme = Theme.of(context);
    final screenLayout = ScreenLayout.of(context);

    return [
      Row(
        children: [
          RichText(
            text: TextSpan(
              style: theme.textTheme.titleLarge,
              children: [
                TextSpan(
                  text: 'Patron\n',
                  style: theme.textTheme.displayLarge,
                ),
                const TextSpan(text: 'Subscription'),
              ],
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {},
            child: SizedBox(
              width: screenLayout.small ? 180 : null,
              child: Text(
                paymentsController.monthlySubscriptionTitle,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 40),
      Text(
        'Enhance this app for your writing mood.',
        style: theme.textTheme.displaySmall,
      ),
      const SizedBox(height: 40),
      const Text("What's included:"),
      const SizedBox(height: 24),
      const Wrap(
        children: [
          FeatureCard(
            title: 'Synchronization',
            description:
                'Synchronize your Notes & Ideas for all devices, including '
                'desktops MacOS, Linux, Windows and mobile iOS, iPad, Android',
            icon: Icon(Icons.sync_rounded),
          ),
          FeatureCard(
            title: 'Folders',
            description: 'Use folders to orginize your Notes & Ideas',
            icon: Icon(Icons.folder_rounded),
          ),
          FeatureCard(
            title: 'Customizations',
            description:
                'Use beautiful Unsplash photos to make Notes & Ideas list '
                'unique and memorizable',
            icon: Icon(Icons.photo_size_select_actual_rounded),
          ),
          FeatureCard(
            title: 'Support Open Source',
            description: 'This app is an Open Source software and '
                'your support makes possible to keep it that way, '
                'and provides more time for quality and usabily updates.',
            icon: Icon(Icons.code_rounded),
          ),
        ],
      ),
      const SizedBox(height: 40),
      Center(
        child: TextButton(
          onPressed: () {},
          child: Text(
            paymentsController.monthlySubscriptionTitle,
            textAlign: TextAlign.center,
          ),
        ),
      ),
      const SizedBox(height: 14),
      Center(
        child: TextButton(
          onPressed: () {},
          child: Text(
            paymentsController.annualSubscriptionTitle,
            textAlign: TextAlign.center,
          ),
        ),
      ),
      const SizedBox(height: 14),
      const BottomSafeArea(),
    ];
  }

  List<Widget> getPatronSubscriptionBlocks(
    final BuildContext context,
    final double leftColumnWidth,
  ) =>
      [
        const Row(
          children: [
            Text('You are a Patron!'),
            Text('Which means:'),
          ],
        ),
      ];
}

class FeatureCard extends StatelessWidget {
  const FeatureCard({
    required this.title,
    required this.description,
    required this.icon,
    super.key,
  });
  final String title;
  final String description;
  final Widget icon;
  @override
  Widget build(final BuildContext context) => Card(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 10,
          ),
          title: Text(title, style: Theme.of(context).textTheme.headlineSmall),
          subtitle: Text(description),
          leading: icon,
        ),
      );
}
