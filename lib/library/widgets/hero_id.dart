part of widgets;

enum HeroIdTypes {
  projectTitle,
  projectIdeaAnswerText,
  projectIdeaQuestionTitle,
}

class HeroId extends StatelessWidget {
  const HeroId({
    required final this.id,
    required final this.child,
    required final this.type,
    final this.flightShuttleBuilder,
    final this.placeholderBuilder,
    final Key? key,
  }) : super(key: key);
  final String id;
  final HeroIdTypes type;
  final Widget child;
  final HeroFlightShuttleBuilder? flightShuttleBuilder;
  final HeroPlaceholderBuilder? placeholderBuilder;
  @override
  Widget build(final BuildContext context) {
    return Hero(
      tag: '${type.toString()}$id',
      placeholderBuilder: placeholderBuilder,
      flightShuttleBuilder: flightShuttleBuilder,
      child: Material(
        color: Colors.transparent,
        child: child,
      ),
    );
  }
}
