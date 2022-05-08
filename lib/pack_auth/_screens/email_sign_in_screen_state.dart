part of pack_auth;

EmailSignInScreenState useEmailSignInScreenState() => use(
      LifeHook(
        debugLabel: 'EmailSignInScreenState',
        state: EmailSignInScreenState(),
      ),
    );

class EmailSignInScreenState extends LifeState {
  EmailSignInScreenState();

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
