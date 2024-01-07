import 'dart:async';

import 'package:core_server_server/src/endpoints/modules/google_play_client.dart';
import 'package:core_server_server/src/endpoints/repositories/purchases/purchases.dart';
import 'package:core_server_server/src/future_calls/future_calls.dart';
import 'package:serverpod/serverpod.dart';

export 'google_play_client.dart';

class Modules {
  Modules({
    required this.googlePlayClient,
    required this.googlePlayHandlerFutureCall,
  });
  final GooglePlayClient googlePlayClient;
  final GooglePlayHandlerFutureCall googlePlayHandlerFutureCall;

  static Future<Modules> createModules() async {
    /// Creates the Google Play and Apple Store [PurchaseHandler]
    /// and their dependencies
    final iapRepository = IapRepository();
    final googlePlayClient = await GooglePlayClient.load();
    return Modules(
      googlePlayClient: googlePlayClient,
      googlePlayHandlerFutureCall: GooglePlayHandlerFutureCall(
        googlePlayClient: googlePlayClient,
        iapRepository: iapRepository,
      ),
    );
  }

  void onLoad() {
    final futureCalls = <ScheduledFutureCall>{
      googlePlayHandlerFutureCall,
    };
    for (final futureCall in futureCalls) {
      Serverpod.instance!.registerFutureCall(futureCall, futureCall.name);
      unawaited(futureCall.scheduleCall());
    }
  }
}
