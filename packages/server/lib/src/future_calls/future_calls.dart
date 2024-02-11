import 'package:serverpod/serverpod.dart';

export 'google_play_handler_future_call.dart';

abstract base class ScheduledFutureCall extends FutureCall {
  ScheduledFutureCall({
    required this.serverpod,
  });
  final Serverpod serverpod;
  Future<void> scheduleCall() =>
      serverpod.futureCallWithDelay(name, null, scheduleDelayDuration);
  Duration get scheduleDelayDuration => const Duration(seconds: 10);
}
