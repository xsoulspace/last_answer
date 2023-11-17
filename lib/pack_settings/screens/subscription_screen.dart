import 'package:lastanswer/common_imports.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({
    required this.onBack,
    super.key,
  });
  final VoidCallback onBack;
  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.canvasColor,
      appBar: AppBar(
        centerTitle: true,
        leading: AdaptiveBackButton(onPressed: onBack),
        title: Text(S.current.subscription),
      ),
      body: const SubscriptionInfo(),
    );
  }
}
