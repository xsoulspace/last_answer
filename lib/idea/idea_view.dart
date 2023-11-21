import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/home/project_view.dart';

class IdeaView extends StatelessWidget {
  const IdeaView({
    required this.idea,
    super.key,
  });
  final ProjectModelIdea idea;
  @override
  Widget build(final BuildContext context) => const Column(
        children: [
          ProjectViewAppBar(),
          Placeholder(),
        ],
      );
}
