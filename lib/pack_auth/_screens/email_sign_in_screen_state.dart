part of pack_auth;

EmailSignInScreenState useEmailSignInScreenState() => use(
      LifeHook(
        debugLabel: 'EmailSignInScreenState',
        state: EmailSignInScreenState(),
      ),
    );

class EmailSignInScreenState extends LifeState {
  EmailSignInScreenState();
}
