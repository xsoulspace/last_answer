part of widgets;

enum HeroIdTypes {
  projectTitle,
  projectIdeaAnswerText,
  projectIdeaQuestionTitle,
}

class HeroId extends StatelessWidget {
  const HeroId({
    required this.id,
    required this.child,
    required this.type,
    this.flightShuttleBuilder,
    this.placeholderBuilder,
    super.key,
  });
  final String id;
  final HeroIdTypes type;
  final Widget child;
  final HeroFlightShuttleBuilder? flightShuttleBuilder;
  final HeroPlaceholderBuilder? placeholderBuilder;
  @override
  Widget build(final BuildContext context) {
    if (isDesktop) return child;

    return Hero(
      tag: '$type$id',
      placeholderBuilder: placeholderBuilder,
      flightShuttleBuilder: flightShuttleBuilder,
      child: Material(
        color: Colors.transparent,
        child: child,
      ),
    );
  }
}
