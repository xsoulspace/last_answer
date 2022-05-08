part of pack_auth;

EmailSignUpScreenState useSignUpScreenState() => use(
      LifeHook(
        debugLabel: 'SignUpScreenState',
        state: EmailSignUpScreenState(),
      ),
    );

class EmailSignUpScreenState extends LifeState {
  EmailSignUpScreenState();

  @override
  void initState() {
    // TODO: implement initState
  }

  @override
  void dispose() {
    // TODO: implement dispose
  }
}
