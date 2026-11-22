// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'project_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WorldBindingModel implements DiagnosticableTreeMixin {

 String get worldId; String get endpoint; String get displayName; String get workspace;
/// Create a copy of WorldBindingModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorldBindingModelCopyWith<WorldBindingModel> get copyWith => _$WorldBindingModelCopyWithImpl<WorldBindingModel>(this as WorldBindingModel, _$identity);

  /// Serializes this WorldBindingModel to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'WorldBindingModel'))
    ..add(DiagnosticsProperty('worldId', worldId))..add(DiagnosticsProperty('endpoint', endpoint))..add(DiagnosticsProperty('displayName', displayName))..add(DiagnosticsProperty('workspace', workspace));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorldBindingModel&&(identical(other.worldId, worldId) || other.worldId == worldId)&&(identical(other.endpoint, endpoint) || other.endpoint == endpoint)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.workspace, workspace) || other.workspace == workspace));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,worldId,endpoint,displayName,workspace);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'WorldBindingModel(worldId: $worldId, endpoint: $endpoint, displayName: $displayName, workspace: $workspace)';
}


}

/// @nodoc
abstract mixin class $WorldBindingModelCopyWith<$Res>  {
  factory $WorldBindingModelCopyWith(WorldBindingModel value, $Res Function(WorldBindingModel) _then) = _$WorldBindingModelCopyWithImpl;
@useResult
$Res call({
 String worldId, String endpoint, String displayName, String workspace
});




}
/// @nodoc
class _$WorldBindingModelCopyWithImpl<$Res>
    implements $WorldBindingModelCopyWith<$Res> {
  _$WorldBindingModelCopyWithImpl(this._self, this._then);

  final WorldBindingModel _self;
  final $Res Function(WorldBindingModel) _then;

/// Create a copy of WorldBindingModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? worldId = null,Object? endpoint = null,Object? displayName = null,Object? workspace = null,}) {
  return _then(WorldBindingModel(
worldId: null == worldId ? _self.worldId : worldId // ignore: cast_nullable_to_non_nullable
as String,endpoint: null == endpoint ? _self.endpoint : endpoint // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,workspace: null == workspace ? _self.workspace : workspace // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [WorldBindingModel].
extension WorldBindingModelPatterns on WorldBindingModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorldBindingModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorldBindingModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorldBindingModel value)  $default,){
final _that = this;
switch (_that) {
case _WorldBindingModel():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorldBindingModel value)?  $default,){
final _that = this;
switch (_that) {
case _WorldBindingModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String worldId,  String endpoint,  String displayName,  String workspace)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorldBindingModel() when $default != null:
return $default(_that.worldId,_that.endpoint,_that.displayName,_that.workspace);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String worldId,  String endpoint,  String displayName,  String workspace)  $default,) {final _that = this;
switch (_that) {
case _WorldBindingModel():
return $default(_that.worldId,_that.endpoint,_that.displayName,_that.workspace);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String worldId,  String endpoint,  String displayName,  String workspace)?  $default,) {final _that = this;
switch (_that) {
case _WorldBindingModel() when $default != null:
return $default(_that.worldId,_that.endpoint,_that.displayName,_that.workspace);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorldBindingModel with DiagnosticableTreeMixin implements WorldBindingModel {
  const _WorldBindingModel({required this.worldId, required this.endpoint, this.displayName = '', this.workspace = ''});
  factory _WorldBindingModel.fromJson(Map<String, dynamic> json) => _$WorldBindingModelFromJson(json);

@override final  String worldId;
@override final  String endpoint;
@override@JsonKey() final  String displayName;
@override@JsonKey() final  String workspace;

/// Create a copy of WorldBindingModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorldBindingModelCopyWith<_WorldBindingModel> get copyWith => __$WorldBindingModelCopyWithImpl<_WorldBindingModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorldBindingModelToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'WorldBindingModel'))
    ..add(DiagnosticsProperty('worldId', worldId))..add(DiagnosticsProperty('endpoint', endpoint))..add(DiagnosticsProperty('displayName', displayName))..add(DiagnosticsProperty('workspace', workspace));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorldBindingModel&&(identical(other.worldId, worldId) || other.worldId == worldId)&&(identical(other.endpoint, endpoint) || other.endpoint == endpoint)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.workspace, workspace) || other.workspace == workspace));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,worldId,endpoint,displayName,workspace);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'WorldBindingModel(worldId: $worldId, endpoint: $endpoint, displayName: $displayName, workspace: $workspace)';
}


}

/// @nodoc
abstract mixin class _$WorldBindingModelCopyWith<$Res> implements $WorldBindingModelCopyWith<$Res> {
  factory _$WorldBindingModelCopyWith(_WorldBindingModel value, $Res Function(_WorldBindingModel) _then) = __$WorldBindingModelCopyWithImpl;
@override @useResult
$Res call({
 String worldId, String endpoint, String displayName, String workspace
});




}
/// @nodoc
class __$WorldBindingModelCopyWithImpl<$Res>
    implements _$WorldBindingModelCopyWith<$Res> {
  __$WorldBindingModelCopyWithImpl(this._self, this._then);

  final _WorldBindingModel _self;
  final $Res Function(_WorldBindingModel) _then;

/// Create a copy of WorldBindingModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? worldId = null,Object? endpoint = null,Object? displayName = null,Object? workspace = null,}) {
  return _then(_WorldBindingModel(
worldId: null == worldId ? _self.worldId : worldId // ignore: cast_nullable_to_non_nullable
as String,endpoint: null == endpoint ? _self.endpoint : endpoint // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,workspace: null == workspace ? _self.workspace : workspace // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$AgentDocModel implements DiagnosticableTreeMixin {

 List<String> get workspaces; String get backend;/// For the `external_acp` backend: registry key of the agent server
/// configured in the agent config file, used as the harness's generator.
 String get externalAcpServer;/// Explicit verification command overriding the workspace convention
/// (D8): the same escape hatch the CLI spells `--check`. Empty = the
/// workspace convention decides.
 List<String> get checkCommand;/// The external harness world this doc observes (null = the embedded
/// in-process world — the default path).
 WorldBindingModel? get worldBinding;
/// Create a copy of AgentDocModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AgentDocModelCopyWith<AgentDocModel> get copyWith => _$AgentDocModelCopyWithImpl<AgentDocModel>(this as AgentDocModel, _$identity);

  /// Serializes this AgentDocModel to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'AgentDocModel'))
    ..add(DiagnosticsProperty('workspaces', workspaces))..add(DiagnosticsProperty('backend', backend))..add(DiagnosticsProperty('externalAcpServer', externalAcpServer))..add(DiagnosticsProperty('checkCommand', checkCommand))..add(DiagnosticsProperty('worldBinding', worldBinding));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AgentDocModel&&const DeepCollectionEquality().equals(other.workspaces, workspaces)&&(identical(other.backend, backend) || other.backend == backend)&&(identical(other.externalAcpServer, externalAcpServer) || other.externalAcpServer == externalAcpServer)&&const DeepCollectionEquality().equals(other.checkCommand, checkCommand)&&(identical(other.worldBinding, worldBinding) || other.worldBinding == worldBinding));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(workspaces),backend,externalAcpServer,const DeepCollectionEquality().hash(checkCommand),worldBinding);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'AgentDocModel(workspaces: $workspaces, backend: $backend, externalAcpServer: $externalAcpServer, checkCommand: $checkCommand, worldBinding: $worldBinding)';
}


}

/// @nodoc
abstract mixin class $AgentDocModelCopyWith<$Res>  {
  factory $AgentDocModelCopyWith(AgentDocModel value, $Res Function(AgentDocModel) _then) = _$AgentDocModelCopyWithImpl;
@useResult
$Res call({
 List<String> workspaces, String backend, String externalAcpServer, List<String> checkCommand, WorldBindingModel? worldBinding
});


$WorldBindingModelCopyWith<$Res>? get worldBinding;

}
/// @nodoc
class _$AgentDocModelCopyWithImpl<$Res>
    implements $AgentDocModelCopyWith<$Res> {
  _$AgentDocModelCopyWithImpl(this._self, this._then);

  final AgentDocModel _self;
  final $Res Function(AgentDocModel) _then;

/// Create a copy of AgentDocModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? workspaces = null,Object? backend = null,Object? externalAcpServer = null,Object? checkCommand = null,Object? worldBinding = freezed,}) {
  return _then(AgentDocModel(
workspaces: null == workspaces ? _self.workspaces : workspaces // ignore: cast_nullable_to_non_nullable
as List<String>,backend: null == backend ? _self.backend : backend // ignore: cast_nullable_to_non_nullable
as String,externalAcpServer: null == externalAcpServer ? _self.externalAcpServer : externalAcpServer // ignore: cast_nullable_to_non_nullable
as String,checkCommand: null == checkCommand ? _self.checkCommand : checkCommand // ignore: cast_nullable_to_non_nullable
as List<String>,worldBinding: freezed == worldBinding ? _self.worldBinding : worldBinding // ignore: cast_nullable_to_non_nullable
as WorldBindingModel?,
  ));
}
/// Create a copy of AgentDocModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WorldBindingModelCopyWith<$Res>? get worldBinding {
    if (_self.worldBinding == null) {
    return null;
  }

  return $WorldBindingModelCopyWith<$Res>(_self.worldBinding!, (value) {
    return _then(_self.copyWith(worldBinding: value));
  });
}
}


