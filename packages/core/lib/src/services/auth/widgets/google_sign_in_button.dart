import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:serverpod_auth_google_flutter/serverpod_auth_google_flutter.dart';

import '../../../../core.dart';
import '../providers/providers.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key});

  @override
  Widget build(final BuildContext context) => const _ServerpodImpl();
}

class _CustomImpl extends StatelessWidget {
  const _CustomImpl({super.key});

  @override
  Widget build(final BuildContext context) => TextButton(
        onPressed: () async {
          await GoogleAuthProvider().getCredentials();
        },
        child: const Text('Sign in'),
      );
}

class _ServerpodImpl extends StatelessWidget {
  const _ServerpodImpl();

  @override
  Widget build(final BuildContext context) {
    final remoteClient =
        context.read<RemoteClient>() as RemoteClientServerpodImpl;
    return SignInWithGoogleButton(
      // clientId: PlatformInfo.isWeb ? null : Envs.googleClientId,
      caller: remoteClient.client.modules.auth,
      serverClientId: Envs.googleServerClientId,
      redirectUri: Envs.serverRedirectUri,
      onFailure: context.pop,
      onSignedIn: context.pop,
    );
  }
}
