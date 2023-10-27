part of pack_settings;

class MyAccountScreen extends StatelessWidget {
  const MyAccountScreen({
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
        title: Text(S.current.myAccount),
      ),
      body: const MyAccount(),
    );
  }
}
