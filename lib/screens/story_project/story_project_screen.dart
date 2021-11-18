part of story_project;

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
