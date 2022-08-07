// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'router.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

ParsedRoute _$ParsedRouteFromJson(Map<String, dynamic> json) {
  return _ParsedRoute.fromJson(json);
}

/// @nodoc
mixin _$ParsedRoute {
  /// The current path location without query parameters. (/book/123)
  String get path => throw _privateConstructorUsedError;

  /// The path template (/book/:id)
  String get pathTemplate => throw _privateConstructorUsedError;

  /// The path parameters ({id: 123})
  Map<String, String> get parameters => throw _privateConstructorUsedError;

  /// The query parameters ({search: abc})
  Map<String, String> get queryParameters => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ParsedRouteCopyWith<ParsedRoute> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ParsedRouteCopyWith<$Res> {
  factory $ParsedRouteCopyWith(
          ParsedRoute value, $Res Function(ParsedRoute) then) =
      _$ParsedRouteCopyWithImpl<$Res>;
  $Res call(
      {String path,
      String pathTemplate,
      Map<String, String> parameters,
      Map<String, String> queryParameters});
}

/// @nodoc
class _$ParsedRouteCopyWithImpl<$Res> implements $ParsedRouteCopyWith<$Res> {
  _$ParsedRouteCopyWithImpl(this._value, this._then);

  final ParsedRoute _value;
  // ignore: unused_field
  final $Res Function(ParsedRoute) _then;

  @override
  $Res call({
    Object? path = freezed,
    Object? pathTemplate = freezed,
    Object? parameters = freezed,
    Object? queryParameters = freezed,
  }) {
    return _then(_value.copyWith(
      path: path == freezed
          ? _value.path
          : path // ignore: cast_nullable_to_non_nullable
              as String,
      pathTemplate: pathTemplate == freezed
          ? _value.pathTemplate
          : pathTemplate // ignore: cast_nullable_to_non_nullable
              as String,
      parameters: parameters == freezed
          ? _value.parameters
          : parameters // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      queryParameters: queryParameters == freezed
          ? _value.queryParameters
          : queryParameters // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
    ));
  }
}

/// @nodoc
abstract class _$$_ParsedRouteCopyWith<$Res>
    implements $ParsedRouteCopyWith<$Res> {
  factory _$$_ParsedRouteCopyWith(
          _$_ParsedRoute value, $Res Function(_$_ParsedRoute) then) =
      __$$_ParsedRouteCopyWithImpl<$Res>;
  @override
  $Res call(
      {String path,
      String pathTemplate,
      Map<String, String> parameters,
      Map<String, String> queryParameters});
}

/// @nodoc
class __$$_ParsedRouteCopyWithImpl<$Res> extends _$ParsedRouteCopyWithImpl<$Res>
    implements _$$_ParsedRouteCopyWith<$Res> {
  __$$_ParsedRouteCopyWithImpl(
      _$_ParsedRoute _value, $Res Function(_$_ParsedRoute) _then)
      : super(_value, (v) => _then(v as _$_ParsedRoute));

  @override
  _$_ParsedRoute get _value => super._value as _$_ParsedRoute;

  @override
  $Res call({
    Object? path = freezed,
    Object? pathTemplate = freezed,
    Object? parameters = freezed,
    Object? queryParameters = freezed,
  }) {
    return _then(_$_ParsedRoute(
      path: path == freezed
          ? _value.path
          : path // ignore: cast_nullable_to_non_nullable
              as String,
      pathTemplate: pathTemplate == freezed
          ? _value.pathTemplate
          : pathTemplate // ignore: cast_nullable_to_non_nullable
              as String,
      parameters: parameters == freezed
          ? _value._parameters
          : parameters // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      queryParameters: queryParameters == freezed
          ? _value._queryParameters
          : queryParameters // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$_ParsedRoute extends _ParsedRoute with DiagnosticableTreeMixin {
  const _$_ParsedRoute(
      {required this.path,
      required this.pathTemplate,
      required final Map<String, String> parameters,
      required final Map<String, String> queryParameters})
      : _parameters = parameters,
        _queryParameters = queryParameters,
        super._();

  factory _$_ParsedRoute.fromJson(Map<String, dynamic> json) =>
      _$$_ParsedRouteFromJson(json);

  /// The current path location without query parameters. (/book/123)
  @override
  final String path;

  /// The path template (/book/:id)
  @override
  final String pathTemplate;

  /// The path parameters ({id: 123})
  final Map<String, String> _parameters;

  /// The path parameters ({id: 123})
  @override
  Map<String, String> get parameters {
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_parameters);
  }

  /// The query parameters ({search: abc})
  final Map<String, String> _queryParameters;

  /// The query parameters ({search: abc})
  @override
  Map<String, String> get queryParameters {
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_queryParameters);
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ParsedRoute(path: $path, pathTemplate: $pathTemplate, parameters: $parameters, queryParameters: $queryParameters)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ParsedRoute'))
      ..add(DiagnosticsProperty('path', path))
      ..add(DiagnosticsProperty('pathTemplate', pathTemplate))
      ..add(DiagnosticsProperty('parameters', parameters))
      ..add(DiagnosticsProperty('queryParameters', queryParameters));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_ParsedRoute &&
            const DeepCollectionEquality().equals(other.path, path) &&
            const DeepCollectionEquality()
                .equals(other.pathTemplate, pathTemplate) &&
            const DeepCollectionEquality()
                .equals(other._parameters, _parameters) &&
            const DeepCollectionEquality()
                .equals(other._queryParameters, _queryParameters));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(path),
      const DeepCollectionEquality().hash(pathTemplate),
      const DeepCollectionEquality().hash(_parameters),
      const DeepCollectionEquality().hash(_queryParameters));

  @JsonKey(ignore: true)
  @override
  _$$_ParsedRouteCopyWith<_$_ParsedRoute> get copyWith =>
      __$$_ParsedRouteCopyWithImpl<_$_ParsedRoute>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_ParsedRouteToJson(
      this,
    );
  }
}

abstract class _ParsedRoute extends ParsedRoute {
  const factory _ParsedRoute(
      {required final String path,
      required final String pathTemplate,
      required final Map<String, String> parameters,
      required final Map<String, String> queryParameters}) = _$_ParsedRoute;
  const _ParsedRoute._() : super._();

  factory _ParsedRoute.fromJson(Map<String, dynamic> json) =
      _$_ParsedRoute.fromJson;

  @override

  /// The current path location without query parameters. (/book/123)
  String get path;
  @override

  /// The path template (/book/:id)
  String get pathTemplate;
  @override

  /// The path parameters ({id: 123})
  Map<String, String> get parameters;
  @override

  /// The query parameters ({search: abc})
  Map<String, String> get queryParameters;
  @override
  @JsonKey(ignore: true)
  _$$_ParsedRouteCopyWith<_$_ParsedRoute> get copyWith =>
      throw _privateConstructorUsedError;
}
