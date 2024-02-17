import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class UiCircularProgress extends StatelessWidget {
  const UiCircularProgress({super.key});

  @override
  Widget build(final BuildContext context) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 24, maxWidth: 24),
          child: const CircularProgressIndicator.adaptive(),
        ),
      ).animate().fadeIn();
}