/// Adds pattern-matching-related methods to [AgentDocModel].
extension AgentDocModelPatterns on AgentDocModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AgentDocModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AgentDocModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AgentDocModel value)  $default,){
final _that = this;
switch (_that) {
case _AgentDocModel():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AgentDocModel value)?  $default,){
final _that = this;
switch (_that) {
case _AgentDocModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> workspaces,  String backend,  String externalAcpServer,  List<String> checkCommand,  WorldBindingModel? worldBinding)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AgentDocModel() when $default != null:
return $default(_that.workspaces,_that.backend,_that.externalAcpServer,_that.checkCommand,_that.worldBinding);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> workspaces,  String backend,  String externalAcpServer,  List<String> checkCommand,  WorldBindingModel? worldBinding)  $default,) {final _that = this;
switch (_that) {
case _AgentDocModel():
return $default(_that.workspaces,_that.backend,_that.externalAcpServer,_that.checkCommand,_that.worldBinding);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> workspaces,  String backend,  String externalAcpServer,  List<String> checkCommand,  WorldBindingModel? worldBinding)?  $default,) {final _that = this;
switch (_that) {
case _AgentDocModel() when $default != null:
return $default(_that.workspaces,_that.backend,_that.externalAcpServer,_that.checkCommand,_that.worldBinding);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AgentDocModel with DiagnosticableTreeMixin implements AgentDocModel {
  const _AgentDocModel({ List<String> workspaces = const [], this.backend = 'apple_foundation_afm', this.externalAcpServer = '',  List<String> checkCommand = const [], this.worldBinding = null}): _workspaces = workspaces,_checkCommand = checkCommand;
  factory _AgentDocModel.fromJson(Map<String, dynamic> json) => _$AgentDocModelFromJson(json);

 final  List<String> _workspaces;
@override@JsonKey() List<String> get workspaces {
  if (_workspaces is EqualUnmodifiableListView) return _workspaces;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_workspaces);
}

@override@JsonKey() final  String backend;
/// For the `external_acp` backend: registry key of the agent server
/// configured in the agent config file, used as the harness's generator.
@override@JsonKey() final  String externalAcpServer;
/// Explicit verification command overriding the workspace convention
/// (D8): the same escape hatch the CLI spells `--check`. Empty = the
/// workspace convention decides.
 final  List<String> _checkCommand;
/// Explicit verification command overriding the workspace convention
/// (D8): the same escape hatch the CLI spells `--check`. Empty = the
/// workspace convention decides.
@override@JsonKey() List<String> get checkCommand {
  if (_checkCommand is EqualUnmodifiableListView) return _checkCommand;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_checkCommand);
}

/// The external harness world this doc observes (null = the embedded
/// in-process world — the default path).
@override@JsonKey() final  WorldBindingModel? worldBinding;

/// Create a copy of AgentDocModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AgentDocModelCopyWith<_AgentDocModel> get copyWith => __$AgentDocModelCopyWithImpl<_AgentDocModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AgentDocModelToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'AgentDocModel'))
    ..add(DiagnosticsProperty('workspaces', workspaces))..add(DiagnosticsProperty('backend', backend))..add(DiagnosticsProperty('externalAcpServer', externalAcpServer))..add(DiagnosticsProperty('checkCommand', checkCommand))..add(DiagnosticsProperty('worldBinding', worldBinding));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AgentDocModel&&const DeepCollectionEquality().equals(other._workspaces, _workspaces)&&(identical(other.backend, backend) || other.backend == backend)&&(identical(other.externalAcpServer, externalAcpServer) || other.externalAcpServer == externalAcpServer)&&const DeepCollectionEquality().equals(other._checkCommand, _checkCommand)&&(identical(other.worldBinding, worldBinding) || other.worldBinding == worldBinding));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_workspaces),backend,externalAcpServer,const DeepCollectionEquality().hash(_checkCommand),worldBinding);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'AgentDocModel(workspaces: $workspaces, backend: $backend, externalAcpServer: $externalAcpServer, checkCommand: $checkCommand, worldBinding: $worldBinding)';
}


}

/// @nodoc
abstract mixin class _$AgentDocModelCopyWith<$Res> implements $AgentDocModelCopyWith<$Res> {
  factory _$AgentDocModelCopyWith(_AgentDocModel value, $Res Function(_AgentDocModel) _then) = __$AgentDocModelCopyWithImpl;
@override @useResult
$Res call({
 List<String> workspaces, String backend, String externalAcpServer, List<String> checkCommand, WorldBindingModel? worldBinding
});


@override $WorldBindingModelCopyWith<$Res>? get worldBinding;

}
/// @nodoc
class __$AgentDocModelCopyWithImpl<$Res>
    implements _$AgentDocModelCopyWith<$Res> {
  __$AgentDocModelCopyWithImpl(this._self, this._then);

  final _AgentDocModel _self;
  final $Res Function(_AgentDocModel) _then;

/// Create a copy of AgentDocModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? workspaces = null,Object? backend = null,Object? externalAcpServer = null,Object? checkCommand = null,Object? worldBinding = freezed,}) {
  return _then(_AgentDocModel(
workspaces: null == workspaces ? _self._workspaces : workspaces // ignore: cast_nullable_to_non_nullable
as List<String>,backend: null == backend ? _self.backend : backend // ignore: cast_nullable_to_non_nullable
as String,externalAcpServer: null == externalAcpServer ? _self.externalAcpServer : externalAcpServer // ignore: cast_nullable_to_non_nullable
as String,checkCommand: null == checkCommand ? _self._checkCommand : checkCommand // ignore: cast_nullable_to_non_nullable
as List<String>,worldBinding: freezed == worldBinding ? _self.worldBinding : worldBinding // ignore: cast_nullable_to_non_nullable
as WorldBindingModel?,
  ));
}

/// Create a copy of AgentDocModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WorldBindingModelCopyWith<$Res>? get worldBinding {
    if (_self.worldBinding == null) {
    return null;
  }

  return $WorldBindingModelCopyWith<$Res>(_self.worldBinding!, (value) {
    return _then(_self.copyWith(worldBinding: value));
  });
}
}


/// @nodoc
mixin _$DocBlockModel implements DiagnosticableTreeMixin {

 DocBlockId get id; DocBlockType get type; String get content; int? get level;
/// Create a copy of DocBlockModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocBlockModelCopyWith<DocBlockModel> get copyWith => _$DocBlockModelCopyWithImpl<DocBlockModel>(this as DocBlockModel, _$identity);

  /// Serializes this DocBlockModel to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'DocBlockModel'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('type', type))..add(DiagnosticsProperty('content', content))..add(DiagnosticsProperty('level', level));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DocBlockModel&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.content, content) || other.content == content)&&(identical(other.level, level) || other.level == level));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,content,level);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'DocBlockModel(id: $id, type: $type, content: $content, level: $level)';
}


}

/// @nodoc
abstract mixin class $DocBlockModelCopyWith<$Res>  {
  factory $DocBlockModelCopyWith(DocBlockModel value, $Res Function(DocBlockModel) _then) = _$DocBlockModelCopyWithImpl;
@useResult
$Res call({
 DocBlockId id, DocBlockType type, String content, int? level
});




}
/// @nodoc
class _$DocBlockModelCopyWithImpl<$Res>
    implements $DocBlockModelCopyWith<$Res> {
  _$DocBlockModelCopyWithImpl(this._self, this._then);

  final DocBlockModel _self;
  final $Res Function(DocBlockModel) _then;

/// Create a copy of DocBlockModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? content = null,Object? level = freezed,}) {
  return _then(DocBlockModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as DocBlockId,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as DocBlockType,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,level: freezed == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [DocBlockModel].
extension DocBlockModelPatterns on DocBlockModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DocBlockModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DocBlockModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DocBlockModel value)  $default,){
final _that = this;
switch (_that) {
case _DocBlockModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DocBlockModel value)?  $default,){
final _that = this;
switch (_that) {
case _DocBlockModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DocBlockId id,  DocBlockType type,  String content,  int? level)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DocBlockModel() when $default != null:
return $default(_that.id,_that.type,_that.content,_that.level);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DocBlockId id,  DocBlockType type,  String content,  int? level)  $default,) {final _that = this;
switch (_that) {
case _DocBlockModel():
return $default(_that.id,_that.type,_that.content,_that.level);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DocBlockId id,  DocBlockType type,  String content,  int? level)?  $default,) {final _that = this;
switch (_that) {
case _DocBlockModel() when $default != null:
return $default(_that.id,_that.type,_that.content,_that.level);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DocBlockModel with DiagnosticableTreeMixin implements DocBlockModel {
  const _DocBlockModel({required this.id, required this.type, this.content = '', this.level});
  factory _DocBlockModel.fromJson(Map<String, dynamic> json) => _$DocBlockModelFromJson(json);

@override final  DocBlockId id;
@override final  DocBlockType type;
@override@JsonKey() final  String content;
@override final  int? level;

/// Create a copy of DocBlockModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DocBlockModelCopyWith<_DocBlockModel> get copyWith => __$DocBlockModelCopyWithImpl<_DocBlockModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DocBlockModelToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'DocBlockModel'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('type', type))..add(DiagnosticsProperty('content', content))..add(DiagnosticsProperty('level', level));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DocBlockModel&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.content, content) || other.content == content)&&(identical(other.level, level) || other.level == level));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,content,level);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'DocBlockModel(id: $id, type: $type, content: $content, level: $level)';
}


}

/// @nodoc
abstract mixin class _$DocBlockModelCopyWith<$Res> implements $DocBlockModelCopyWith<$Res> {
  factory _$DocBlockModelCopyWith(_DocBlockModel value, $Res Function(_DocBlockModel) _then) = __$DocBlockModelCopyWithImpl;
@override @useResult
$Res call({
 DocBlockId id, DocBlockType type, String content, int? level
});




}
/// @nodoc
class __$DocBlockModelCopyWithImpl<$Res>
    implements _$DocBlockModelCopyWith<$Res> {
  __$DocBlockModelCopyWithImpl(this._self, this._then);

  final _DocBlockModel _self;
  final $Res Function(_DocBlockModel) _then;

/// Create a copy of DocBlockModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? content = null,Object? level = freezed,}) {
  return _then(_DocBlockModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as DocBlockId,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as DocBlockType,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,level: freezed == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$AnchorSpanModel implements DiagnosticableTreeMixin {

 DocBlockId get blockId; String? get prefixHash; String? get suffixHash;
/// Create a copy of AnchorSpanModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnchorSpanModelCopyWith<AnchorSpanModel> get copyWith => _$AnchorSpanModelCopyWithImpl<AnchorSpanModel>(this as AnchorSpanModel, _$identity);

  /// Serializes this AnchorSpanModel to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'AnchorSpanModel'))
    ..add(DiagnosticsProperty('blockId', blockId))..add(DiagnosticsProperty('prefixHash', prefixHash))..add(DiagnosticsProperty('suffixHash', suffixHash));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnchorSpanModel&&(identical(other.blockId, blockId) || other.blockId == blockId)&&(identical(other.prefixHash, prefixHash) || other.prefixHash == prefixHash)&&(identical(other.suffixHash, suffixHash) || other.suffixHash == suffixHash));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,blockId,prefixHash,suffixHash);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'AnchorSpanModel(blockId: $blockId, prefixHash: $prefixHash, suffixHash: $suffixHash)';
}


}

