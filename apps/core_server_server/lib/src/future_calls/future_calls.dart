import 'package:serverpod/serverpod.dart';

export 'google_play_handler_future_call.dart';

abstract base class ScheduledFutureCall extends FutureCall {
  Future<void> scheduleCall() => Serverpod.instance!
      .futureCallWithDelay(name, null, scheduleDelayDuration);
  Duration get scheduleDelayDuration => const Duration(seconds: 10);
}
