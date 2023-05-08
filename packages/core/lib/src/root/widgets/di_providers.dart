import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';

class RootDiProviders extends StatelessWidget {
  const RootDiProviders({
    required this.providers,
    required this.builder,
    super.key,
  });
  final RootProvidersModel providers;
  final WidgetBuilder builder;

  @override
  Widget build(final BuildContext context) => MultiProvider(
        providers: const [],
        builder: (final context, final child) => builder(context),
      );
}

class BlocDiProviders extends StatelessWidget {
  const BlocDiProviders({
    required this.providers,
    required this.builder,
    super.key,
  });

  final BlocProvidersModel providers;
  final WidgetBuilder builder;

  @override
  Widget build(final BuildContext context) => MultiBlocProvider(
        providers: const [],
        child: Builder(builder: builder),
      );
}
