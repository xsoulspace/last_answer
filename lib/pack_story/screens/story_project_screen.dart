import 'package:flutter/material.dart';
import 'package:lastanswer/pack_core/pack_core.dart';

class StoryProjectScreen extends StatelessWidget {
  const StoryProjectScreen({
    required final this.projectId,
    final Key? key,
  }) : super(key: key);
  final ProjectId projectId;

  @override
  Widget build(final BuildContext context) => Scaffold(
        appBar: AppBar(),
      );
}
