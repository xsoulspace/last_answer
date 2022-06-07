import 'package:flutter/material.dart';
import 'package:lastanswer/utils/routing/parsed_route.dart';
import 'package:path_to_regexp/path_to_regexp.dart';

/// Used by [TemplateRouteParser] to guard access to routes.
///
/// Override this class to change the route that is returned by
/// [TemplateRouteParser.parseRouteInformation] if a condition is not met, for
/// example, if the user is not signed in.
abstract class RouteGuard<T> {
  RouteGuard._();
  Future<T> redirect(final T from);
}

/// Parses the URI path into a [ParsedRoute].
class TemplateRouteParser extends RouteInformationParser<ParsedRoute> {
  TemplateRouteParser({
    /// The list of allowed path templates (['/', '/users/:id'])
    required final List<String> allowedPaths,

    /// The initial route
    final String? initialRoute = '/',

    ///  [RouteGuard] used to redirect.
    final this.guards,
  }) : initialRoute = ParsedRoute.fromPathTemplate(initialRoute ?? '/') {
    for (final template in allowedPaths) {
      _addRoute(template);
    }
  }
  final List<String> _pathTemplates = [];
  List<RouteGuard<ParsedRoute>>? guards;
  final ParsedRoute initialRoute;

  void _addRoute(final String pathTemplate) {
    _pathTemplates.add(pathTemplate);
  }

  @override
  Future<ParsedRoute> parseRouteInformation(
    final RouteInformation routeInformation,
  ) async =>
      _parse(routeInformation);

  Future<ParsedRoute> _parse(final RouteInformation routeInformation) async {
    final path = routeInformation.location!;
    final queryParams = Uri.parse(path).queryParameters;
    var parsedRoute = initialRoute;

    for (final pathTemplate in _pathTemplates) {
      final parameters = <String>[];
      final pathRegExp = pathToRegExp(pathTemplate, parameters: parameters);
      if (pathRegExp.hasMatch(path)) {
        final match = pathRegExp.matchAsPrefix(path);
        if (match == null) continue;
        final params = extract(parameters, match);
        parsedRoute = ParsedRoute(
          path: path,
          pathTemplate: pathTemplate,
          parameters: params,
          queryParameters: queryParams,
        );
      }
    }

    // Redirect if a guard is present
    final guards = this.guards ?? [];
    for (final guard in guards) {
      final maybeRouteToRedirect = await guard.redirect(parsedRoute);
      final isToRedirect = maybeRouteToRedirect != parsedRoute;
      if (isToRedirect) return maybeRouteToRedirect;
    }

    return parsedRoute;
  }

  @override
  RouteInformation restoreRouteInformation(final ParsedRoute configuration) =>
      RouteInformation(location: configuration.path);
}
