import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_app/pack_app.dart';
import 'package:lastanswer/pack_auth/_hooks/auth_state.dart';
import 'package:lastanswer/pack_auth/_screens/email_sign_in_screen_state.dart';
import 'package:life_hooks/life_hooks.dart';
import 'package:provider/provider.dart' as provider_lib;

Future<void> showEmailSignInScreen({
  required final BuildContext context,
}) async {
  await showFrostedDialog(
    context: context,
    builder: (final context) => const FrostedDialog(
      content: FrostedDialogContent(
        title: 'Sign In',
        content: EmailSignInScreen(),
        isCloseButtonVisible: false,
      ),
    ),
  );
}

class EmailSignInScreen extends HookWidget {
  const EmailSignInScreen({final Key? key}) : super(key: key);

  static const _contentPadding = EdgeInsets.symmetric(
    horizontal: 18,
    vertical: 14,
  );
  @override
  Widget build(final BuildContext context) {
    final authState = context.watch<AuthState>();
    final formHelper = useFormHelper();
    final state = useEmailSignInScreenState(
      formHelper: formHelper,
      authState: authState,
    );

    return Form(
      key: formHelper.formKey,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 350,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                FlatTextField(
                  labelText: 'E-mail',
                  controller: state.emailController,
                  onSubmit: () {},
                  filled: false,
                  contentPadding: _contentPadding,
                  maxLines: 1,
                  hintText: 'email@email.com',
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.email(),
                  ]),
                ),
                const SizedBox(height: 36),
                FlatTextField(
                  focusOnInit: false,
                  controller: state.passwordController,
                  onSubmit: () {},
                  filled: false,
                  maxLines: 1,
                  contentPadding: _contentPadding,
                  labelText: 'Password',
                  obscureText: true,
                  countCharacters: true,
                  hintText: '',
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.minLength(8),
                  ]),
                ),
                const SizedBox(height: 48),
                FractionallySizedBox(
                  widthFactor: 0.8,
                  child: ValueListenableBuilder<bool>(
                    valueListenable: formHelper.loading,
                    builder: (final context, final loading, final child) {
                      return OutlinedActionButton(
                        loading: loading,
                        onPressed: state.onSingIn,
                        text: 'Sign In',
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