/// @nodoc
abstract mixin class $AnchorSpanModelCopyWith<$Res>  {
  factory $AnchorSpanModelCopyWith(AnchorSpanModel value, $Res Function(AnchorSpanModel) _then) = _$AnchorSpanModelCopyWithImpl;
@useResult
$Res call({
 DocBlockId blockId, String? prefixHash, String? suffixHash
});




}
/// @nodoc
class _$AnchorSpanModelCopyWithImpl<$Res>
    implements $AnchorSpanModelCopyWith<$Res> {
  _$AnchorSpanModelCopyWithImpl(this._self, this._then);

  final AnchorSpanModel _self;
  final $Res Function(AnchorSpanModel) _then;

/// Create a copy of AnchorSpanModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? blockId = null,Object? prefixHash = freezed,Object? suffixHash = freezed,}) {
  return _then(AnchorSpanModel(
blockId: null == blockId ? _self.blockId : blockId // ignore: cast_nullable_to_non_nullable
as DocBlockId,prefixHash: freezed == prefixHash ? _self.prefixHash : prefixHash // ignore: cast_nullable_to_non_nullable
as String?,suffixHash: freezed == suffixHash ? _self.suffixHash : suffixHash // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AnchorSpanModel].
extension AnchorSpanModelPatterns on AnchorSpanModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnchorSpanModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnchorSpanModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnchorSpanModel value)  $default,){
final _that = this;
switch (_that) {
case _AnchorSpanModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnchorSpanModel value)?  $default,){
final _that = this;
switch (_that) {
case _AnchorSpanModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DocBlockId blockId,  String? prefixHash,  String? suffixHash)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnchorSpanModel() when $default != null:
return $default(_that.blockId,_that.prefixHash,_that.suffixHash);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DocBlockId blockId,  String? prefixHash,  String? suffixHash)  $default,) {final _that = this;
switch (_that) {
case _AnchorSpanModel():
return $default(_that.blockId,_that.prefixHash,_that.suffixHash);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DocBlockId blockId,  String? prefixHash,  String? suffixHash)?  $default,) {final _that = this;
switch (_that) {
case _AnchorSpanModel() when $default != null:
return $default(_that.blockId,_that.prefixHash,_that.suffixHash);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AnchorSpanModel with DiagnosticableTreeMixin implements AnchorSpanModel {
  const _AnchorSpanModel({required this.blockId, this.prefixHash, this.suffixHash});
  factory _AnchorSpanModel.fromJson(Map<String, dynamic> json) => _$AnchorSpanModelFromJson(json);

@override final  DocBlockId blockId;
@override final  String? prefixHash;
@override final  String? suffixHash;

/// Create a copy of AnchorSpanModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnchorSpanModelCopyWith<_AnchorSpanModel> get copyWith => __$AnchorSpanModelCopyWithImpl<_AnchorSpanModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnchorSpanModelToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'AnchorSpanModel'))
    ..add(DiagnosticsProperty('blockId', blockId))..add(DiagnosticsProperty('prefixHash', prefixHash))..add(DiagnosticsProperty('suffixHash', suffixHash));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnchorSpanModel&&(identical(other.blockId, blockId) || other.blockId == blockId)&&(identical(other.prefixHash, prefixHash) || other.prefixHash == prefixHash)&&(identical(other.suffixHash, suffixHash) || other.suffixHash == suffixHash));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,blockId,prefixHash,suffixHash);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'AnchorSpanModel(blockId: $blockId, prefixHash: $prefixHash, suffixHash: $suffixHash)';
}


}

