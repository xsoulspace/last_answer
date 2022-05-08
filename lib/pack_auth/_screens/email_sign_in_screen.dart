part of pack_auth;

Future<void> showEmailSignInScreen({
  required final BuildContext context,
}) async {
  await showFrostedDialog(
    context: context,
    builder: (final context) => const FrostedDialog(
      content: FrostedDialogContent(
        title: 'Sign in',
        content: EmailSignInScreen(),
      ),
    ),
  );
}

class EmailSignInScreen extends HookWidget {
  const EmailSignInScreen({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context) {
    final state = useEmailSignInScreenState();

    return Column(
      children: [],
    );
  }
}
