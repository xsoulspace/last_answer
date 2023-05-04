import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lastanswer/pack_auth/_hooks/auth_state.dart';
import 'package:lastanswer/pack_auth/_screens/email_sign_in_screen.dart';
import 'package:lastanswer/pack_auth/_screens/email_sign_up_screen.dart';
import 'package:life_hooks/life_hooks.dart';

GlobalSignInScreenState useGlobalSignInScreenState({
  required final AuthState authState,
}) =>
    use(
      ContextfulLifeHook(
        debugLabel: 'GlobalSignInScreenState',
        state: GlobalSignInScreenState(
          authState: authState,
        ),
      ),
    );

class GlobalSignInScreenState extends ContextfulLifeState {
  GlobalSignInScreenState({
    required this.authState,
  });
  final AuthState authState;
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  @override
  void dispose() {
    super.dispose();
    isLoading.dispose();
  }

  void onSignOut() {
    authState.signOut();
  }

  void onSignInByEmail() {
    showEmailSignInScreen(context: getContext());
  }

  void onSignUpByEmail() {
    showEmailSignUpScreen(context: getContext());
  }

  Future<void> signInWithDiscord() async {
    try {
      isLoading.value = true;
      await authState.signInWithDiscord();
    } finally {
      isLoading.value = false;
    }
  }
}