/// @nodoc
abstract mixin class _$AnchorSpanModelCopyWith<$Res> implements $AnchorSpanModelCopyWith<$Res> {
  factory _$AnchorSpanModelCopyWith(_AnchorSpanModel value, $Res Function(_AnchorSpanModel) _then) = __$AnchorSpanModelCopyWithImpl;
@override @useResult
$Res call({
 DocBlockId blockId, String? prefixHash, String? suffixHash
});




}
/// @nodoc
class __$AnchorSpanModelCopyWithImpl<$Res>
    implements _$AnchorSpanModelCopyWith<$Res> {
  __$AnchorSpanModelCopyWithImpl(this._self, this._then);

  final _AnchorSpanModel _self;
  final $Res Function(_AnchorSpanModel) _then;

/// Create a copy of AnchorSpanModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? blockId = null,Object? prefixHash = freezed,Object? suffixHash = freezed,}) {
  return _then(_AnchorSpanModel(
blockId: null == blockId ? _self.blockId : blockId // ignore: cast_nullable_to_non_nullable
as DocBlockId,prefixHash: freezed == prefixHash ? _self.prefixHash : prefixHash // ignore: cast_nullable_to_non_nullable
as String?,suffixHash: freezed == suffixHash ? _self.suffixHash : suffixHash // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$NoteAssetModel implements DiagnosticableTreeMixin {

 String get id; String get path; String get mime; String get alt; int get width; int get height; int get bytes; DateTime? get createdAt;
/// Create a copy of NoteAssetModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NoteAssetModelCopyWith<NoteAssetModel> get copyWith => _$NoteAssetModelCopyWithImpl<NoteAssetModel>(this as NoteAssetModel, _$identity);

  /// Serializes this NoteAssetModel to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'NoteAssetModel'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('path', path))..add(DiagnosticsProperty('mime', mime))..add(DiagnosticsProperty('alt', alt))..add(DiagnosticsProperty('width', width))..add(DiagnosticsProperty('height', height))..add(DiagnosticsProperty('bytes', bytes))..add(DiagnosticsProperty('createdAt', createdAt));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NoteAssetModel&&(identical(other.id, id) || other.id == id)&&(identical(other.path, path) || other.path == path)&&(identical(other.mime, mime) || other.mime == mime)&&(identical(other.alt, alt) || other.alt == alt)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.bytes, bytes) || other.bytes == bytes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,path,mime,alt,width,height,bytes,createdAt);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'NoteAssetModel(id: $id, path: $path, mime: $mime, alt: $alt, width: $width, height: $height, bytes: $bytes, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $NoteAssetModelCopyWith<$Res>  {
  factory $NoteAssetModelCopyWith(NoteAssetModel value, $Res Function(NoteAssetModel) _then) = _$NoteAssetModelCopyWithImpl;
@useResult
$Res call({
 String id, String path, String mime, String alt, int width, int height, int bytes, DateTime? createdAt
});




}
/// @nodoc
class _$NoteAssetModelCopyWithImpl<$Res>
    implements $NoteAssetModelCopyWith<$Res> {
  _$NoteAssetModelCopyWithImpl(this._self, this._then);

  final NoteAssetModel _self;
  final $Res Function(NoteAssetModel) _then;

/// Create a copy of NoteAssetModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? path = null,Object? mime = null,Object? alt = null,Object? width = null,Object? height = null,Object? bytes = null,Object? createdAt = freezed,}) {
  return _then(NoteAssetModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,mime: null == mime ? _self.mime : mime // ignore: cast_nullable_to_non_nullable
as String,alt: null == alt ? _self.alt : alt // ignore: cast_nullable_to_non_nullable
as String,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,bytes: null == bytes ? _self.bytes : bytes // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [NoteAssetModel].
extension NoteAssetModelPatterns on NoteAssetModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NoteAssetModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NoteAssetModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NoteAssetModel value)  $default,){
final _that = this;
switch (_that) {
case _NoteAssetModel():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NoteAssetModel value)?  $default,){
final _that = this;
switch (_that) {
case _NoteAssetModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String path,  String mime,  String alt,  int width,  int height,  int bytes,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NoteAssetModel() when $default != null:
return $default(_that.id,_that.path,_that.mime,_that.alt,_that.width,_that.height,_that.bytes,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String path,  String mime,  String alt,  int width,  int height,  int bytes,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _NoteAssetModel():
return $default(_that.id,_that.path,_that.mime,_that.alt,_that.width,_that.height,_that.bytes,_that.createdAt);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String path,  String mime,  String alt,  int width,  int height,  int bytes,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _NoteAssetModel() when $default != null:
return $default(_that.id,_that.path,_that.mime,_that.alt,_that.width,_that.height,_that.bytes,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NoteAssetModel extends NoteAssetModel with DiagnosticableTreeMixin {
  const _NoteAssetModel({required this.id, required this.path, this.mime = 'image/png', this.alt = '', this.width = 0, this.height = 0, this.bytes = 0, this.createdAt}): super._();
  factory _NoteAssetModel.fromJson(Map<String, dynamic> json) => _$NoteAssetModelFromJson(json);

@override final  String id;
@override final  String path;
@override@JsonKey() final  String mime;
@override@JsonKey() final  String alt;
@override@JsonKey() final  int width;
@override@JsonKey() final  int height;
@override@JsonKey() final  int bytes;
@override final  DateTime? createdAt;

/// Create a copy of NoteAssetModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NoteAssetModelCopyWith<_NoteAssetModel> get copyWith => __$NoteAssetModelCopyWithImpl<_NoteAssetModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NoteAssetModelToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'NoteAssetModel'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('path', path))..add(DiagnosticsProperty('mime', mime))..add(DiagnosticsProperty('alt', alt))..add(DiagnosticsProperty('width', width))..add(DiagnosticsProperty('height', height))..add(DiagnosticsProperty('bytes', bytes))..add(DiagnosticsProperty('createdAt', createdAt));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NoteAssetModel&&(identical(other.id, id) || other.id == id)&&(identical(other.path, path) || other.path == path)&&(identical(other.mime, mime) || other.mime == mime)&&(identical(other.alt, alt) || other.alt == alt)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.bytes, bytes) || other.bytes == bytes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,path,mime,alt,width,height,bytes,createdAt);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'NoteAssetModel(id: $id, path: $path, mime: $mime, alt: $alt, width: $width, height: $height, bytes: $bytes, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$NoteAssetModelCopyWith<$Res> implements $NoteAssetModelCopyWith<$Res> {
  factory _$NoteAssetModelCopyWith(_NoteAssetModel value, $Res Function(_NoteAssetModel) _then) = __$NoteAssetModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String path, String mime, String alt, int width, int height, int bytes, DateTime? createdAt
});




}
/// @nodoc
class __$NoteAssetModelCopyWithImpl<$Res>
    implements _$NoteAssetModelCopyWith<$Res> {
  __$NoteAssetModelCopyWithImpl(this._self, this._then);

  final _NoteAssetModel _self;
  final $Res Function(_NoteAssetModel) _then;

/// Create a copy of NoteAssetModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? path = null,Object? mime = null,Object? alt = null,Object? width = null,Object? height = null,Object? bytes = null,Object? createdAt = freezed,}) {
  return _then(_NoteAssetModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,mime: null == mime ? _self.mime : mime // ignore: cast_nullable_to_non_nullable
as String,alt: null == alt ? _self.alt : alt // ignore: cast_nullable_to_non_nullable
as String,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,bytes: null == bytes ? _self.bytes : bytes // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

ProjectModel _$ProjectModelFromJson(
  Map<String, dynamic> json
) {
        switch (json['runtimeType']) {
                  case 'idea':
          return ProjectModelIdea.fromJson(
            json
          );
                case 'note':
          return ProjectModelNote.fromJson(
            json
          );
                case 'changelog':
          return ProjectModelChangelog.fromJson(
            json
          );
                case 'doc':
          return ProjectModelDoc.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'runtimeType',
  'ProjectModel',
  'Invalid union type "${json['runtimeType']}"!'
);
        }
      
}

/// @nodoc
mixin _$ProjectModel implements DiagnosticableTreeMixin {

 ProjectModelId get id; DateTime get createdAt; DateTime get updatedAt; ProjectTypes get type; DateTime? get archivedAt; List<ProjectTagModelId> get tagsIds;
/// Create a copy of ProjectModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectModelCopyWith<ProjectModel> get copyWith => _$ProjectModelCopyWithImpl<ProjectModel>(this as ProjectModel, _$identity);

  /// Serializes this ProjectModel to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'ProjectModel'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('createdAt', createdAt))..add(DiagnosticsProperty('updatedAt', updatedAt))..add(DiagnosticsProperty('type', type))..add(DiagnosticsProperty('archivedAt', archivedAt))..add(DiagnosticsProperty('tagsIds', tagsIds));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectModel&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.type, type) || other.type == type)&&(identical(other.archivedAt, archivedAt) || other.archivedAt == archivedAt)&&const DeepCollectionEquality().equals(other.tagsIds, tagsIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createdAt,updatedAt,type,archivedAt,const DeepCollectionEquality().hash(tagsIds));

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'ProjectModel(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, type: $type, archivedAt: $archivedAt, tagsIds: $tagsIds)';
}


}

/// @nodoc
abstract mixin class $ProjectModelCopyWith<$Res>  {
  factory $ProjectModelCopyWith(ProjectModel value, $Res Function(ProjectModel) _then) = _$ProjectModelCopyWithImpl;
@useResult
$Res call({
 ProjectModelId id, DateTime createdAt, DateTime updatedAt, ProjectTypes type, DateTime? archivedAt, List<ProjectTagModelId> tagsIds
});




}
/// @nodoc
class _$ProjectModelCopyWithImpl<$Res>
    implements $ProjectModelCopyWith<$Res> {
  _$ProjectModelCopyWithImpl(this._self, this._then);

  final ProjectModel _self;
  final $Res Function(ProjectModel) _then;

/// Create a copy of ProjectModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? createdAt = null,Object? updatedAt = null,Object? type = null,Object? archivedAt = freezed,Object? tagsIds = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as ProjectModelId,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ProjectTypes,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,tagsIds: null == tagsIds ? _self.tagsIds : tagsIds // ignore: cast_nullable_to_non_nullable
as List<ProjectTagModelId>,
  ));
}

}


/// Adds pattern-matching-related methods to [ProjectModel].
extension ProjectModelPatterns on ProjectModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ProjectModelIdea value)?  idea,TResult Function( ProjectModelNote value)?  note,TResult Function( ProjectModelChangelog value)?  changelog,TResult Function( ProjectModelDoc value)?  doc,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ProjectModelIdea() when idea != null:
return idea(_that);case ProjectModelNote() when note != null:
return note(_that);case ProjectModelChangelog() when changelog != null:
return changelog(_that);case ProjectModelDoc() when doc != null:
return doc(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ProjectModelIdea value)  idea,required TResult Function( ProjectModelNote value)  note,required TResult Function( ProjectModelChangelog value)  changelog,required TResult Function( ProjectModelDoc value)  doc,}){
final _that = this;
switch (_that) {
case ProjectModelIdea():
return idea(_that);case ProjectModelNote():
return note(_that);case ProjectModelChangelog():
return changelog(_that);case ProjectModelDoc():
return doc(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ProjectModelIdea value)?  idea,TResult? Function( ProjectModelNote value)?  note,TResult? Function( ProjectModelChangelog value)?  changelog,TResult? Function( ProjectModelDoc value)?  doc,}){
final _that = this;
switch (_that) {
case ProjectModelIdea() when idea != null:
return idea(_that);case ProjectModelNote() when note != null:
return note(_that);case ProjectModelChangelog() when changelog != null:
return changelog(_that);case ProjectModelDoc() when doc != null:
return doc(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( ProjectModelId id,  DateTime createdAt,  DateTime updatedAt,  String title,  ProjectTypes type,  DateTime? archivedAt,  List<IdeaProjectAnswerModel> answers,  IdeaProjectAnswerModel? draftAnswer,  List<ProjectTagModelId> tagsIds)?  idea,TResult Function( ProjectModelId id,  DateTime createdAt,  DateTime updatedAt,  String note,  ProjectTypes type,  int charactersLimit,  DateTime? archivedAt,  List<ProjectTagModelId> tagsIds,  List<NoteAssetModel> assets)?  note,TResult Function( DateTime createdAt,  DateTime updatedAt,  LocalizedTextModel title,  ProjectModelId id,  ProjectTypes type,  List<ProjectTagModelId> tagsIds,  DateTime? archivedAt)?  changelog,TResult Function( ProjectModelId id,  DateTime createdAt,  DateTime updatedAt,  String formatId,  String title,  ProjectTypes type,  List<ProjectTagModelId> tagsIds,  DateTime? archivedAt,  List<DocBlockModel> blocks,  ProjectModelId? parentDocId,  AnchorSpanModel? anchorSpan,  String spanSnapshot,  AgentDocModel? agent,  DocStatus status)?  doc,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ProjectModelIdea() when idea != null:
return idea(_that.id,_that.createdAt,_that.updatedAt,_that.title,_that.type,_that.archivedAt,_that.answers,_that.draftAnswer,_that.tagsIds);case ProjectModelNote() when note != null:
return note(_that.id,_that.createdAt,_that.updatedAt,_that.note,_that.type,_that.charactersLimit,_that.archivedAt,_that.tagsIds,_that.assets);case ProjectModelChangelog() when changelog != null:
return changelog(_that.createdAt,_that.updatedAt,_that.title,_that.id,_that.type,_that.tagsIds,_that.archivedAt);case ProjectModelDoc() when doc != null:
return doc(_that.id,_that.createdAt,_that.updatedAt,_that.formatId,_that.title,_that.type,_that.tagsIds,_that.archivedAt,_that.blocks,_that.parentDocId,_that.anchorSpan,_that.spanSnapshot,_that.agent,_that.status);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( ProjectModelId id,  DateTime createdAt,  DateTime updatedAt,  String title,  ProjectTypes type,  DateTime? archivedAt,  List<IdeaProjectAnswerModel> answers,  IdeaProjectAnswerModel? draftAnswer,  List<ProjectTagModelId> tagsIds)  idea,required TResult Function( ProjectModelId id,  DateTime createdAt,  DateTime updatedAt,  String note,  ProjectTypes type,  int charactersLimit,  DateTime? archivedAt,  List<ProjectTagModelId> tagsIds,  List<NoteAssetModel> assets)  note,required TResult Function( DateTime createdAt,  DateTime updatedAt,  LocalizedTextModel title,  ProjectModelId id,  ProjectTypes type,  List<ProjectTagModelId> tagsIds,  DateTime? archivedAt)  changelog,required TResult Function( ProjectModelId id,  DateTime createdAt,  DateTime updatedAt,  String formatId,  String title,  ProjectTypes type,  List<ProjectTagModelId> tagsIds,  DateTime? archivedAt,  List<DocBlockModel> blocks,  ProjectModelId? parentDocId,  AnchorSpanModel? anchorSpan,  String spanSnapshot,  AgentDocModel? agent,  DocStatus status)  doc,}) {final _that = this;
switch (_that) {
case ProjectModelIdea():
return idea(_that.id,_that.createdAt,_that.updatedAt,_that.title,_that.type,_that.archivedAt,_that.answers,_that.draftAnswer,_that.tagsIds);case ProjectModelNote():
return note(_that.id,_that.createdAt,_that.updatedAt,_that.note,_that.type,_that.charactersLimit,_that.archivedAt,_that.tagsIds,_that.assets);case ProjectModelChangelog():
return changelog(_that.createdAt,_that.updatedAt,_that.title,_that.id,_that.type,_that.tagsIds,_that.archivedAt);case ProjectModelDoc():
return doc(_that.id,_that.createdAt,_that.updatedAt,_that.formatId,_that.title,_that.type,_that.tagsIds,_that.archivedAt,_that.blocks,_that.parentDocId,_that.anchorSpan,_that.spanSnapshot,_that.agent,_that.status);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( ProjectModelId id,  DateTime createdAt,  DateTime updatedAt,  String title,  ProjectTypes type,  DateTime? archivedAt,  List<IdeaProjectAnswerModel> answers,  IdeaProjectAnswerModel? draftAnswer,  List<ProjectTagModelId> tagsIds)?  idea,TResult? Function( ProjectModelId id,  DateTime createdAt,  DateTime updatedAt,  String note,  ProjectTypes type,  int charactersLimit,  DateTime? archivedAt,  List<ProjectTagModelId> tagsIds,  List<NoteAssetModel> assets)?  note,TResult? Function( DateTime createdAt,  DateTime updatedAt,  LocalizedTextModel title,  ProjectModelId id,  ProjectTypes type,  List<ProjectTagModelId> tagsIds,  DateTime? archivedAt)?  changelog,TResult? Function( ProjectModelId id,  DateTime createdAt,  DateTime updatedAt,  String formatId,  String title,  ProjectTypes type,  List<ProjectTagModelId> tagsIds,  DateTime? archivedAt,  List<DocBlockModel> blocks,  ProjectModelId? parentDocId,  AnchorSpanModel? anchorSpan,  String spanSnapshot,  AgentDocModel? agent,  DocStatus status)?  doc,}) {final _that = this;
switch (_that) {
case ProjectModelIdea() when idea != null:
return idea(_that.id,_that.createdAt,_that.updatedAt,_that.title,_that.type,_that.archivedAt,_that.answers,_that.draftAnswer,_that.tagsIds);case ProjectModelNote() when note != null:
return note(_that.id,_that.createdAt,_that.updatedAt,_that.note,_that.type,_that.charactersLimit,_that.archivedAt,_that.tagsIds,_that.assets);case ProjectModelChangelog() when changelog != null:
return changelog(_that.createdAt,_that.updatedAt,_that.title,_that.id,_that.type,_that.tagsIds,_that.archivedAt);case ProjectModelDoc() when doc != null:
return doc(_that.id,_that.createdAt,_that.updatedAt,_that.formatId,_that.title,_that.type,_that.tagsIds,_that.archivedAt,_that.blocks,_that.parentDocId,_that.anchorSpan,_that.spanSnapshot,_that.agent,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class ProjectModelIdea extends ProjectModel with DiagnosticableTreeMixin implements Archivable, Sharable {
  const ProjectModelIdea({required this.id, required this.createdAt, required this.updatedAt, this.title = '', this.type = ProjectTypes.idea, this.archivedAt,  List<IdeaProjectAnswerModel> answers = const [], this.draftAnswer,  List<ProjectTagModelId> tagsIds = const [],  String? $type}): _answers = answers,_tagsIds = tagsIds,$type = $type ?? 'idea',super._();
  factory ProjectModelIdea.fromJson(Map<String, dynamic> json) => _$ProjectModelIdeaFromJson(json);

@override final  ProjectModelId id;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@JsonKey() final  String title;
@override@JsonKey() final  ProjectTypes type;
@override final  DateTime? archivedAt;
 final  List<IdeaProjectAnswerModel> _answers;
@JsonKey() List<IdeaProjectAnswerModel> get answers {
  if (_answers is EqualUnmodifiableListView) return _answers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_answers);
}

 final  IdeaProjectAnswerModel? draftAnswer;
 final  List<ProjectTagModelId> _tagsIds;
@override@JsonKey() List<ProjectTagModelId> get tagsIds {
  if (_tagsIds is EqualUnmodifiableListView) return _tagsIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tagsIds);
}


@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of ProjectModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectModelIdeaCopyWith<ProjectModelIdea> get copyWith => _$ProjectModelIdeaCopyWithImpl<ProjectModelIdea>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProjectModelIdeaToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'ProjectModel.idea'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('createdAt', createdAt))..add(DiagnosticsProperty('updatedAt', updatedAt))..add(DiagnosticsProperty('title', title))..add(DiagnosticsProperty('type', type))..add(DiagnosticsProperty('archivedAt', archivedAt))..add(DiagnosticsProperty('answers', answers))..add(DiagnosticsProperty('draftAnswer', draftAnswer))..add(DiagnosticsProperty('tagsIds', tagsIds));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectModelIdea&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.title, title) || other.title == title)&&(identical(other.type, type) || other.type == type)&&(identical(other.archivedAt, archivedAt) || other.archivedAt == archivedAt)&&const DeepCollectionEquality().equals(other._answers, _answers)&&(identical(other.draftAnswer, draftAnswer) || other.draftAnswer == draftAnswer)&&const DeepCollectionEquality().equals(other._tagsIds, _tagsIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createdAt,updatedAt,title,type,archivedAt,const DeepCollectionEquality().hash(_answers),draftAnswer,const DeepCollectionEquality().hash(_tagsIds));

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'ProjectModel.idea(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, title: $title, type: $type, archivedAt: $archivedAt, answers: $answers, draftAnswer: $draftAnswer, tagsIds: $tagsIds)';
}


}

