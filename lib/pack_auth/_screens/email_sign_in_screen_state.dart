import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:la_core/la_core.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_auth/_hooks/auth_state.dart';
import 'package:life_hooks/life_hooks.dart';

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
