part of pack_story;

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
