import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lastanswer/library/hooks/hooks.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_auth/_hooks/auth_state.dart';
import 'package:life_hooks/life_hooks.dart';

MagicLinkSignInScreenState useMagicLinkSignInScreenState({
  required final FormHelperState formHelper,
  required final AuthState authState,
}) =>
    use(
      ContextfulLifeHook(
        debugLabel: 'MagicLinkSignInScreenState',
        state: MagicLinkSignInScreenState(
          formHelper: formHelper,
          authState: authState,
        ),
      ),
    );

class MagicLinkSignInScreenState extends ContextfulLifeState {
  MagicLinkSignInScreenState({
    required this.formHelper,
    required this.authState,
  });
  final FormHelperState formHelper;
  final AuthState authState;
  final emailController = TextEditingController();

  Future<void> onSubmit() async {
    await formHelper.submit(
      onValide: () async {
        final response = await authState.signInWithMagicLink(
          email: emailController.text,
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
  }
}
