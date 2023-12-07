import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core.dart';

class GoogleAuthProvider implements AuthProvider {
  final _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
    serverClientId: Envs.googleServerClientId,
  );

  @override
  Future<ProviderResponseModel> getCredentials() async {
    try {
      try {
        await _googleSignIn.disconnect();
      } on PlatformException {
        // noop
      }
      final account = await _googleSignIn.signIn();
      if (account == null) throw const CancelException();
      final serverAuthCode = account.serverAuthCode;

      return ProviderResponseModel(
        token: serverAuthCode!,
      );

      /// we expect [PlatformException] as user can just cancel sign in
    } on PlatformException {
      throw const CancelException();
    }
  }
}
