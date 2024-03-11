import 'package:firebase_core/firebase_core.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/other/other.dart';

Future<void> bootstrap({
  required final FirebaseOptions? firebaseOptions,
}) async {
  final GlobalServicesInitializer initializer = GlobalServicesInitializerImpl(
    firebaseOptions: firebaseOptions,
  );
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      unawaited(initializer.onLoad());
      runApp(const LastAnswerApp());
    },
    initializer.analyticsService.recordError,
  );
}
