import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class UiCircularProgress extends StatelessWidget {
  const UiCircularProgress({super.key});

  @override
  Widget build(final BuildContext context) =>
      const Center(child: CircularProgressIndicator.adaptive())
          .animate()
          .fadeIn();
}
