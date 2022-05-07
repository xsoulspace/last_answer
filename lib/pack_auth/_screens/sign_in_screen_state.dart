part of pack_auth;

SignInScreenState useSignInScreenState() => use(
      LifeHook(
        debugLabel: 'SignInScreenState',
        state: SignInScreenState(),
      ),
    );

class SignInScreenState extends LifeState {
  SignInScreenState();
  late AuthState authState;
  @override
  void registerHooks(final BuildContext context) {
    authState = useAuthState();
    super.registerHooks(context);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
