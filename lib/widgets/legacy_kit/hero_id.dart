/// Legacy-kit port of `_library/widgets/core/hero_id.dart`.
/// Widgets-layer only (the original's transparent `Material` flight wrapper
/// is dropped — `Hero` is widgets-layer and the child carries its own
/// styling); public API identical to the original.
library;

import 'package:core/core.dart';
import 'package:flutter/widgets.dart';

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
    if (PlatformInfo.isNativeWebDesktop) return child;

    return Hero(
      tag: '$type$id',
      placeholderBuilder: placeholderBuilder,
      flightShuttleBuilder: flightShuttleBuilder,
      child: child,
    );
  }
}
