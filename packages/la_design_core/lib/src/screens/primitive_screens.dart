import 'package:flutter/material.dart';

class EmptyScreen extends StatelessWidget {
  const EmptyScreen({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [Text(r'At least it works ¯\_(ツ)_/¯')],
      ),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          CircularProgress(),
        ],
      ),
    );
  }
}

class CircularProgress extends StatelessWidget {
  const CircularProgress({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context) {
    return const CircularProgressIndicator.adaptive();
  }
}
