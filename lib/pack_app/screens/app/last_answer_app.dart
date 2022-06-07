import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lastanswer/pack_app/screens/app/app_scaffold.dart';
import 'package:lastanswer/pack_app/screens/app/app_state_provider.dart';

class LastAnswerApp extends StatelessWidget {
  const LastAnswerApp({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context) {
    return AppStateProvider(
      builder: (final _) => const AppScaffold(),
    );
  }
}
