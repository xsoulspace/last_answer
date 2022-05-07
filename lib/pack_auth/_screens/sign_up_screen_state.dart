part of pack_auth;

SignUpScreenState useSignUpScreenState() => use(
      LifeHook(
        debugLabel: 'SignUpScreenState',
        state: SignUpScreenState(),
      ),
    );

class SignUpScreenState extends LifeState {
  SignUpScreenState();

  @override
  void initState() {
    // TODO: implement initState
  }

  @override
  void dispose() {
    // TODO: implement dispose
  }
}