/// @nodoc
abstract mixin class $ProjectModelIdeaCopyWith<$Res> implements $ProjectModelCopyWith<$Res> {
  factory $ProjectModelIdeaCopyWith(ProjectModelIdea value, $Res Function(ProjectModelIdea) _then) = _$ProjectModelIdeaCopyWithImpl;
@override @useResult
$Res call({
 ProjectModelId id, DateTime createdAt, DateTime updatedAt, String title, ProjectTypes type, DateTime? archivedAt, List<IdeaProjectAnswerModel> answers, IdeaProjectAnswerModel? draftAnswer, List<ProjectTagModelId> tagsIds
});


$IdeaProjectAnswerModelCopyWith<$Res>? get draftAnswer;

}
/// @nodoc
class _$ProjectModelIdeaCopyWithImpl<$Res>
    implements $ProjectModelIdeaCopyWith<$Res> {
  _$ProjectModelIdeaCopyWithImpl(this._self, this._then);

  final ProjectModelIdea _self;
  final $Res Function(ProjectModelIdea) _then;

/// Create a copy of ProjectModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? createdAt = null,Object? updatedAt = null,Object? title = null,Object? type = null,Object? archivedAt = freezed,Object? answers = null,Object? draftAnswer = freezed,Object? tagsIds = null,}) {
  return _then(ProjectModelIdea(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as ProjectModelId,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ProjectTypes,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,answers: null == answers ? _self._answers : answers // ignore: cast_nullable_to_non_nullable
as List<IdeaProjectAnswerModel>,draftAnswer: freezed == draftAnswer ? _self.draftAnswer : draftAnswer // ignore: cast_nullable_to_non_nullable
as IdeaProjectAnswerModel?,tagsIds: null == tagsIds ? _self._tagsIds : tagsIds // ignore: cast_nullable_to_non_nullable
as List<ProjectTagModelId>,
  ));
}

/// Create a copy of ProjectModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IdeaProjectAnswerModelCopyWith<$Res>? get draftAnswer {
    if (_self.draftAnswer == null) {
    return null;
  }

  return $IdeaProjectAnswerModelCopyWith<$Res>(_self.draftAnswer!, (value) {
    return _then(_self.copyWith(draftAnswer: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class ProjectModelNote extends ProjectModel with DiagnosticableTreeMixin implements Archivable, Sharable {
  const ProjectModelNote({required this.id, required this.createdAt, required this.updatedAt, this.note = '', this.type = ProjectTypes.note, this.charactersLimit = 0, this.archivedAt,  List<ProjectTagModelId> tagsIds = const [],  List<NoteAssetModel> assets = const [],  String? $type}): _tagsIds = tagsIds,_assets = assets,$type = $type ?? 'note',super._();
  factory ProjectModelNote.fromJson(Map<String, dynamic> json) => _$ProjectModelNoteFromJson(json);

@override final  ProjectModelId id;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@JsonKey() final  String note;
@override@JsonKey() final  ProjectTypes type;
@JsonKey() final  int charactersLimit;
@override final  DateTime? archivedAt;
 final  List<ProjectTagModelId> _tagsIds;
@override@JsonKey() List<ProjectTagModelId> get tagsIds {
  if (_tagsIds is EqualUnmodifiableListView) return _tagsIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tagsIds);
}

/// Attached images (metadata rows; the bytes live in files under
/// `note-assets/<noteId>/` in the app documents dir). Additive and
/// default-empty: old JSON restores keep working unchanged.
 final  List<NoteAssetModel> _assets;
/// Attached images (metadata rows; the bytes live in files under
/// `note-assets/<noteId>/` in the app documents dir). Additive and
/// default-empty: old JSON restores keep working unchanged.
@JsonKey() List<NoteAssetModel> get assets {
  if (_assets is EqualUnmodifiableListView) return _assets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_assets);
}


@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of ProjectModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectModelNoteCopyWith<ProjectModelNote> get copyWith => _$ProjectModelNoteCopyWithImpl<ProjectModelNote>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProjectModelNoteToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'ProjectModel.note'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('createdAt', createdAt))..add(DiagnosticsProperty('updatedAt', updatedAt))..add(DiagnosticsProperty('note', note))..add(DiagnosticsProperty('type', type))..add(DiagnosticsProperty('charactersLimit', charactersLimit))..add(DiagnosticsProperty('archivedAt', archivedAt))..add(DiagnosticsProperty('tagsIds', tagsIds))..add(DiagnosticsProperty('assets', assets));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectModelNote&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.note, note) || other.note == note)&&(identical(other.type, type) || other.type == type)&&(identical(other.charactersLimit, charactersLimit) || other.charactersLimit == charactersLimit)&&(identical(other.archivedAt, archivedAt) || other.archivedAt == archivedAt)&&const DeepCollectionEquality().equals(other._tagsIds, _tagsIds)&&const DeepCollectionEquality().equals(other._assets, _assets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createdAt,updatedAt,note,type,charactersLimit,archivedAt,const DeepCollectionEquality().hash(_tagsIds),const DeepCollectionEquality().hash(_assets));

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'ProjectModel.note(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, note: $note, type: $type, charactersLimit: $charactersLimit, archivedAt: $archivedAt, tagsIds: $tagsIds, assets: $assets)';
}


}

/// @nodoc
abstract mixin class $ProjectModelNoteCopyWith<$Res> implements $ProjectModelCopyWith<$Res> {
  factory $ProjectModelNoteCopyWith(ProjectModelNote value, $Res Function(ProjectModelNote) _then) = _$ProjectModelNoteCopyWithImpl;
@override @useResult
$Res call({
 ProjectModelId id, DateTime createdAt, DateTime updatedAt, String note, ProjectTypes type, int charactersLimit, DateTime? archivedAt, List<ProjectTagModelId> tagsIds, List<NoteAssetModel> assets
});




}
/// @nodoc
class _$ProjectModelNoteCopyWithImpl<$Res>
    implements $ProjectModelNoteCopyWith<$Res> {
  _$ProjectModelNoteCopyWithImpl(this._self, this._then);

  final ProjectModelNote _self;
  final $Res Function(ProjectModelNote) _then;

/// Create a copy of ProjectModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? createdAt = null,Object? updatedAt = null,Object? note = null,Object? type = null,Object? charactersLimit = null,Object? archivedAt = freezed,Object? tagsIds = null,Object? assets = null,}) {
  return _then(ProjectModelNote(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as ProjectModelId,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ProjectTypes,charactersLimit: null == charactersLimit ? _self.charactersLimit : charactersLimit // ignore: cast_nullable_to_non_nullable
as int,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,tagsIds: null == tagsIds ? _self._tagsIds : tagsIds // ignore: cast_nullable_to_non_nullable
as List<ProjectTagModelId>,assets: null == assets ? _self._assets : assets // ignore: cast_nullable_to_non_nullable
as List<NoteAssetModel>,
  ));
}


}

/// @nodoc
@JsonSerializable()

class ProjectModelChangelog extends ProjectModel with DiagnosticableTreeMixin implements Sharable, Archivable {
  const ProjectModelChangelog({required this.createdAt, required this.updatedAt, this.title = LocalizedTextModel.empty, this.id = ProjectModelId.systemChangelog, this.type = ProjectTypes.systemChangelog,  List<ProjectTagModelId> tagsIds = const [], this.archivedAt,  String? $type}): _tagsIds = tagsIds,$type = $type ?? 'changelog',super._();
  factory ProjectModelChangelog.fromJson(Map<String, dynamic> json) => _$ProjectModelChangelogFromJson(json);

@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@JsonKey() final  LocalizedTextModel title;
@override@JsonKey() final  ProjectModelId id;
@override@JsonKey() final  ProjectTypes type;
 final  List<ProjectTagModelId> _tagsIds;
@override@JsonKey() List<ProjectTagModelId> get tagsIds {
  if (_tagsIds is EqualUnmodifiableListView) return _tagsIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tagsIds);
}

@override final  DateTime? archivedAt;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of ProjectModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectModelChangelogCopyWith<ProjectModelChangelog> get copyWith => _$ProjectModelChangelogCopyWithImpl<ProjectModelChangelog>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProjectModelChangelogToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'ProjectModel.changelog'))
    ..add(DiagnosticsProperty('createdAt', createdAt))..add(DiagnosticsProperty('updatedAt', updatedAt))..add(DiagnosticsProperty('title', title))..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('type', type))..add(DiagnosticsProperty('tagsIds', tagsIds))..add(DiagnosticsProperty('archivedAt', archivedAt));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectModelChangelog&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.title, title) || other.title == title)&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other._tagsIds, _tagsIds)&&(identical(other.archivedAt, archivedAt) || other.archivedAt == archivedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,createdAt,updatedAt,title,id,type,const DeepCollectionEquality().hash(_tagsIds),archivedAt);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'ProjectModel.changelog(createdAt: $createdAt, updatedAt: $updatedAt, title: $title, id: $id, type: $type, tagsIds: $tagsIds, archivedAt: $archivedAt)';
}


}

