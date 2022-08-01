import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_app/pack_app.dart';
import 'package:lastanswer/pack_auth/_hooks/auth_state.dart';
import 'package:lastanswer/pack_auth/_screens/magic_link_sign_in_screen_state.dart';
import 'package:life_hooks/life_hooks.dart';
import 'package:provider/provider.dart' as provider_lib;

Future<void> showMagicLinkSignInScreen({
  required final BuildContext context,
}) async {
  await showFrostedDialog(
    context: context,
    builder: (final context) => const FrostedDialog(
      content: FrostedDialogContent(
        title: 'Sign in',
        content: MagicLinkSignInScreen(),
        isCloseButtonVisible: false,
      ),
    ),
  );
}

class MagicLinkSignInScreen extends HookWidget {
  const MagicLinkSignInScreen({final Key? key}) : super(key: key);

  static const _contentPadding = EdgeInsets.symmetric(
    horizontal: 18,
    vertical: 14,
  );
  @override
  Widget build(final BuildContext context) {
    final authState = context.watch<AuthState>();
    final formHelper = useFormHelper();
    final state = useMagicLinkSignInScreenState(
      formHelper: formHelper,
      authState: authState,
    );
    final textTheme = Theme.of(context).textTheme;

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
                Text(
                  'Sign in via the magic link \nwith your email below',
                  textAlign: TextAlign.center,
                  style: textTheme.labelLarge,
                ),
                const SizedBox(height: 32),
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
                const SizedBox(height: 48),
                FractionallySizedBox(
                  widthFactor: 0.8,
                  child: ValueListenableBuilder<bool>(
                    valueListenable: formHelper.loading,
                    builder: (final context, final loading, final child) {
                      return OutlinedActionButton(
                        loading: loading,
                        onPressed: state.onSubmit,
                        text: 'Send Magic Link',
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
