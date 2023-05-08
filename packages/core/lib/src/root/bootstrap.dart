import 'dart:async';
import 'dart:developer';

import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import '../states/global/global_initializer.dart';
import 'widgets/widgets.dart';

/// ********************************************
/// *      APP RUNTIME
/// ********************************************

/// use this function in main like:
///
/// Future<void> main() => bootstrapMain(builder: AppScaffold.create);
/// where AppScaffold.create is
/// class AppScaffold extends ...Widget{
///   AppScaffold._();
///   static Widget create() => AppScaffold._();
/// }
Future<void> bootstrapMain({
  required final WidgetBuilder builder,
  final AppBootstrapDto? dto,
}) =>
    bootstrap(
      builder: DiProvidersBuilder.createFor(builder),
      dto: dto,
    );

/// ********************************************
/// *      MOCK APP RUNTIME
/// ********************************************

/// Use this function too bootstrap Mock App
Future<void> bootstrapMockMain({
  required final WidgetBuilder builder,
  final AppBootstrapDto? dto,
}) =>
    bootstrap(
      builder: MockDiProvidersBuilder.createFor(builder),
      dto: dto,
    );

/// ********************************************
/// *      BOOTSTRAP
/// ********************************************

class AppBootstrapDto {
  AppBootstrapDto({
    required this.firebaseOptions,
  });
  final FirebaseOptions? firebaseOptions;
}

Future<void> bootstrap({
  required final Widget Function(GlobalInitializer) builder,
  required final AppBootstrapDto? dto,
}) async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  final GlobalInitializer initializer = GlobalInitializerImpl(
    firebaseOptions: dto?.firebaseOptions,
  );
  await initializer.onLoad();

  Bloc.observer = _AppBlocObserver();

  runZonedGuarded(
    () => runApp(builder(initializer)),
    initializer.analyticsService.recordError,
  );
}

class _AppBlocObserver extends BlocObserver {
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