/// @nodoc
abstract mixin class $ProjectModelChangelogCopyWith<$Res> implements $ProjectModelCopyWith<$Res> {
  factory $ProjectModelChangelogCopyWith(ProjectModelChangelog value, $Res Function(ProjectModelChangelog) _then) = _$ProjectModelChangelogCopyWithImpl;
@override @useResult
$Res call({
 DateTime createdAt, DateTime updatedAt, LocalizedTextModel title, ProjectModelId id, ProjectTypes type, List<ProjectTagModelId> tagsIds, DateTime? archivedAt
});


$LocalizedTextModelCopyWith<$Res> get title;

}
/// @nodoc
class _$ProjectModelChangelogCopyWithImpl<$Res>
    implements $ProjectModelChangelogCopyWith<$Res> {
  _$ProjectModelChangelogCopyWithImpl(this._self, this._then);

  final ProjectModelChangelog _self;
  final $Res Function(ProjectModelChangelog) _then;

/// Create a copy of ProjectModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? createdAt = null,Object? updatedAt = null,Object? title = null,Object? id = null,Object? type = null,Object? tagsIds = null,Object? archivedAt = freezed,}) {
  return _then(ProjectModelChangelog(
createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as LocalizedTextModel,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as ProjectModelId,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ProjectTypes,tagsIds: null == tagsIds ? _self._tagsIds : tagsIds // ignore: cast_nullable_to_non_nullable
as List<ProjectTagModelId>,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of ProjectModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocalizedTextModelCopyWith<$Res> get title {
  
  return $LocalizedTextModelCopyWith<$Res>(_self.title, (value) {
    return _then(_self.copyWith(title: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class ProjectModelDoc extends ProjectModel with DiagnosticableTreeMixin implements Archivable, Sharable {
  const ProjectModelDoc({required this.id, required this.createdAt, required this.updatedAt, this.formatId = '', this.title = '', this.type = ProjectTypes.doc,  List<ProjectTagModelId> tagsIds = const [], this.archivedAt,  List<DocBlockModel> blocks = const [], this.parentDocId, this.anchorSpan, this.spanSnapshot = '', this.agent, this.status = DocStatus.open,  String? $type}): _tagsIds = tagsIds,_blocks = blocks,$type = $type ?? 'doc',super._();
  factory ProjectModelDoc.fromJson(Map<String, dynamic> json) => _$ProjectModelDocFromJson(json);

@override final  ProjectModelId id;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
/// Format template id ([DocFormatIds] or custom). Empty = generic doc.
@JsonKey() final  String formatId;
@JsonKey() final  String title;
@override@JsonKey() final  ProjectTypes type;
 final  List<ProjectTagModelId> _tagsIds;
@override@JsonKey() List<ProjectTagModelId> get tagsIds {
  if (_tagsIds is EqualUnmodifiableListView) return _tagsIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tagsIds);
}

@override final  DateTime? archivedAt;
 final  List<DocBlockModel> _blocks;
@JsonKey() List<DocBlockModel> get blocks {
  if (_blocks is EqualUnmodifiableListView) return _blocks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_blocks);
}

/// Parent document when this node is a discussion opened on a span.
 final  ProjectModelId? parentDocId;
/// Span this node anchors to in [parentDocId].
 final  AnchorSpanModel? anchorSpan;
/// Snapshot of the anchored text at creation ("history note").
@JsonKey() final  String spanSnapshot;
/// Agent-doc payload (ADR 0003). Null for every other doc format.
 final  AgentDocModel? agent;
@JsonKey() final  DocStatus status;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of ProjectModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectModelDocCopyWith<ProjectModelDoc> get copyWith => _$ProjectModelDocCopyWithImpl<ProjectModelDoc>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProjectModelDocToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'ProjectModel.doc'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('createdAt', createdAt))..add(DiagnosticsProperty('updatedAt', updatedAt))..add(DiagnosticsProperty('formatId', formatId))..add(DiagnosticsProperty('title', title))..add(DiagnosticsProperty('type', type))..add(DiagnosticsProperty('tagsIds', tagsIds))..add(DiagnosticsProperty('archivedAt', archivedAt))..add(DiagnosticsProperty('blocks', blocks))..add(DiagnosticsProperty('parentDocId', parentDocId))..add(DiagnosticsProperty('anchorSpan', anchorSpan))..add(DiagnosticsProperty('spanSnapshot', spanSnapshot))..add(DiagnosticsProperty('agent', agent))..add(DiagnosticsProperty('status', status));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectModelDoc&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.formatId, formatId) || other.formatId == formatId)&&(identical(other.title, title) || other.title == title)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other._tagsIds, _tagsIds)&&(identical(other.archivedAt, archivedAt) || other.archivedAt == archivedAt)&&const DeepCollectionEquality().equals(other._blocks, _blocks)&&(identical(other.parentDocId, parentDocId) || other.parentDocId == parentDocId)&&(identical(other.anchorSpan, anchorSpan) || other.anchorSpan == anchorSpan)&&(identical(other.spanSnapshot, spanSnapshot) || other.spanSnapshot == spanSnapshot)&&(identical(other.agent, agent) || other.agent == agent)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createdAt,updatedAt,formatId,title,type,const DeepCollectionEquality().hash(_tagsIds),archivedAt,const DeepCollectionEquality().hash(_blocks),parentDocId,anchorSpan,spanSnapshot,agent,status);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'ProjectModel.doc(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, formatId: $formatId, title: $title, type: $type, tagsIds: $tagsIds, archivedAt: $archivedAt, blocks: $blocks, parentDocId: $parentDocId, anchorSpan: $anchorSpan, spanSnapshot: $spanSnapshot, agent: $agent, status: $status)';
}


}

/// @nodoc
abstract mixin class $ProjectModelDocCopyWith<$Res> implements $ProjectModelCopyWith<$Res> {
  factory $ProjectModelDocCopyWith(ProjectModelDoc value, $Res Function(ProjectModelDoc) _then) = _$ProjectModelDocCopyWithImpl;
@override @useResult
$Res call({
 ProjectModelId id, DateTime createdAt, DateTime updatedAt, String formatId, String title, ProjectTypes type, List<ProjectTagModelId> tagsIds, DateTime? archivedAt, List<DocBlockModel> blocks, ProjectModelId? parentDocId, AnchorSpanModel? anchorSpan, String spanSnapshot, AgentDocModel? agent, DocStatus status
});


$AnchorSpanModelCopyWith<$Res>? get anchorSpan;$AgentDocModelCopyWith<$Res>? get agent;

}
/// @nodoc
class _$ProjectModelDocCopyWithImpl<$Res>
    implements $ProjectModelDocCopyWith<$Res> {
  _$ProjectModelDocCopyWithImpl(this._self, this._then);

  final ProjectModelDoc _self;
  final $Res Function(ProjectModelDoc) _then;

/// Create a copy of ProjectModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? createdAt = null,Object? updatedAt = null,Object? formatId = null,Object? title = null,Object? type = null,Object? tagsIds = null,Object? archivedAt = freezed,Object? blocks = null,Object? parentDocId = freezed,Object? anchorSpan = freezed,Object? spanSnapshot = null,Object? agent = freezed,Object? status = null,}) {
  return _then(ProjectModelDoc(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as ProjectModelId,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,formatId: null == formatId ? _self.formatId : formatId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ProjectTypes,tagsIds: null == tagsIds ? _self._tagsIds : tagsIds // ignore: cast_nullable_to_non_nullable
as List<ProjectTagModelId>,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,blocks: null == blocks ? _self._blocks : blocks // ignore: cast_nullable_to_non_nullable
as List<DocBlockModel>,parentDocId: freezed == parentDocId ? _self.parentDocId : parentDocId // ignore: cast_nullable_to_non_nullable
as ProjectModelId?,anchorSpan: freezed == anchorSpan ? _self.anchorSpan : anchorSpan // ignore: cast_nullable_to_non_nullable
as AnchorSpanModel?,spanSnapshot: null == spanSnapshot ? _self.spanSnapshot : spanSnapshot // ignore: cast_nullable_to_non_nullable
as String,agent: freezed == agent ? _self.agent : agent // ignore: cast_nullable_to_non_nullable
as AgentDocModel?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DocStatus,
  ));
}

/// Create a copy of ProjectModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnchorSpanModelCopyWith<$Res>? get anchorSpan {
    if (_self.anchorSpan == null) {
    return null;
  }

  return $AnchorSpanModelCopyWith<$Res>(_self.anchorSpan!, (value) {
    return _then(_self.copyWith(anchorSpan: value));
  });
}/// Create a copy of ProjectModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AgentDocModelCopyWith<$Res>? get agent {
    if (_self.agent == null) {
    return null;
  }

  return $AgentDocModelCopyWith<$Res>(_self.agent!, (value) {
    return _then(_self.copyWith(agent: value));
  });
}
}


/// @nodoc
mixin _$IdeaProjectAnswerModel implements DiagnosticableTreeMixin {

 IdeaProjectAnswerModelId get id; DateTime get createdAt; IdeaProjectQuestionModel get question; String get text;
/// Create a copy of IdeaProjectAnswerModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IdeaProjectAnswerModelCopyWith<IdeaProjectAnswerModel> get copyWith => _$IdeaProjectAnswerModelCopyWithImpl<IdeaProjectAnswerModel>(this as IdeaProjectAnswerModel, _$identity);

  /// Serializes this IdeaProjectAnswerModel to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'IdeaProjectAnswerModel'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('createdAt', createdAt))..add(DiagnosticsProperty('question', question))..add(DiagnosticsProperty('text', text));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IdeaProjectAnswerModel&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.question, question) || other.question == question)&&(identical(other.text, text) || other.text == text));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createdAt,question,text);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'IdeaProjectAnswerModel(id: $id, createdAt: $createdAt, question: $question, text: $text)';
}


}

