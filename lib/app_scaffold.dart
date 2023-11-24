import 'package:lastanswer/common_imports.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.navigator,
    super.key,
  });
  final Widget navigator;
  @override
  Widget build(final BuildContext context) => navigator;
}

class ScreenScaffold extends StatelessWidget {
  const ScreenScaffold({
    required this.navigator,
    super.key,
  });
  final Widget navigator;
  @override
  Widget build(final BuildContext context) => Scaffold(body: navigator);
}
