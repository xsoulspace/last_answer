import 'dart:async';
import 'dart:developer';

import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../states/global/global_initializer.dart';

class AppBlocObserver extends BlocObserver {
  @override
  // ignore: unnecessary_overrides
  void onChange(final BlocBase bloc, final Change change) {
    super.onChange(bloc, change);
    // log('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(
    final BlocBase bloc,
    final Object error,
    final StackTrace stackTrace,
  ) {
    log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}

Future<void> bootstrap(
  final Widget Function(FirebaseOptions? firebaseOptions) builder,
) async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  final GlobalInitializer initializer = GlobalInitializerImpl();
  await initializer.onLoad();

  Bloc.observer = AppBlocObserver();

  runZonedGuarded(
    () => runApp(builder()),
    initializer.analyticsService.recordError,
  );
}
