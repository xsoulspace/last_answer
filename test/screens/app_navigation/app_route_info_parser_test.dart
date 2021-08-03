import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/screens/app_navigator/app_navigator.dart';

void main() {
  final routes = {
    '/${AppRoutesName.idea}/1': AppRouteConfig.idea(id: '1'),
    '/${AppRoutesName.createIdea}': AppRouteConfig.createIdea(),
    '/${AppRoutesName.note}/1': AppRouteConfig.note(id: '1'),
    '/${AppRoutesName.story}/1': AppRouteConfig.story(id: '1'),
    '/${AppRoutesName.settings}': AppRouteConfig.settings(),
    AppRoutesName.home: AppRouteConfig.home(),
    '/${AppRoutesName.unknown404}': AppRouteConfig.unknown(),
  };
  group('[app route info parser]', () {
    test('parseRouteInformation can parse all routes', () async {
      final parser = AppRouteInformationParser();
      for (final routeEntry in routes.entries) {
        final routeInformation = RouteInformation(location: routeEntry.key);
        final config = await parser.parseRouteInformation(routeInformation);
        expect(config, equals(routeEntry.value));
      }
    });
    test('restoreRouteInformation can restore all routes', () async {
      final parser = AppRouteInformationParser();
      for (final routeEntry in routes.entries) {
        final routeInformation =
            parser.restoreRouteInformation(routeEntry.value);
        expect(routeInformation?.location, equals(routeEntry.key));
      }
    });
  });
}
