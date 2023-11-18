import 'package:go_router/go_router.dart';
import 'package:lastanswer/pack_app/widgets/widgets.dart';

final _routes = [
  ShellRoute(
    builder: (final context, final state, final navigator) => AppScaffold(
      navigator: navigator,
    ),
    routes: const [],
  ),
];
