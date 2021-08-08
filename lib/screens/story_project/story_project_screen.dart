part of story_project;

class StoryProjectScreen extends StatelessWidget {
  const StoryProjectScreen({
    required this.project,
    Key? key,
  }) : super(key: key);
  final StoryProject project;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(),
      );
}
