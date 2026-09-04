import 'package:flutter_test/flutter_test.dart';

/// Drives the embedded-harness loop inside a widget test. The loop
/// interleaves two worlds: in-memory ACP stream deliveries are scheduled
/// in the test's fake-async zone (flushed by [WidgetTester.pump]), while
/// real file/process IO (snapshot store, the workspace oracle's
/// `dart run`) only completes inside [WidgetTester.runAsync]. Alternating
/// both until a condition holds drives a full scripted session
/// deterministically, in real milliseconds.
Future<void> pumpUntil(
  final Future<void> Function(Future<void> Function()) runAsync,
  final bool Function() condition, {
  final int maxCycles = 600,
}) async {
  for (var i = 0; i < maxCycles && !condition(); i++) {
    await runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
  }
}
