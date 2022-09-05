import 'package:flutter/material.dart';
import 'package:lastanswer/pack_core/abstract/server_models/server_models.dart';

class StoryProjectScreen extends StatelessWidget {
  const StoryProjectScreen({
    required this.projectId,
    final Key? key,
  }) : super(key: key);
  final ProjectId projectId;

  @override
  Widget build(final BuildContext context) => Scaffold(
        appBar: AppBar(),
      );
}
