import 'package:flutter/widgets.dart';

import '../../states/states.dart';
import '../models/models.dart';
import 'widgets.dart';

class DiProvidersBuilder extends StatefulWidget {
  const DiProvidersBuilder._({
    required this.globalInitializer,
    required this.builder,
  });
  static Widget Function(GlobalInitializer) createFor(
    final WidgetBuilder builder,
  ) =>
      (final globalInitializer) => DiProvidersBuilder._(
            globalInitializer: globalInitializer,
            builder: builder,
          );

  final GlobalInitializer globalInitializer;
  final WidgetBuilder builder;

  @override
  State<DiProvidersBuilder> createState() => _DiProvidersBuilderState();
}

class _DiProvidersBuilderState extends State<DiProvidersBuilder> {
  @override
  void dispose() {
    widget.globalInitializer.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => RootDiProviders(
        providers: RootProvidersModel.appRuntime(
          globalInitializer: widget.globalInitializer,
        ),
        builder: (final context) => BlocDiProviders(
          providers: BlocProvidersModel.appRuntime(),
          builder: widget.builder,
        ),
      );
}

class MockDiProvidersBuilder extends StatefulWidget {
  const MockDiProvidersBuilder._({
    required this.globalInitializer,
    required this.builder,
  });
  static Widget Function(GlobalInitializer) createFor(
    final WidgetBuilder builder,
  ) =>
      (final globalInitializer) => MockDiProvidersBuilder._(
            globalInitializer: globalInitializer,
            builder: builder,
          );

  final GlobalInitializer globalInitializer;
  final WidgetBuilder builder;

  @override
  State<MockDiProvidersBuilder> createState() => _MockDiProvidersBuilderState();
}

class _MockDiProvidersBuilderState extends State<MockDiProvidersBuilder> {
  @override
  void dispose() {
    widget.globalInitializer.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => RootDiProviders(
        providers: RootProvidersModel.mock(
          globalInitializer: widget.globalInitializer,
        ),
        builder: (final context) => BlocDiProviders(
          providers: BlocProvidersModel.mock(),
          builder: widget.builder,
        ),
      );
}