/// @nodoc
abstract mixin class $IdeaProjectAnswerModelCopyWith<$Res>  {
  factory $IdeaProjectAnswerModelCopyWith(IdeaProjectAnswerModel value, $Res Function(IdeaProjectAnswerModel) _then) = _$IdeaProjectAnswerModelCopyWithImpl;
@useResult
$Res call({
 IdeaProjectAnswerModelId id, DateTime createdAt, IdeaProjectQuestionModel question, String text
});


$IdeaProjectQuestionModelCopyWith<$Res> get question;

}
/// @nodoc
class _$IdeaProjectAnswerModelCopyWithImpl<$Res>
    implements $IdeaProjectAnswerModelCopyWith<$Res> {
  _$IdeaProjectAnswerModelCopyWithImpl(this._self, this._then);

  final IdeaProjectAnswerModel _self;
  final $Res Function(IdeaProjectAnswerModel) _then;

/// Create a copy of IdeaProjectAnswerModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? createdAt = null,Object? question = null,Object? text = null,}) {
  return _then(IdeaProjectAnswerModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as IdeaProjectAnswerModelId,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as IdeaProjectQuestionModel,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of IdeaProjectAnswerModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IdeaProjectQuestionModelCopyWith<$Res> get question {
  
  return $IdeaProjectQuestionModelCopyWith<$Res>(_self.question, (value) {
    return _then(_self.copyWith(question: value));
  });
}
}


/// Adds pattern-matching-related methods to [IdeaProjectAnswerModel].
extension IdeaProjectAnswerModelPatterns on IdeaProjectAnswerModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IdeaProjectAnswerModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IdeaProjectAnswerModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IdeaProjectAnswerModel value)  $default,){
final _that = this;
switch (_that) {
case _IdeaProjectAnswerModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IdeaProjectAnswerModel value)?  $default,){
final _that = this;
switch (_that) {
case _IdeaProjectAnswerModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( IdeaProjectAnswerModelId id,  DateTime createdAt,  IdeaProjectQuestionModel question,  String text)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IdeaProjectAnswerModel() when $default != null:
return $default(_that.id,_that.createdAt,_that.question,_that.text);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( IdeaProjectAnswerModelId id,  DateTime createdAt,  IdeaProjectQuestionModel question,  String text)  $default,) {final _that = this;
switch (_that) {
case _IdeaProjectAnswerModel():
return $default(_that.id,_that.createdAt,_that.question,_that.text);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( IdeaProjectAnswerModelId id,  DateTime createdAt,  IdeaProjectQuestionModel question,  String text)?  $default,) {final _that = this;
switch (_that) {
case _IdeaProjectAnswerModel() when $default != null:
return $default(_that.id,_that.createdAt,_that.question,_that.text);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IdeaProjectAnswerModel extends IdeaProjectAnswerModel with DiagnosticableTreeMixin {
  const _IdeaProjectAnswerModel({required this.id, required this.createdAt, required this.question, this.text = ''}): super._();
  factory _IdeaProjectAnswerModel.fromJson(Map<String, dynamic> json) => _$IdeaProjectAnswerModelFromJson(json);

@override final  IdeaProjectAnswerModelId id;
@override final  DateTime createdAt;
@override final  IdeaProjectQuestionModel question;
@override@JsonKey() final  String text;

/// Create a copy of IdeaProjectAnswerModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IdeaProjectAnswerModelCopyWith<_IdeaProjectAnswerModel> get copyWith => __$IdeaProjectAnswerModelCopyWithImpl<_IdeaProjectAnswerModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IdeaProjectAnswerModelToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'IdeaProjectAnswerModel'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('createdAt', createdAt))..add(DiagnosticsProperty('question', question))..add(DiagnosticsProperty('text', text));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IdeaProjectAnswerModel&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.question, question) || other.question == question)&&(identical(other.text, text) || other.text == text));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createdAt,question,text);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'IdeaProjectAnswerModel(id: $id, createdAt: $createdAt, question: $question, text: $text)';
}


}

/// @nodoc
abstract mixin class _$IdeaProjectAnswerModelCopyWith<$Res> implements $IdeaProjectAnswerModelCopyWith<$Res> {
  factory _$IdeaProjectAnswerModelCopyWith(_IdeaProjectAnswerModel value, $Res Function(_IdeaProjectAnswerModel) _then) = __$IdeaProjectAnswerModelCopyWithImpl;
@override @useResult
$Res call({
 IdeaProjectAnswerModelId id, DateTime createdAt, IdeaProjectQuestionModel question, String text
});


@override $IdeaProjectQuestionModelCopyWith<$Res> get question;

}
/// @nodoc
class __$IdeaProjectAnswerModelCopyWithImpl<$Res>
    implements _$IdeaProjectAnswerModelCopyWith<$Res> {
  __$IdeaProjectAnswerModelCopyWithImpl(this._self, this._then);

  final _IdeaProjectAnswerModel _self;
  final $Res Function(_IdeaProjectAnswerModel) _then;

/// Create a copy of IdeaProjectAnswerModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? createdAt = null,Object? question = null,Object? text = null,}) {
  return _then(_IdeaProjectAnswerModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as IdeaProjectAnswerModelId,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as IdeaProjectQuestionModel,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of IdeaProjectAnswerModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IdeaProjectQuestionModelCopyWith<$Res> get question {
  
  return $IdeaProjectQuestionModelCopyWith<$Res>(_self.question, (value) {
    return _then(_self.copyWith(question: value));
  });
}
}


/// @nodoc
mixin _$IdeaProjectQuestionModel implements DiagnosticableTreeMixin {

 IdeaProjectQuestionModelId get id; LocalizedTextModel get title;
/// Create a copy of IdeaProjectQuestionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IdeaProjectQuestionModelCopyWith<IdeaProjectQuestionModel> get copyWith => _$IdeaProjectQuestionModelCopyWithImpl<IdeaProjectQuestionModel>(this as IdeaProjectQuestionModel, _$identity);

  /// Serializes this IdeaProjectQuestionModel to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'IdeaProjectQuestionModel'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('title', title));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IdeaProjectQuestionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'IdeaProjectQuestionModel(id: $id, title: $title)';
}


}

/// @nodoc
abstract mixin class $IdeaProjectQuestionModelCopyWith<$Res>  {
  factory $IdeaProjectQuestionModelCopyWith(IdeaProjectQuestionModel value, $Res Function(IdeaProjectQuestionModel) _then) = _$IdeaProjectQuestionModelCopyWithImpl;
@useResult
$Res call({
 IdeaProjectQuestionModelId id, LocalizedTextModel title
});


$LocalizedTextModelCopyWith<$Res> get title;

}
/// @nodoc
class _$IdeaProjectQuestionModelCopyWithImpl<$Res>
    implements $IdeaProjectQuestionModelCopyWith<$Res> {
  _$IdeaProjectQuestionModelCopyWithImpl(this._self, this._then);

  final IdeaProjectQuestionModel _self;
  final $Res Function(IdeaProjectQuestionModel) _then;

/// Create a copy of IdeaProjectQuestionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,}) {
  return _then(IdeaProjectQuestionModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as IdeaProjectQuestionModelId,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as LocalizedTextModel,
  ));
}
/// Create a copy of IdeaProjectQuestionModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocalizedTextModelCopyWith<$Res> get title {
  
  return $LocalizedTextModelCopyWith<$Res>(_self.title, (value) {
    return _then(_self.copyWith(title: value));
  });
}
}


/// Adds pattern-matching-related methods to [IdeaProjectQuestionModel].
extension IdeaProjectQuestionModelPatterns on IdeaProjectQuestionModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IdeaProjectQuestionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IdeaProjectQuestionModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IdeaProjectQuestionModel value)  $default,){
final _that = this;
switch (_that) {
case _IdeaProjectQuestionModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IdeaProjectQuestionModel value)?  $default,){
final _that = this;
switch (_that) {
case _IdeaProjectQuestionModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( IdeaProjectQuestionModelId id,  LocalizedTextModel title)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IdeaProjectQuestionModel() when $default != null:
return $default(_that.id,_that.title);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( IdeaProjectQuestionModelId id,  LocalizedTextModel title)  $default,) {final _that = this;
switch (_that) {
case _IdeaProjectQuestionModel():
return $default(_that.id,_that.title);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( IdeaProjectQuestionModelId id,  LocalizedTextModel title)?  $default,) {final _that = this;
switch (_that) {
case _IdeaProjectQuestionModel() when $default != null:
return $default(_that.id,_that.title);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IdeaProjectQuestionModel extends IdeaProjectQuestionModel with DiagnosticableTreeMixin {
  const _IdeaProjectQuestionModel({required this.id, required this.title}): super._();
  factory _IdeaProjectQuestionModel.fromJson(Map<String, dynamic> json) => _$IdeaProjectQuestionModelFromJson(json);

@override final  IdeaProjectQuestionModelId id;
@override final  LocalizedTextModel title;

/// Create a copy of IdeaProjectQuestionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IdeaProjectQuestionModelCopyWith<_IdeaProjectQuestionModel> get copyWith => __$IdeaProjectQuestionModelCopyWithImpl<_IdeaProjectQuestionModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IdeaProjectQuestionModelToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'IdeaProjectQuestionModel'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('title', title));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IdeaProjectQuestionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'IdeaProjectQuestionModel(id: $id, title: $title)';
}


}

/// @nodoc
abstract mixin class _$IdeaProjectQuestionModelCopyWith<$Res> implements $IdeaProjectQuestionModelCopyWith<$Res> {
  factory _$IdeaProjectQuestionModelCopyWith(_IdeaProjectQuestionModel value, $Res Function(_IdeaProjectQuestionModel) _then) = __$IdeaProjectQuestionModelCopyWithImpl;
@override @useResult
$Res call({
 IdeaProjectQuestionModelId id, LocalizedTextModel title
});


@override $LocalizedTextModelCopyWith<$Res> get title;

}
/// @nodoc
class __$IdeaProjectQuestionModelCopyWithImpl<$Res>
    implements _$IdeaProjectQuestionModelCopyWith<$Res> {
  __$IdeaProjectQuestionModelCopyWithImpl(this._self, this._then);

  final _IdeaProjectQuestionModel _self;
  final $Res Function(_IdeaProjectQuestionModel) _then;

/// Create a copy of IdeaProjectQuestionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,}) {
  return _then(_IdeaProjectQuestionModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as IdeaProjectQuestionModelId,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as LocalizedTextModel,
  ));
}

/// Create a copy of IdeaProjectQuestionModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocalizedTextModelCopyWith<$Res> get title {
  
  return $LocalizedTextModelCopyWith<$Res>(_self.title, (value) {
    return _then(_self.copyWith(title: value));
  });
}
}


/// @nodoc
mixin _$LocalizedTextModel implements DiagnosticableTreeMixin {

 String get ru; String get en; String get it; String get ga;
/// Create a copy of LocalizedTextModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocalizedTextModelCopyWith<LocalizedTextModel> get copyWith => _$LocalizedTextModelCopyWithImpl<LocalizedTextModel>(this as LocalizedTextModel, _$identity);

  /// Serializes this LocalizedTextModel to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'LocalizedTextModel'))
    ..add(DiagnosticsProperty('ru', ru))..add(DiagnosticsProperty('en', en))..add(DiagnosticsProperty('it', it))..add(DiagnosticsProperty('ga', ga));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocalizedTextModel&&(identical(other.ru, ru) || other.ru == ru)&&(identical(other.en, en) || other.en == en)&&(identical(other.it, it) || other.it == it)&&(identical(other.ga, ga) || other.ga == ga));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ru,en,it,ga);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'LocalizedTextModel(ru: $ru, en: $en, it: $it, ga: $ga)';
}


}

/// @nodoc
abstract mixin class $LocalizedTextModelCopyWith<$Res>  {
  factory $LocalizedTextModelCopyWith(LocalizedTextModel value, $Res Function(LocalizedTextModel) _then) = _$LocalizedTextModelCopyWithImpl;
@useResult
$Res call({
 String ru, String en, String it, String ga
});




}
/// @nodoc
class _$LocalizedTextModelCopyWithImpl<$Res>
    implements $LocalizedTextModelCopyWith<$Res> {
  _$LocalizedTextModelCopyWithImpl(this._self, this._then);

  final LocalizedTextModel _self;
  final $Res Function(LocalizedTextModel) _then;

/// Create a copy of LocalizedTextModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ru = null,Object? en = null,Object? it = null,Object? ga = null,}) {
  return _then(LocalizedTextModel(
ru: null == ru ? _self.ru : ru // ignore: cast_nullable_to_non_nullable
as String,en: null == en ? _self.en : en // ignore: cast_nullable_to_non_nullable
as String,it: null == it ? _self.it : it // ignore: cast_nullable_to_non_nullable
as String,ga: null == ga ? _self.ga : ga // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LocalizedTextModel].
extension LocalizedTextModelPatterns on LocalizedTextModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LocalizedTextModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LocalizedTextModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LocalizedTextModel value)  $default,){
final _that = this;
switch (_that) {
case _LocalizedTextModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LocalizedTextModel value)?  $default,){
final _that = this;
switch (_that) {
case _LocalizedTextModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String ru,  String en,  String it,  String ga)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LocalizedTextModel() when $default != null:
return $default(_that.ru,_that.en,_that.it,_that.ga);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String ru,  String en,  String it,  String ga)  $default,) {final _that = this;
switch (_that) {
case _LocalizedTextModel():
return $default(_that.ru,_that.en,_that.it,_that.ga);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String ru,  String en,  String it,  String ga)?  $default,) {final _that = this;
switch (_that) {
case _LocalizedTextModel() when $default != null:
return $default(_that.ru,_that.en,_that.it,_that.ga);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LocalizedTextModel extends LocalizedTextModel with DiagnosticableTreeMixin {
  const _LocalizedTextModel({required this.ru, this.en = '', this.it = '', this.ga = ''}): super._();
  factory _LocalizedTextModel.fromJson(Map<String, dynamic> json) => _$LocalizedTextModelFromJson(json);

@override final  String ru;
@override@JsonKey() final  String en;
@override@JsonKey() final  String it;
@override@JsonKey() final  String ga;

/// Create a copy of LocalizedTextModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocalizedTextModelCopyWith<_LocalizedTextModel> get copyWith => __$LocalizedTextModelCopyWithImpl<_LocalizedTextModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LocalizedTextModelToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'LocalizedTextModel'))
    ..add(DiagnosticsProperty('ru', ru))..add(DiagnosticsProperty('en', en))..add(DiagnosticsProperty('it', it))..add(DiagnosticsProperty('ga', ga));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LocalizedTextModel&&(identical(other.ru, ru) || other.ru == ru)&&(identical(other.en, en) || other.en == en)&&(identical(other.it, it) || other.it == it)&&(identical(other.ga, ga) || other.ga == ga));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ru,en,it,ga);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'LocalizedTextModel(ru: $ru, en: $en, it: $it, ga: $ga)';
}


}

