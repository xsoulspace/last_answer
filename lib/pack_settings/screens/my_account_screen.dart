part of pack_settings;

class MyAccountScreen extends StatelessWidget {
  const MyAccountScreen({
    required final this.onBack,
    final Key? key,
  }) : super(key: key);
  final VoidCallback onBack;
  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final screenLayout = ScreenLayout.of(context);

    return Scaffold(
      backgroundColor: theme.canvasColor,
      appBar: BackTextUniversalAppBar(
        useBackButton: true,
        screenLayout: screenLayout,
        onBack: onBack,
        titleStr: S.current.myAccount,
      ),
      body: const MyAccount(),
    );
  }
}
