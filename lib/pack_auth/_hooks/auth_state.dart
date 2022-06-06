part of pack_auth;

AuthState useAppAuthState({
  required final SupabaseClient supabaseClient,
  required final UsersNotifier usersNotifier,
}) =>
    use(
      LifeHook(
        debugLabel: 'AuthState',
        state: AuthState(
          supabaseClient: supabaseClient,
          usersNotifier: usersNotifier,
        ),
      ),
    );

class AuthState extends SupabaseAuthLifeState {
  AuthState({
    required this.supabaseClient,
    required this.usersNotifier,
  });
  final SupabaseClient supabaseClient;
  final UsersNotifier usersNotifier;
  GoTrueClient get supabaseAuth => supabaseClient.auth;
  bool get discordSignInAvailable =>
      kIsWeb || Platform.isAndroid || Platform.isIOS;
  bool get magicLinkSignInAvailable => discordSignInAvailable;

  /// iOS, Android and web only
  Future<GotrueSessionResponse> signInWithMagicLink({
    required final String email,
  }) async {
    return supabaseAuth.signIn(
      email: email,
      options: _getAuthOptions(),
    );
  }

  /// Supports all platforms
  Future<GotrueSessionResponse> signInWithEmail({
    required final String email,
    required final String password,
  }) async {
    return supabaseClient.auth.signIn(
      email: email,
      password: password,
    );
  }

  /// Supports all platforms
  Future<GotrueSessionResponse> signUpWithEmail({
    required final String email,
    required final String password,
  }) async {
    return supabaseAuth.signUp(
      email,
      password,
    );
  }

  Future<void> signInWithDiscord() async {
    return _signInWithProvider(provider: Provider.discord);
  }

  AuthOptions _getAuthOptions() {
    String? redirectTo;

    if (kIsWeb) {
    } else {
      redirectTo = 'dev.xsoulspace.lastanswer://login-callback/';
    }

    return AuthOptions(
      redirectTo: redirectTo,
    );
  }

  Future<void> _signInWithProvider({required final Provider provider}) async {
    final GotrueSessionResponse res = await supabaseAuth.signIn(
      provider: provider,
      options: _getAuthOptions(),
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

  Future<void> deleteUser() async {
    /// see more: https://github.com/supabase/supabase/discussions/1066
    final response = await supabaseClient.rpc('delete_user').execute();
    if (response.status == 200 || response.status == 204) {
      try {
        await signOut();
        // ignore: empty_catches, avoid_catches_without_on_clauses
      } catch (e) {}
      onUnauthenticated();
    }
  }

  Future<GotrueResponse> signOut() async {
    return supabaseAuth.signOut();
  }

  @override
  void onUnauthenticated() {
    usersNotifier.authenticated.value = false;
  }

  @override
  void onAuthenticated(final Session session) {
    usersNotifier.authenticated.value = true;
  }

  @override
  void onPasswordRecovery(final Session session) {}

  @override
  void onErrorAuthenticating(final String message) {
    usersNotifier.authenticated.value = false;
  }
}
