part of pack_settings;

class MyAccountScreen extends StatelessWidget {
  const MyAccountScreen({
    required final this.onBack,
    required this.onSignIn,
    final Key? key,
  }) : super(key: key);
  final VoidCallback onBack;
  final VoidCallback onSignIn;
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
      body: MyAccount(
        onSignIn: onSignIn,
      ),
    );
  }
}
