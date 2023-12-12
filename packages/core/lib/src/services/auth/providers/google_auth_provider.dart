import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_models/shared_models.dart';

import '../../../../core.dart';

class GoogleAuthProvider implements AuthProvider {
  @override
  Future<ProviderResponseModel> getCredentials() async {
    try {
      final googleSignIn = GoogleSignIn(
        serverClientId: Envs.googleServerClientId,
      );
      try {
        await googleSignIn.disconnect();
      } on PlatformException {
        // noop
      }

      final account = await googleSignIn.signIn();
      if (account == null) throw const CancelException();
      final serverAuthCode = account.serverAuthCode;

      return ProviderResponseModel(
        token: serverAuthCode!,
      );

      /// we expect [PlatformException] as user can just cancel sign in
    } on PlatformException catch (e) {
      debugPrint(e.toString());
      throw const CancelException();
    }
  }
}
