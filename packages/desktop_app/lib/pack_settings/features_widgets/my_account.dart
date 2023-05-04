import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lastanswer/generated/l10n.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_auth/pack_auth.dart';
import 'package:lastanswer/pack_settings/abstract/general_settings_controller.dart';
import 'package:lastanswer/pack_settings/features_widgets/my_account_state.dart';
import 'package:lastanswer/pack_settings/widgets/settings_list_container.dart';
import 'package:lastanswer/pack_settings/widgets/settings_list_tile.dart';
import 'package:provider/provider.dart';

class MyAccount extends HookWidget {
  const MyAccount({
    required this.onSignIn,
    this.padding,
    super.key,
  });
  final EdgeInsets? padding;
  final VoidCallback onSignIn;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<GeneralSettingsController>();
    final authState = context.watch<AuthState>();
    final usersNotifier = context.watch<UsersNotifier>();
    final state = useMyAccountState(
      authState: authState,
    );

    return ValueListenableBuilder<bool>(
      valueListenable: authState.usersNotifier.authenticated,
      builder: (final context, final authenticated, final child) {
        if (!authenticated) {
          return const GlobalSignInScreen();
        }

        return SettingsListContainer(
          padding: padding,
          builder: (final context, final leftColumnWidth) => [
            const SizedBox(height: 24),
            SettingsListTile(
              title: S.current.email,
              leftColumnWidth: leftColumnWidth,
              child: Text(usersNotifier.currentUser.value.username),
            ),
            // TODO(arenukvern): add linked accounts
            const SizedBox(height: 24),
            Divider(
              color: theme.highlightColor,
              height: 24,
              endIndent: 10,
              indent: 10,
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: state.onSingOut,
              child: Text(S.current.signOut),
            ),
            const SizedBox(height: 24),
            DangerZone(
              onRemove: state.onDeleteAccount,
              removeText: S.current.deleteMyAccount,
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}
