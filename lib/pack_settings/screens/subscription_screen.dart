part of pack_settings;

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({
    required final this.onBack,
    final Key? key,
  }) : super(key: key);
  final VoidCallback onBack;
  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.canvasColor,
      appBar: AppBar(
        leading: AdaptiveBackButton(onPressed: onBack),
        title: Text(S.current.myAccount),
      ),
      // TODO(arenukvern): replace with subscription screen
      body: const MyAccount(),
    );
  }
}