/// @nodoc
abstract mixin class _$LocalizedTextModelCopyWith<$Res> implements $LocalizedTextModelCopyWith<$Res> {
  factory _$LocalizedTextModelCopyWith(_LocalizedTextModel value, $Res Function(_LocalizedTextModel) _then) = __$LocalizedTextModelCopyWithImpl;
@override @useResult
$Res call({
 String ru, String en, String it, String ga
});




}
/// @nodoc
class __$LocalizedTextModelCopyWithImpl<$Res>
    implements _$LocalizedTextModelCopyWith<$Res> {
  __$LocalizedTextModelCopyWithImpl(this._self, this._then);

  final _LocalizedTextModel _self;
  final $Res Function(_LocalizedTextModel) _then;

/// Create a copy of LocalizedTextModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ru = null,Object? en = null,Object? it = null,Object? ga = null,}) {
  return _then(_LocalizedTextModel(
ru: null == ru ? _self.ru : ru // ignore: cast_nullable_to_non_nullable
as String,en: null == en ? _self.en : en // ignore: cast_nullable_to_non_nullable
as String,it: null == it ? _self.it : it // ignore: cast_nullable_to_non_nullable
as String,ga: null == ga ? _self.ga : ga // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ProjectTagModel implements DiagnosticableTreeMixin {

 ProjectTagModelId get id; String get title;
/// Create a copy of ProjectTagModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectTagModelCopyWith<ProjectTagModel> get copyWith => _$ProjectTagModelCopyWithImpl<ProjectTagModel>(this as ProjectTagModel, _$identity);

  /// Serializes this ProjectTagModel to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'ProjectTagModel'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('title', title));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectTagModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'ProjectTagModel(id: $id, title: $title)';
}


}

/// @nodoc
abstract mixin class $ProjectTagModelCopyWith<$Res>  {
  factory $ProjectTagModelCopyWith(ProjectTagModel value, $Res Function(ProjectTagModel) _then) = _$ProjectTagModelCopyWithImpl;
@useResult
$Res call({
 ProjectTagModelId id, String title
});




}
/// @nodoc
class _$ProjectTagModelCopyWithImpl<$Res>
    implements $ProjectTagModelCopyWith<$Res> {
  _$ProjectTagModelCopyWithImpl(this._self, this._then);

  final ProjectTagModel _self;
  final $Res Function(ProjectTagModel) _then;

/// Create a copy of ProjectTagModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,}) {
  return _then(ProjectTagModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as ProjectTagModelId,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ProjectTagModel].
extension ProjectTagModelPatterns on ProjectTagModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProjectTagModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProjectTagModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProjectTagModel value)  $default,){
final _that = this;
switch (_that) {
case _ProjectTagModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProjectTagModel value)?  $default,){
final _that = this;
switch (_that) {
case _ProjectTagModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ProjectTagModelId id,  String title)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProjectTagModel() when $default != null:
return $default(_that.id,_that.title);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ProjectTagModelId id,  String title)  $default,) {final _that = this;
switch (_that) {
case _ProjectTagModel():
return $default(_that.id,_that.title);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ProjectTagModelId id,  String title)?  $default,) {final _that = this;
switch (_that) {
case _ProjectTagModel() when $default != null:
return $default(_that.id,_that.title);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProjectTagModel extends ProjectTagModel with DiagnosticableTreeMixin {
  const _ProjectTagModel({required this.id, this.title = ''}): super._();
  factory _ProjectTagModel.fromJson(Map<String, dynamic> json) => _$ProjectTagModelFromJson(json);

@override final  ProjectTagModelId id;
@override@JsonKey() final  String title;

/// Create a copy of ProjectTagModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProjectTagModelCopyWith<_ProjectTagModel> get copyWith => __$ProjectTagModelCopyWithImpl<_ProjectTagModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProjectTagModelToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'ProjectTagModel'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('title', title));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProjectTagModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'ProjectTagModel(id: $id, title: $title)';
}


}

/// @nodoc
abstract mixin class _$ProjectTagModelCopyWith<$Res> implements $ProjectTagModelCopyWith<$Res> {
  factory _$ProjectTagModelCopyWith(_ProjectTagModel value, $Res Function(_ProjectTagModel) _then) = __$ProjectTagModelCopyWithImpl;
@override @useResult
$Res call({
 ProjectTagModelId id, String title
});




}
/// @nodoc
class __$ProjectTagModelCopyWithImpl<$Res>
    implements _$ProjectTagModelCopyWith<$Res> {
  __$ProjectTagModelCopyWithImpl(this._self, this._then);

  final _ProjectTagModel _self;
  final $Res Function(_ProjectTagModel) _then;

/// Create a copy of ProjectTagModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,}) {
  return _then(_ProjectTagModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as ProjectTagModelId,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$DbSaveModel implements DiagnosticableTreeMixin {

 DbSaveVersion get version; List<ProjectModel> get projects; List<ProjectTagModel> get tags;
/// Create a copy of DbSaveModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DbSaveModelCopyWith<DbSaveModel> get copyWith => _$DbSaveModelCopyWithImpl<DbSaveModel>(this as DbSaveModel, _$identity);

  /// Serializes this DbSaveModel to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'DbSaveModel'))
    ..add(DiagnosticsProperty('version', version))..add(DiagnosticsProperty('projects', projects))..add(DiagnosticsProperty('tags', tags));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DbSaveModel&&(identical(other.version, version) || other.version == version)&&const DeepCollectionEquality().equals(other.projects, projects)&&const DeepCollectionEquality().equals(other.tags, tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version,const DeepCollectionEquality().hash(projects),const DeepCollectionEquality().hash(tags));

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'DbSaveModel(version: $version, projects: $projects, tags: $tags)';
}


}

/// @nodoc
abstract mixin class $DbSaveModelCopyWith<$Res>  {
  factory $DbSaveModelCopyWith(DbSaveModel value, $Res Function(DbSaveModel) _then) = _$DbSaveModelCopyWithImpl;
@useResult
$Res call({
 DbSaveVersion version, List<ProjectModel> projects, List<ProjectTagModel> tags
});




}
/// @nodoc
class _$DbSaveModelCopyWithImpl<$Res>
    implements $DbSaveModelCopyWith<$Res> {
  _$DbSaveModelCopyWithImpl(this._self, this._then);

  final DbSaveModel _self;
  final $Res Function(DbSaveModel) _then;

/// Create a copy of DbSaveModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? version = null,Object? projects = null,Object? tags = null,}) {
  return _then(DbSaveModel(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as DbSaveVersion,projects: null == projects ? _self.projects : projects // ignore: cast_nullable_to_non_nullable
as List<ProjectModel>,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<ProjectTagModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [DbSaveModel].
extension DbSaveModelPatterns on DbSaveModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DbSaveModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DbSaveModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DbSaveModel value)  $default,){
final _that = this;
switch (_that) {
case _DbSaveModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DbSaveModel value)?  $default,){
final _that = this;
switch (_that) {
case _DbSaveModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DbSaveVersion version,  List<ProjectModel> projects,  List<ProjectTagModel> tags)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DbSaveModel() when $default != null:
return $default(_that.version,_that.projects,_that.tags);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DbSaveVersion version,  List<ProjectModel> projects,  List<ProjectTagModel> tags)  $default,) {final _that = this;
switch (_that) {
case _DbSaveModel():
return $default(_that.version,_that.projects,_that.tags);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DbSaveVersion version,  List<ProjectModel> projects,  List<ProjectTagModel> tags)?  $default,) {final _that = this;
switch (_that) {
case _DbSaveModel() when $default != null:
return $default(_that.version,_that.projects,_that.tags);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DbSaveModel extends DbSaveModel with DiagnosticableTreeMixin {
  const _DbSaveModel({this.version = DbSaveVersion.v1,  List<ProjectModel> projects = const [],  List<ProjectTagModel> tags = const []}): _projects = projects,_tags = tags,super._();
  factory _DbSaveModel.fromJson(Map<String, dynamic> json) => _$DbSaveModelFromJson(json);

@override@JsonKey() final  DbSaveVersion version;
 final  List<ProjectModel> _projects;
@override@JsonKey() List<ProjectModel> get projects {
  if (_projects is EqualUnmodifiableListView) return _projects;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_projects);
}

 final  List<ProjectTagModel> _tags;
@override@JsonKey() List<ProjectTagModel> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}


/// Create a copy of DbSaveModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DbSaveModelCopyWith<_DbSaveModel> get copyWith => __$DbSaveModelCopyWithImpl<_DbSaveModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DbSaveModelToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'DbSaveModel'))
    ..add(DiagnosticsProperty('version', version))..add(DiagnosticsProperty('projects', projects))..add(DiagnosticsProperty('tags', tags));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DbSaveModel&&(identical(other.version, version) || other.version == version)&&const DeepCollectionEquality().equals(other._projects, _projects)&&const DeepCollectionEquality().equals(other._tags, _tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version,const DeepCollectionEquality().hash(_projects),const DeepCollectionEquality().hash(_tags));

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'DbSaveModel(version: $version, projects: $projects, tags: $tags)';
}


}

/// @nodoc
abstract mixin class _$DbSaveModelCopyWith<$Res> implements $DbSaveModelCopyWith<$Res> {
  factory _$DbSaveModelCopyWith(_DbSaveModel value, $Res Function(_DbSaveModel) _then) = __$DbSaveModelCopyWithImpl;
@override @useResult
$Res call({
 DbSaveVersion version, List<ProjectModel> projects, List<ProjectTagModel> tags
});




}
/// @nodoc
class __$DbSaveModelCopyWithImpl<$Res>
    implements _$DbSaveModelCopyWith<$Res> {
  __$DbSaveModelCopyWithImpl(this._self, this._then);

  final _DbSaveModel _self;
  final $Res Function(_DbSaveModel) _then;

/// Create a copy of DbSaveModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? version = null,Object? projects = null,Object? tags = null,}) {
  return _then(_DbSaveModel(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as DbSaveVersion,projects: null == projects ? _self._projects : projects // ignore: cast_nullable_to_non_nullable
as List<ProjectModel>,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<ProjectTagModel>,
  ));
}


}

// dart format on
