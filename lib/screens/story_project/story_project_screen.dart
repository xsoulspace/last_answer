part of story_project;

class StoryProjectScreen extends StatelessWidget {
  const StoryProjectScreen({
    required this.projectId,
    Key? key,
  }) : super(key: key);
  final ProjectId projectId;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(),
      );
}
