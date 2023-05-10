import 'package:life_hooks/life_hooks.dart';
import 'package:provider/provider.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../states/states.dart';

/// ********************************************
/// *      Widget
/// ********************************************
class AppDiInitializerLoader extends StatefulWidget {
  const AppDiInitializerLoader({
    required this.child,
    super.key,
  });
  final Widget child;

  @override
  State<AppDiInitializerLoader> createState() => _AppDiInitializerLoaderState();
}

class _AppDiInitializerLoaderState extends State<AppDiInitializerLoader> {
  bool _isInitialized = false;
  final _initalizer = AppDiInitializer();

  @override
  Widget build(final BuildContext context) => Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          children: [
            widget.child,
            if (!_isInitialized)
              FutureBuilder(
                // ignore: discarded_futures
                future: () async {
                  if (_isInitialized) return;
                  _isInitialized = true;
                  WidgetsBinding.instance
                      .addPostFrameCallback((final timeStamp) {
                    setState(() {});
                  });

                  return _initalizer.onLoad(context);
                }(),
                builder: (final context, final snapshot) =>
                    const LoadingScreen(),
              ),
          ],
        ),
      );
}

/// ********************************************
/// *      Initializer
/// ********************************************

class _AppDiInitializerDto {
  _AppDiInitializerDto.of(final Locator read) : authCubit = read();
  final AuthCubit authCubit;
}

class AppDiInitializer extends StateInitializer {
  /// If you need to wait until, then add await for
  /// required functions. But notice: every await
  /// function will increase app loading time because
  /// at the time the loader will be shown instead of the app.

  @override
  Future<void> onLoad(final BuildContext context) async {
    // FlutterNativeSplash.remove();

    final dto = _AppDiInitializerDto.of(context.read);
    await dto.authCubit.onLoad();
  }
}
