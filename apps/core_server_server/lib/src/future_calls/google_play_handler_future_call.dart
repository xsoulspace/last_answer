import 'dart:async';

import 'package:core_server_server/src/endpoints/modules/modules.dart';
import 'package:core_server_server/src/future_calls/future_calls.dart';
import 'package:serverpod/serverpod.dart';

// Future calls are calls that will be invoked at a later time. An example is if
// you want to send a drip-email campaign after a user signs up. You can
// schedule a future call for a day, a week, or a month. The calls are stored in
// the database, so they will persist even if the server is restarted.
//
//  To add a future call to your server, you need to register it in the
//  `server.dart` file. Schedule the call using the
//  `session.serverpod.futureCallWithDelay` or
//  `session.serverpod.futureCallAtTime`
//  methods. You can optionally pass a serializable object together with the
//  call.
final class GooglePlayHandlerFutureCall extends ScheduledFutureCall {
  GooglePlayHandlerFutureCall({
    required final GooglePlayClient googlePlayClient,
    // required final IapRepository iapRepository,
    required super.serverpod,
  });
  //  :googlePlayHandler = GooglePlayPurchaseHandler(
  //         androidPublisher: googlePlayClient.androidPublisher,
  //         pubsubApi: googlePlayClient.pubsubApi,
  //         iapRepository: iapRepository,
  //       );
  @override
  String get name => 'GooglePlayHandlerFutureCall';

  // final GooglePlayPurchaseHandler googlePlayHandler;
  @override
  Future<void> invoke(
    final Session session,
    final SerializableEntity? object,
  ) async {
    // await googlePlayHandler.pullMessageFromPubSub(session: session);
    unawaited(scheduleCall());
  }
}
