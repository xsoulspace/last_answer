import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:life_hooks/life_hooks.dart';
import 'package:provider/provider.dart';
import 'package:ui_kit/ui_kit.dart';

class AppDiLoaderDto {
  AppDiLoaderDto.of(final Locator read)
      : authFlowBloc = read(),
        dictionariesBloc = read(),
        appSettingsBloc = read();
  final AuthFlowBloc authFlowBloc;
  final DictionariesBloc dictionariesBloc;
  final AppSettingsBloc appSettingsBloc;
}

class AppDiLoader extends StatefulWidget {
  const AppDiLoader({
    required this.child,
    super.key,
  });
  final Widget child;

  @override
  State<AppDiLoader> createState() => _AppDiLoaderState();
}

class _AppDiLoaderState extends State<AppDiLoader> {
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
                    // ignore: no-empty-block
                    setState(() {});
                  });

                  return _initalizer.onLoad(context);
                }(),
                builder: (final context, final snapshot) {
                  return const LoaderScreen();
                },
              ),
          ],
        ),
      );
}

class AppDiInitializer extends StateInitializer {
  /// If you need to wait until, then add await for
  /// required functions. But notice: every await
  /// function will increase app loading time because
  /// at the time the loader will be shown instead of the app.

  @override
  Future<void> onLoad(final BuildContext context) async {
    final dto = AppDiLoaderDto.of(context.read);
    await dto.authFlowBloc.onLoad();
    dto.dictionariesBloc.add(const DictionariesBlocEvent.load());
    dto.appSettingsBloc.add(const AppSettingsBlocEvent.load());
  }
}
