// 4c — crash reporting rides the LOCAL lane (lib/crash/crash_reports.dart):
// privacy-first by the project's own law, zero new dependencies. The
// Firebase re-enable stays an owner decision (plan v5 4c named the
// choice; the native gradle plugins remain wired for that day).
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/crash/crash_reports.dart';
import 'package:lastanswer/other/other.dart';

Future<void> bootstrap() async {
  final GlobalServicesInitializer initializer = GlobalServicesInitializerImpl();
  WidgetsFlutterBinding.ensureInitialized();
  CrashReports.install();
  CrashReports.guard(() async {
    runApp(const LastAnswerApp());
  });
}
