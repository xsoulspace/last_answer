import 'dart:async';

import 'package:flutter/material.dart';
import 'package:serverpod_auth_client/module.dart';
import 'package:serverpod_auth_google_flutter/serverpod_auth_google_flutter.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../../core.dart';
import '../providers/providers.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key});

  @override
  Widget build(final BuildContext context) => const _ServerpodImpl();
}

class _CustomImpl extends StatelessWidget {
  const _CustomImpl();

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
    final remoteClient = RemoteClient.ofContextAsServerpodImpl(context);
    return ServerpodSignInWithGoogleButton(
      // clientId: PlatformInfo.isWeb ? null : Envs.googleClientId,
      caller: remoteClient.client.modules.auth,
      serverClientId: Envs.googleServerClientId,
      redirectUri: Envs.serverRedirectUri,
      onFailure: () {
        print('onFailure');
      },
      onSignedIn: () {
        print('onSignedIn');
      },
    );
  }
}

// TODO(arenukvern): refactor after serverpod new version release
/// Quick copy paste from serverpod since they have new version
/// is coming.
/// Sign in with Google button. When pressed, attempts to sign in with Google.
class ServerpodSignInWithGoogleButton extends StatefulWidget {
  /// Creates a new Sign in with Google button.
  const ServerpodSignInWithGoogleButton({
    required this.caller,
    required this.redirectUri,
    super.key,
    this.clientId,
    this.serverClientId,
    this.onSignedIn,
    this.onFailure,
    this.debug = false,
    this.style,
    this.additionalScopes = const [],
    this.alignment = Alignment.centerLeft,
  });

  /// The Auth module's caller.
  final Caller caller;

  /// Google clientId, if not specified through a GoogleService-Info.plist file.
  final String? clientId;

  /// Your server's clientId, if not specified through a
  /// GoogleService-Info.plist file.
  final String? serverClientId;

  /// Called if sign in is successful.
  final VoidCallback? onSignedIn;

  /// Called if sign in is unsuccessful.
  final VoidCallback? onFailure;

  /// The style of the button.
  final ButtonStyle? style;

  /// Will output debug prints if set to true.
  final bool debug;

  /// Scopes to request when signing in. Default scopes are userinfo.profile
  /// and email, these should not be included in the [additionalScopes] list.
  final List<String> additionalScopes;

  /// Alignment of text and icon within the button.
  final Alignment alignment;

  /// Redirect Uri as setup in Google console.
  final Uri redirectUri;

  @override
  ServerpodSignInWithGoogleButtonState createState() =>
      ServerpodSignInWithGoogleButtonState();
}

/// State for Sign in with Google button.
class ServerpodSignInWithGoogleButtonState
    extends State<ServerpodSignInWithGoogleButton> {
  @override
  Widget build(final BuildContext context) => ElevatedButton.icon(
        style: widget.style ??
            ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.grey[700],
              alignment: widget.alignment,
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
        onPressed: () async {
          // Open a dialog with just the progress indicator that isn't
          // dismissable.
          final barrierNavigator = await _showLoadingBarrier(context: context);

          // Attempt to sign in the user.
          final userInfo = await signInWithGoogle(
            widget.caller,
            debug: widget.debug,
            clientId: widget.clientId,
            serverClientId: widget.serverClientId,
            additionalScopes: widget.additionalScopes,
            redirectUri: widget.redirectUri,
          );
          // Pop the loading barrier
          barrierNavigator.pop();

          // Notify the parent.
          if (userInfo != null) {
            widget.onSignedIn?.call();
          } else {
            widget.onFailure?.call();
          }
        },
        label: const Text('Sign in with Google'),
        icon: Image.asset(
          'assets/google-icon.png',
          package: 'serverpod_auth_google_flutter',
          width: 24,
          height: 24,
        ),
      );
}

/// Shows an non-dismissible barrier with a [CircularProgressIndicator]. Used
/// to show progress and block user input when signing in.
Future<NavigatorState> _showLoadingBarrier({
  required final BuildContext context,
}) {
  final completer = Completer<NavigatorState>();
  unawaited(
    showDialog(
      context: context,
      builder: (final context) {
        completer.complete(Navigator.of(context));
        return Container(
          child: const UiCircularProgress(),
        );
      },
      barrierDismissible: false,
    ),
  );
  return completer.future;
}
