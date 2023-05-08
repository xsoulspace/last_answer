import 'package:flutter/material.dart';

class EmptyScreen extends StatelessWidget {
  const EmptyScreen({
    this.isEmpty = false,
    super.key,
  });
  final bool isEmpty;
  @override
  Widget build(final BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isEmpty) const Text(r'At least it works ¯\_(ツ)_/¯'),
          ],
        ),
      );
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(final BuildContext context) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgress(),
          ],
        ),
      );
}

class CircularProgress extends StatelessWidget {
  const CircularProgress({super.key});

  @override
  Widget build(final BuildContext context) =>
      const CircularProgressIndicator.adaptive();
}
