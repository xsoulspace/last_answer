import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_auth/_hooks/auth_state.dart';
import 'package:life_hooks/life_hooks.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

EmailSignUpScreenState useSignUpScreenState({
  required final FormHelperState formHelper,
  required final AuthState authState,
}) =>
    use(
      ContextfulLifeHook(
        debugLabel: 'SignUpScreenState',
        state: EmailSignUpScreenState(
          formHelper: formHelper,
          authState: authState,
        ),
      ),
    );

enum EmailSignUpStatus {
  signUp,
  waitingConfirmation,
}

class EmailSignUpScreenState extends ContextfulLifeState {
  EmailSignUpScreenState({
    required this.formHelper,
    required this.authState,
  });
  final FormHelperState formHelper;
  final AuthState authState;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmationController = TextEditingController();
  final statusController =
      PageController(initialPage: EmailSignUpStatus.signUp.index);

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordConfirmationController.dispose();
    passwordController.dispose();
    statusController.dispose();
  }

  Future<void> onSignUp() async {
    await formHelper.submit(
      onValide: () async {
        final response = await authState.signUpWithEmail(
          email: emailController.text,
          password: passwordController.text,
        );
        await _onResponse(response);
      },
    );
  }

  Future<void> _onResponse(
    final GotrueSessionResponse response,
  ) async {
    final error = response.error;

    if (!mounted) return;
    if (error == null) {
      if (statusController.page ==
          EmailSignUpStatus.waitingConfirmation.index) {
        Navigator.of(context, rootNavigator: true).pop();
        authState.onAuthenticated(response.data!);
      } else {
        await statusController.animateToPage(
          EmailSignUpStatus.waitingConfirmation.index,
          duration: const Duration(milliseconds: 250),
          curve: Curves.fastOutSlowIn,
        );
      }
    } else {
      await AlertHelper.onResponseError(error: error);
    }
  }

  Future<void> onTryToSignIn() async {
    await formHelper.submit(
      onValide: () async {
        final response = await authState.signInWithEmail(
          email: emailController.text,
          password: passwordController.text,
        );
        await _onResponse(response);
      },
    );
  }
}
