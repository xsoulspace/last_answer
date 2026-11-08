import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/crash/crash_reports.dart';
import 'package:universal_io/io.dart';

/// 4c — the local crash lane's laws: capture never throws, the store
/// is bounded (newest survive, oldest pruned), reports round-trip
/// their durable facts, and the human can erase everything.
void main() {
  late Directory temp;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('la_crash_');
    CrashReports.debugDirectoryOverride = () async => temp;
  });

  tearDown(() async {
    CrashReports.debugDirectoryOverride = null;
    if (temp.existsSync()) await temp.delete(recursive: true);
  });

  test('capture stores a parseable report with the durable facts', () async {
    await CrashReports.capture(
      StateError('the thing broke'),
      StackTrace.fromString('frame-one\nframe-two'),
    );
    final reports = await CrashReports.list();
    expect(reports, hasLength(1));
    expect(reports.single.error, contains('the thing broke'));
    expect(reports.single.stack, contains('frame-one'));
    expect(reports.single.platform, isNotEmpty);
    expect(DateTime.tryParse(reports.single.at), isNotNull);
  });

  test(
    'the store is bounded: the newest survive, the oldest are pruned',
    () async {
      for (var i = 0; i < CrashReports.maxReports + 5; i++) {
        await CrashReports.capture(StateError('crash $i'), StackTrace.current);
        // Distinct filenames ride the micros clock + identity hash; a
        // same-micros collision would silently overwrite — acceptable in
        // production, sequenced here by the await boundary.
      }
      final reports = await CrashReports.list();
      expect(reports.length, lessThanOrEqualTo(CrashReports.maxReports));
      expect(
        reports.first.error,
        contains('crash ${CrashReports.maxReports + 4}'),
      );
    },
  );

  test('the stack is capped — a report is a diagnostic, not a dump', () async {
    final huge = 'x' * (CrashReports.maxStackChars * 2);
    await CrashReports.capture(StateError('big'), StackTrace.fromString(huge));
    final reports = await CrashReports.list();
    expect(
      reports.single.stack.length,
      lessThanOrEqualTo(CrashReports.maxStackChars),
    );
  });

  test('clear empties the store (the right to erase diagnostics)', () async {
    await CrashReports.capture(StateError('gone soon'), StackTrace.current);
    expect(await CrashReports.list(), hasLength(1));
    await CrashReports.clear();
    expect(await CrashReports.list(), isEmpty);
  });

  test('a broken store reads empty and capture never throws', () async {
    CrashReports.debugDirectoryOverride = () async =>
        throw const FileSystemException('no home');
    // The capture law: a failing capture is a lost report, never a
    // second crash.
    await CrashReports.capture(StateError('x'), StackTrace.current);
    expect(await CrashReports.list(), isEmpty);
  });
}
