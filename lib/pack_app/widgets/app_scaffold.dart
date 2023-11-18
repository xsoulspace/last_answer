import 'package:flutter/cupertino.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.navigator,
    super.key,
  });
  final Widget? navigator;
  @override
  Widget build(final BuildContext context) => navigator;
}
