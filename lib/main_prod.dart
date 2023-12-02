import 'package:lastanswer/bootstrap.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/firebase_options.dart';

Future<void> main() async =>
    bootstrap(firebaseOptions: DefaultFirebaseOptions.currentPlatform);
