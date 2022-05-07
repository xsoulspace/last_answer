part of pack_auth;

AuthState useAppAuthState() => use(
      ContextfulLifeHook(
        debugLabel: 'AuthState',
        state: AuthState(),
      ),
    );

class AuthState extends SupabaseAuthLifeState {
  ValueNotifier<bool> authenticated = ValueNotifier(false);

  @override
  void initState() {
    startAuthObserver();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    stopAuthObserver();
  }

  Future<void> signInWithDiscord() async {
    return _signInWithProvider(provider: Provider.discord);
  }

  Future<void> _signInWithProvider({required final Provider provider}) async {
    final supabase = context.read<SupabaseClient>();

    String? redirectTo;

    if (kIsWeb) {
    } else if (Platform.isAndroid || Platform.isIOS) {
      redirectTo = 'dev.xsoulspace.lastanswer://login-callback/';
    }
    final GotrueSessionResponse res = await supabase.auth.signIn(
      provider: provider,
      options: AuthOptions(
        redirectTo: redirectTo,
      ),
    );

    if (res.url != null) {
      final authUri = Uri.parse(res.url!);
      LaunchMode mode = LaunchMode.platformDefault;
      if (kIsWeb) {
      } else if (Platform.isIOS || Platform.isAndroid) {
        mode = LaunchMode.externalApplication;
      }

      await launchUrl(
        authUri,
        webOnlyWindowName: '_self',
        mode: mode,
      );
    }
  }

  Future<GotrueResponse> signOut() async {
    final supabase = context.read<SupabaseClient>();

    return supabase.auth.signOut();
  }

  @override
  void onUnauthenticated() {
    authenticated.value = false;
  }

  @override
  void onAuthenticated(final Session session) {
    authenticated.value = true;
  }

  @override
  void onPasswordRecovery(final Session session) {}

  @override
  void onErrorAuthenticating(final String message) {
    authenticated.value = false;
    context.showErrorSnackBar(message: message);
  }
}
