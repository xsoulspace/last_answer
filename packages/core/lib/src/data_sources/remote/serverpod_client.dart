import 'package:core_server_client/core_server_client.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';

import '../interfaces/interfaces.dart';

class RemoteClientServerpodImpl implements RemoteClient {
  RemoteClientServerpodImpl({
    this.host = 'http://localhost:8080/',
  });
  final String host;
  // Sets up a singleton client object that can be used to talk to the server from
  // anywhere in our app. The client is generated from your server code.
  // The client is set up to connect to a Serverpod running on a local server on
  // the default port. You will need to modify this to connect to staging or
  // production servers.
  late final Client client = Client(host)
    ..connectivityMonitor = FlutterConnectivityMonitor();
  void onLoad() {}
}
