part of utils;

/// A route path that has been parsed by [TemplateRouteParser].
@immutable
class ParsedRoute {
  const ParsedRoute({
    required this.path,
    required this.pathTemplate,
    required this.parameters,
    required this.queryParameters,
  });
  const ParsedRoute.fromPathTemplate(final String template)
      : path = template,
        pathTemplate = template,
        parameters = const {},
        queryParameters = const {};

  /// The current path location without query parameters. (/book/123)
  final String path;

  /// The path template (/book/:id)
  final String pathTemplate;

  /// The path parameters ({id: 123})
  final Map<String, String> parameters;

  /// The query parameters ({search: abc})
  final Map<String, String> queryParameters;

  static const _mapEquality = MapEquality<String, String>();
  ParsedRoute copyWith({
    final String? path,
    final String? pathTemplate,
    final Map<String, String>? parameters,
    final Map<String, String>? queryParameters,
  }) =>
      ParsedRoute(
        parameters: parameters ?? this.parameters,
        path: path ?? this.path,
        pathTemplate: pathTemplate ?? this.pathTemplate,
        queryParameters: queryParameters ?? this.queryParameters,
      );
  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(final Object other) =>
      other is ParsedRoute &&
      other.pathTemplate == pathTemplate &&
      other.path == path &&
      _mapEquality.equals(parameters, other.parameters) &&
      _mapEquality.equals(queryParameters, other.queryParameters);

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => hash4(
        path,
        pathTemplate,
        _mapEquality.hash(parameters),
        _mapEquality.hash(queryParameters),
      );

  @override
  String toString() => '<ParsedRoute '
      'template: $pathTemplate '
      'path: $path '
      'parameters: $parameters '
      'query parameters: $queryParameters>';
}
