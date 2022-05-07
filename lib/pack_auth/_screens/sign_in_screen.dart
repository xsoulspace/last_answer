part of pack_auth;

class SignInScreen extends HookWidget {
  const SignInScreen({
    final Key? key,
  }) : super(key: key);
  @override
  Widget build(final BuildContext context) {
    final state = useSignInScreenState(
      authState: context.read(),
    );

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        children: [
          const Text('Sign in via Discord'),
          const SizedBox(height: 18),
          ValueListenableBuilder<bool>(
            valueListenable: state.isLoading,
            builder: (final context, final loading, final child) {
              return ElevatedButton(
                onPressed: loading ? null : state.signInWithDiscord,
                child: Text(loading ? 'Loading' : 'Discord Sign In'),
              );
            },
          ),
          ElevatedButton(
            onPressed: state.onSignOut,
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}
