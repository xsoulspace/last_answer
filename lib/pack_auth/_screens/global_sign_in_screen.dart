part of pack_auth;

class GlobalSignInScreen extends HookWidget {
  const GlobalSignInScreen({
    final Key? key,
  }) : super(key: key);
  @override
  Widget build(final BuildContext context) {
    final state = useGlobalSignInScreenState(
      authState: context.read(),
    );

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const FeatureCard(
                      title: 'Sign in',
                      description: 'But only if you want:)\n\n'
                          'In future there will be data synchronization accross '
                          'all devices, and to start using this feature - '
                          'sign in will be required.',
                      icon: Icon(Icons.login),
                    ),
                    const SizedBox(height: 18),
                    ValueListenableBuilder<bool>(
                      valueListenable: state.isLoading,
                      builder: (final context, final loading, final child) {
                        return FractionallySizedBox(
                          widthFactor: 1,
                          child: DecoratedActionButton(
                            surfaceColor: AppColors.primary2,
                            textColor: Theme.of(context).backgroundColor,
                            filled: true,
                            onPressed: loading ? null : state.signInWithDiscord,
                            text: loading ? 'Loading' : 'Sign In',
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    ValueListenableBuilder<bool>(
                      valueListenable: state.isLoading,
                      builder: (final context, final loading, final child) {
                        return FractionallySizedBox(
                          widthFactor: 1,
                          child: OutlinedActionButton(
                            onPressed: loading ? null : state.signInWithDiscord,
                            text: loading ? 'Loading' : 'Sign Up',
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            if (state.authState.discordSignInAvailable) ...[
              const SizedBox(height: 18),
              const Text('Sign in with'),
              const SizedBox(height: 18),
              ValueListenableBuilder<bool>(
                valueListenable: state.isLoading,
                builder: (final context, final loading, final child) {
                  return loading
                      ? const CircularProgress()
                      : SignInDiscordButton(
                          onPressed: () => state.signInWithDiscord,
                        );
                },
              ),
              const SizedBox(height: 18),
              const BottomSafeArea()
            ]
          ],
        ),
      ),
    );
  }
}
