import 'package:flutter/material.dart';

typedef LoadableWidgetBuilder = Widget Function(
  BuildContext context,
  ValueSetter<bool> setLoading,
  // ignore: avoid_positional_boolean_parameters
  bool isLoading,
);

class LoadableWidget extends StatefulWidget {
  const LoadableWidget({
    required this.builder,
    super.key,
  });
  final LoadableWidgetBuilder builder;

  @override
  State<LoadableWidget> createState() => _LoadableWidgetState();
}

class _LoadableWidgetState extends State<LoadableWidget> {
  bool _isLoading = false;

  @override
  Widget build(final BuildContext context) => widget.builder(
        context,
        (final value) {
          if (mounted) setState(() => _isLoading = value);
        },
        _isLoading,
      );
}
