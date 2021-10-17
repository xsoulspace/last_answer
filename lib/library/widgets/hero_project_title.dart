part of widgets;

class HeroProjectTitle extends StatelessWidget {
  const HeroProjectTitle({
    required final this.project,
    required final this.child,
    final Key? key,
  }) : super(key: key);
  final BasicProject project;
  final Widget child;
  @override
  Widget build(final BuildContext context) {
    return Hero(
      tag: 'project-title-${project.id}',
      child: Material(child: child),
    );
  }
}
