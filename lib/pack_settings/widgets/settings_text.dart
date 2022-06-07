import 'package:flutter/material.dart';

class SettingsText extends StatelessWidget {
  const SettingsText({
    required this.text,
    final Key? key,
  }) : super(key: key);
  final String text;
  @override
  Widget build(final BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyText2,
    );
  }
}
