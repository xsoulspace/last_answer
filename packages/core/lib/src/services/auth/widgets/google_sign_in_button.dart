import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:serverpod_auth_google_flutter/serverpod_auth_google_flutter.dart';

import '../../../../core.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key});

  @override
  Widget build(final BuildContext context) => const _ServerpodImpl();
}

class _ServerpodImpl extends StatelessWidget {
  const _ServerpodImpl();

  @override
  Widget build(final BuildContext context) {
    final remoteClient =
        context.read<RemoteClient>() as RemoteClientServerpodImpl;
    return SignInWithGoogleButton(
      caller: remoteClient.client.modules.auth,
      serverClientId: Envs.googleServerClientId,
      redirectUri: Envs.serverRedirectUri,
    );
  }
}
