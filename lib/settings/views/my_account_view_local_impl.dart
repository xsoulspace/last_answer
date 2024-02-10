import 'package:flutter/cupertino.dart';
import 'package:lastanswer/settings/views/supporter_view/supporter_view.dart';

class MyAccountViewLocalImpl extends StatelessWidget {
  const MyAccountViewLocalImpl({super.key});

  @override
  Widget build(final BuildContext context) => const SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: SupportAppView(),
      );
}
