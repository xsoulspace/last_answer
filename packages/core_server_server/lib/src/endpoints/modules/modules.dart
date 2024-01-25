import 'dart:async';

import 'package:core_server_server/src/endpoints/modules/google_play_client.dart';
import 'package:core_server_server/src/future_calls/future_calls.dart';
import 'package:serverpod/serverpod.dart';

export 'google_play_client.dart';

class Modules {
  Modules({
    required this.googlePlayClient,
    required this.pod,
  });
  final GooglePlayClient googlePlayClient;
  final Serverpod pod;
  static Future<Modules> createModules({
    required final Serverpod pod,
  }) async {
    /// Creates the Google Play and Apple Store [PurchaseHandler]
    /// and their dependencies
    final googlePlayClient = await GooglePlayClient.load();
    return Modules(
      pod: pod,
      googlePlayClient: googlePlayClient,
    );
  }

  void onLoad() {
    final futureCalls = <ScheduledFutureCall>{
      // googlePlayHandlerFutureCall,
    };
    for (final futureCall in futureCalls) {
      pod.registerFutureCall(futureCall, futureCall.name);
      unawaited(futureCall.scheduleCall());
    }
  }
}
