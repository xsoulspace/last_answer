import 'package:core_server_client/core_server_client.dart';
import 'package:serverpod_auth_shared_flutter/serverpod_auth_shared_flutter.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';

import '../interfaces/interfaces.dart';

class RemoteClientServerpodImpl implements RemoteClient {
  RemoteClientServerpodImpl({
    required this.host,
  });
  final String host;
  // Sets up a singleton client object that can be used to talk to the server
  // from anywhere in our app. The client is generated from your server code.
  // The client is set up to connect to a Serverpod running on a local server on
  // the default port. You will need to modify this to connect to staging or
  // production servers.
  late final Client client = Client(
    host,
    authenticationKeyManager: FlutterAuthenticationKeyManager(),
  )..connectivityMonitor = FlutterConnectivityMonitor();
  // The session manager keeps track of the signed-in state of the user. You
  // can query it to see if the user is currently signed in and get information
  // about the user.
  late final SessionManager sessionManager = SessionManager(
    caller: client.modules.auth,
  );

  @override
  Future<void> onLoad() async {
    await sessionManager.initialize();
  }
}
