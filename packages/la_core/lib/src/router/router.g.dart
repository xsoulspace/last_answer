// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_ParsedRoute _$$_ParsedRouteFromJson(final Map<String, dynamic> json) =>
    _$_ParsedRoute(
      path: json['path'] as String,
      pathTemplate: json['pathTemplate'] as String,
      parameters: Map<String, String>.from(json['parameters'] as Map),
      queryParameters: Map<String, String>.from(json['queryParameters'] as Map),
    );

Map<String, dynamic> _$$_ParsedRouteToJson(final _$_ParsedRoute instance) =>
    <String, dynamic>{
      'path': instance.path,
      'pathTemplate': instance.pathTemplate,
      'parameters': instance.parameters,
      'queryParameters': instance.queryParameters,
    };
