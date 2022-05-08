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
    final screenLayout = ScreenLayout.of(context);

    Widget child = SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const FeatureCard(
            title: 'Sign in',
            description: 'But only if you want:)\n\n'
                'In future there will be data synchronization '
                'accross all devices, and to start using this '
                'feature - sign in will be required.',
            icon: Icon(Icons.login),
          ),
          const SizedBox(height: 18),
          SignInUpFilledButton(
            onPressed: state.signInWithDiscord,
            text: 'Sign In',
            hero: 'sign-in',
          ),
          const SizedBox(height: 18),
          SignInUpOutlinedButton(
            onPressed: state.signInWithDiscord,
            text: 'Sign Up',
            hero: 'sign-up',
          ),
        ],
      ),
    );
    if (screenLayout.small) {
      child = Expanded(
        child: child,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      child: Column(
        mainAxisSize: screenLayout.small ? MainAxisSize.max : MainAxisSize.min,
        children: [
          child,
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
    );
  }
}

class SignInUpFilledButton extends StatelessWidget {
  const SignInUpFilledButton({
    required this.onPressed,
    required this.text,
    required this.hero,
    final Key? key,
  }) : super(key: key);
  final VoidCallback onPressed;
  final String text;
  final String hero;
  @override
  Widget build(final BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 1,
      child: Hero(
        tag: hero,
        child: DecoratedActionButton(
          surfaceColor: AppColors.primary2,
          textColor: Theme.of(context).backgroundColor,
          filled: true,
          onPressed: onPressed,
          text: text,
        ),
      ),
    );
  }
}

class SignInUpOutlinedButton extends StatelessWidget {
  const SignInUpOutlinedButton({
    required this.onPressed,
    required this.text,
    required this.hero,
    final Key? key,
  }) : super(key: key);
  final VoidCallback onPressed;
  final String text;
  final String hero;
  @override
  Widget build(final BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 1,
      child: Hero(
        tag: hero,
        child: OutlinedActionButton(
          onPressed: onPressed,
          text: text,
        ),
      ),
    );
  }
}
