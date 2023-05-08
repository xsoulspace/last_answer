// ignore_for_file: invalid_annotation_target

part of '../router.dart';

/// A route path that has been parsed by [TemplateRouteParser].
@immutable
@Freezed(
  fromJson: true,
  toJson: true,
  equal: true,
  addImplicitFinal: true,
  copyWith: true,
)
class ParsedRoute with _$ParsedRoute {
  @JsonSerializable(
    explicitToJson: true,
  )
  const factory ParsedRoute({
    /// The current path location without query parameters. (/book/123)
    required final String path,

    /// The path template (/book/:id)
    required final String pathTemplate,

    /// The path parameters ({id: 123})
    required final Map<String, String> parameters,

    /// The query parameters ({search: abc})
    required final Map<String, String> queryParameters,
  }) = _ParsedRoute;
  const ParsedRoute._();
  factory ParsedRoute.fromPathTemplate(final String template) => ParsedRoute(
        path: template,
        pathTemplate: template,
        parameters: const {},
        queryParameters: const {},
      );
}
