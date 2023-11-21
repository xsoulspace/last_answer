import 'package:lastanswer/_library/widgets/widgets.dart';
import 'package:lastanswer/common_imports.dart';

class ProjectViewAppBar extends StatelessWidget {
  const ProjectViewAppBar({super.key});

  @override
  Widget build(final BuildContext context) {
    final screenLayout = ScreenLayout.of(context);
    return SafeArea(
      child: Row(
        children: [
          if (screenLayout.small)
            BackButton(onPressed: () => context.go(ScreenPaths.home)),
        ],
      ),
    );
  }
}
