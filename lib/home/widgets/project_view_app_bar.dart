import 'package:lastanswer/_library/widgets/widgets.dart';
import 'package:lastanswer/common_imports.dart';

class ProjectViewAppBar extends StatelessWidget {
  const ProjectViewAppBar({super.key});

  @override
  Widget build(final BuildContext context) => BackTextUniversalAppBar(
        onBack: () => context.go(ScreenPaths.home),
        titleStr: '',
        useBackButton: true,
      );
}
