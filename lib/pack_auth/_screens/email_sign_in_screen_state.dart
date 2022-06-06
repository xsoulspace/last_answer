part of pack_auth;

EmailSignInScreenState useEmailSignInScreenState({
  required final FormHelperState formHelper,
  required final AuthState authState,
}) =>
    use(
      ContextfulLifeHook(
        debugLabel: 'EmailSignInScreenState',
        state: EmailSignInScreenState(
          formHelper: formHelper,
          authState: authState,
        ),
      ),
    );

class EmailSignInScreenState extends ContextfulLifeState {
  EmailSignInScreenState({
    required this.formHelper,
    required this.authState,
  });
  final FormHelperState formHelper;
  final AuthState authState;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> onSingIn() async {
    await formHelper.submit(
      onValide: () async {
        final response = await authState.signInWithEmail(
          email: emailController.text,
          password: passwordController.text,
        );
        final error = response.error;
        if (!mounted) return;
        if (error == null) {
          Navigator.of(context, rootNavigator: true).pop();
        } else {
          await AlertHelper.onResponseError(error: error);
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }
}
