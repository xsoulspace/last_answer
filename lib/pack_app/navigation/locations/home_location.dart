import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

class HomeLocation extends BeamLocation {
  HomeLocation(super.routeInformation);
  factory HomeLocation.builder(
    final RouteInformation routeInformation,
    final BeamParameters? _,
  ) =>
      HomeLocation(routeInformation);

  @override
  List<BeamPage> buildPages(
    final BuildContext context,
    final RouteInformationSerializable state,
  ) =>
      [
        BeamPage(
          key: ValueKey('home-${DateTime.now()}'),
          child: HomeScreen(),
        )
      ];

  @override
  List<Pattern> get pathPatterns => ['/*'];
}
