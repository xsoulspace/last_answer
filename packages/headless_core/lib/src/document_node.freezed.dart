// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document_node.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Block {

 NodeId get id; BlockType get type; String get content;/// Heading level for [BlockType.heading]; list nesting for lists.
 int? get level;
/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BlockCopyWith<Block> get copyWith => _$BlockCopyWithImpl<Block>(this as Block, _$identity);

  /// Serializes this Block to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Block&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.content, content) || other.content == content)&&(identical(other.level, level) || other.level == level));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,content,level);

@override
String toString() {
  return 'Block(id: $id, type: $type, content: $content, level: $level)';
}


}

/// @nodoc
abstract mixin class $BlockCopyWith<$Res>  {
  factory $BlockCopyWith(Block value, $Res Function(Block) _then) = _$BlockCopyWithImpl;
@useResult
$Res call({
 NodeId id, BlockType type, String content, int? level
});




}
/// @nodoc
class _$BlockCopyWithImpl<$Res>
    implements $BlockCopyWith<$Res> {
  _$BlockCopyWithImpl(this._self, this._then);

  final Block _self;
  final $Res Function(Block) _then;

/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? content = null,Object? level = freezed,}) {
  return _then(Block(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as NodeId,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as BlockType,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,level: freezed == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [Block].
extension BlockPatterns on Block {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Block value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Block() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Block value)  $default,){
final _that = this;
switch (_that) {
case _Block():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Block value)?  $default,){
final _that = this;
switch (_that) {
case _Block() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( NodeId id,  BlockType type,  String content,  int? level)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Block() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( NodeId id,  BlockType type,  String content,  int? level)  $default,) {final _that = this;
switch (_that) {
case _Block():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( NodeId id,  BlockType type,  String content,  int? level)?  $default,) {final _that = this;
switch (_that) {
case _Block() when $default != null:
return $default(_that.id,_that.type,_that.content,_that.level);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Block implements Block {
  const _Block({required this.id, required this.type, this.content = '', this.level});
  factory _Block.fromJson(Map<String, dynamic> json) => _$BlockFromJson(json);

@override final  NodeId id;
@override final  BlockType type;
@override@JsonKey() final  String content;
/// Heading level for [BlockType.heading]; list nesting for lists.
@override final  int? level;

/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BlockCopyWith<_Block> get copyWith => __$BlockCopyWithImpl<_Block>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BlockToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Block&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.content, content) || other.content == content)&&(identical(other.level, level) || other.level == level));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,content,level);

@override
String toString() {
  return 'Block(id: $id, type: $type, content: $content, level: $level)';
}


}

/// @nodoc
abstract mixin class _$BlockCopyWith<$Res> implements $BlockCopyWith<$Res> {
  factory _$BlockCopyWith(_Block value, $Res Function(_Block) _then) = __$BlockCopyWithImpl;
@override @useResult
$Res call({
 NodeId id, BlockType type, String content, int? level
});




}
/// @nodoc
class __$BlockCopyWithImpl<$Res>
    implements _$BlockCopyWith<$Res> {
  __$BlockCopyWithImpl(this._self, this._then);

  final _Block _self;
  final $Res Function(_Block) _then;

/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? content = null,Object? level = freezed,}) {
  return _then(_Block(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as NodeId,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as BlockType,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,level: freezed == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$AnchorSpan {

 NodeId get blockId; String? get prefixHash; String? get suffixHash;
/// Create a copy of AnchorSpan
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnchorSpanCopyWith<AnchorSpan> get copyWith => _$AnchorSpanCopyWithImpl<AnchorSpan>(this as AnchorSpan, _$identity);

  /// Serializes this AnchorSpan to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnchorSpan&&(identical(other.blockId, blockId) || other.blockId == blockId)&&(identical(other.prefixHash, prefixHash) || other.prefixHash == prefixHash)&&(identical(other.suffixHash, suffixHash) || other.suffixHash == suffixHash));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,blockId,prefixHash,suffixHash);

@override
String toString() {
  return 'AnchorSpan(blockId: $blockId, prefixHash: $prefixHash, suffixHash: $suffixHash)';
}


}

/// @nodoc
abstract mixin class $AnchorSpanCopyWith<$Res>  {
  factory $AnchorSpanCopyWith(AnchorSpan value, $Res Function(AnchorSpan) _then) = _$AnchorSpanCopyWithImpl;
@useResult
$Res call({
 NodeId blockId, String? prefixHash, String? suffixHash
});




}
/// @nodoc
class _$AnchorSpanCopyWithImpl<$Res>
    implements $AnchorSpanCopyWith<$Res> {
  _$AnchorSpanCopyWithImpl(this._self, this._then);

  final AnchorSpan _self;
  final $Res Function(AnchorSpan) _then;

/// Create a copy of AnchorSpan
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? blockId = null,Object? prefixHash = freezed,Object? suffixHash = freezed,}) {
  return _then(AnchorSpan(
blockId: null == blockId ? _self.blockId : blockId // ignore: cast_nullable_to_non_nullable
as NodeId,prefixHash: freezed == prefixHash ? _self.prefixHash : prefixHash // ignore: cast_nullable_to_non_nullable
as String?,suffixHash: freezed == suffixHash ? _self.suffixHash : suffixHash // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AnchorSpan].
extension AnchorSpanPatterns on AnchorSpan {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnchorSpan value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnchorSpan() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnchorSpan value)  $default,){
final _that = this;
switch (_that) {
case _AnchorSpan():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnchorSpan value)?  $default,){
final _that = this;
switch (_that) {
case _AnchorSpan() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( NodeId blockId,  String? prefixHash,  String? suffixHash)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnchorSpan() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( NodeId blockId,  String? prefixHash,  String? suffixHash)  $default,) {final _that = this;
switch (_that) {
case _AnchorSpan():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( NodeId blockId,  String? prefixHash,  String? suffixHash)?  $default,) {final _that = this;
switch (_that) {
case _AnchorSpan() when $default != null:
return $default(_that.blockId,_that.prefixHash,_that.suffixHash);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AnchorSpan implements AnchorSpan {
  const _AnchorSpan({required this.blockId, this.prefixHash, this.suffixHash});
  factory _AnchorSpan.fromJson(Map<String, dynamic> json) => _$AnchorSpanFromJson(json);

@override final  NodeId blockId;
@override final  String? prefixHash;
@override final  String? suffixHash;

/// Create a copy of AnchorSpan
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnchorSpanCopyWith<_AnchorSpan> get copyWith => __$AnchorSpanCopyWithImpl<_AnchorSpan>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnchorSpanToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnchorSpan&&(identical(other.blockId, blockId) || other.blockId == blockId)&&(identical(other.prefixHash, prefixHash) || other.prefixHash == prefixHash)&&(identical(other.suffixHash, suffixHash) || other.suffixHash == suffixHash));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,blockId,prefixHash,suffixHash);

@override
String toString() {
  return 'AnchorSpan(blockId: $blockId, prefixHash: $prefixHash, suffixHash: $suffixHash)';
}


}

/// @nodoc
abstract mixin class _$AnchorSpanCopyWith<$Res> implements $AnchorSpanCopyWith<$Res> {
  factory _$AnchorSpanCopyWith(_AnchorSpan value, $Res Function(_AnchorSpan) _then) = __$AnchorSpanCopyWithImpl;
@override @useResult
$Res call({
 NodeId blockId, String? prefixHash, String? suffixHash
});




}
/// @nodoc
class __$AnchorSpanCopyWithImpl<$Res>
    implements _$AnchorSpanCopyWith<$Res> {
  __$AnchorSpanCopyWithImpl(this._self, this._then);

  final _AnchorSpan _self;
  final $Res Function(_AnchorSpan) _then;

/// Create a copy of AnchorSpan
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? blockId = null,Object? prefixHash = freezed,Object? suffixHash = freezed,}) {
  return _then(_AnchorSpan(
blockId: null == blockId ? _self.blockId : blockId // ignore: cast_nullable_to_non_nullable
as NodeId,prefixHash: freezed == prefixHash ? _self.prefixHash : prefixHash // ignore: cast_nullable_to_non_nullable
as String?,suffixHash: freezed == suffixHash ? _self.suffixHash : suffixHash // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$DocumentNode {

 NodeId get id;/// Only 'doc' today; extensible later without model changes.
 String get kind;/// Replaces sealed format enums: 'gdd', 'prd', or any template id.
/// Null = unformatted doc.
 String? get formatId; List<Block> get blocks;/// Null = root/head document.
 NodeId? get parentDocId;/// Required when [parentDocId] != null.
 AnchorSpan? get anchorSpan; DocumentStatus get status;/// Snapshot of anchored text at creation — the "history note" that
/// future-proofs against edits, sync bugs, and storage migrations.
 String? get spanSnapshot; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of DocumentNode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocumentNodeCopyWith<DocumentNode> get copyWith => _$DocumentNodeCopyWithImpl<DocumentNode>(this as DocumentNode, _$identity);

  /// Serializes this DocumentNode to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DocumentNode&&(identical(other.id, id) || other.id == id)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.formatId, formatId) || other.formatId == formatId)&&const DeepCollectionEquality().equals(other.blocks, blocks)&&(identical(other.parentDocId, parentDocId) || other.parentDocId == parentDocId)&&(identical(other.anchorSpan, anchorSpan) || other.anchorSpan == anchorSpan)&&(identical(other.status, status) || other.status == status)&&(identical(other.spanSnapshot, spanSnapshot) || other.spanSnapshot == spanSnapshot)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,kind,formatId,const DeepCollectionEquality().hash(blocks),parentDocId,anchorSpan,status,spanSnapshot,createdAt,updatedAt);

@override
String toString() {
  return 'DocumentNode(id: $id, kind: $kind, formatId: $formatId, blocks: $blocks, parentDocId: $parentDocId, anchorSpan: $anchorSpan, status: $status, spanSnapshot: $spanSnapshot, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $DocumentNodeCopyWith<$Res>  {
  factory $DocumentNodeCopyWith(DocumentNode value, $Res Function(DocumentNode) _then) = _$DocumentNodeCopyWithImpl;
@useResult
$Res call({
 NodeId id, String kind, String? formatId, List<Block> blocks, NodeId? parentDocId, AnchorSpan? anchorSpan, DocumentStatus status, String? spanSnapshot, DateTime createdAt, DateTime updatedAt
});


$AnchorSpanCopyWith<$Res>? get anchorSpan;

}
/// @nodoc
class _$DocumentNodeCopyWithImpl<$Res>
    implements $DocumentNodeCopyWith<$Res> {
  _$DocumentNodeCopyWithImpl(this._self, this._then);

  final DocumentNode _self;
  final $Res Function(DocumentNode) _then;

/// Create a copy of DocumentNode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? kind = null,Object? formatId = freezed,Object? blocks = null,Object? parentDocId = freezed,Object? anchorSpan = freezed,Object? status = null,Object? spanSnapshot = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(DocumentNode(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as NodeId,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,formatId: freezed == formatId ? _self.formatId : formatId // ignore: cast_nullable_to_non_nullable
as String?,blocks: null == blocks ? _self.blocks : blocks // ignore: cast_nullable_to_non_nullable
as List<Block>,parentDocId: freezed == parentDocId ? _self.parentDocId : parentDocId // ignore: cast_nullable_to_non_nullable
as NodeId?,anchorSpan: freezed == anchorSpan ? _self.anchorSpan : anchorSpan // ignore: cast_nullable_to_non_nullable
as AnchorSpan?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DocumentStatus,spanSnapshot: freezed == spanSnapshot ? _self.spanSnapshot : spanSnapshot // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of DocumentNode
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnchorSpanCopyWith<$Res>? get anchorSpan {
    if (_self.anchorSpan == null) {
    return null;
  }

  return $AnchorSpanCopyWith<$Res>(_self.anchorSpan!, (value) {
    return _then(_self.copyWith(anchorSpan: value));
  });
}
}


/// Adds pattern-matching-related methods to [DocumentNode].
extension DocumentNodePatterns on DocumentNode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DocumentNode value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DocumentNode() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DocumentNode value)  $default,){
final _that = this;
switch (_that) {
case _DocumentNode():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DocumentNode value)?  $default,){
final _that = this;
switch (_that) {
case _DocumentNode() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( NodeId id,  String kind,  String? formatId,  List<Block> blocks,  NodeId? parentDocId,  AnchorSpan? anchorSpan,  DocumentStatus status,  String? spanSnapshot,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DocumentNode() when $default != null:
return $default(_that.id,_that.kind,_that.formatId,_that.blocks,_that.parentDocId,_that.anchorSpan,_that.status,_that.spanSnapshot,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( NodeId id,  String kind,  String? formatId,  List<Block> blocks,  NodeId? parentDocId,  AnchorSpan? anchorSpan,  DocumentStatus status,  String? spanSnapshot,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _DocumentNode():
return $default(_that.id,_that.kind,_that.formatId,_that.blocks,_that.parentDocId,_that.anchorSpan,_that.status,_that.spanSnapshot,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( NodeId id,  String kind,  String? formatId,  List<Block> blocks,  NodeId? parentDocId,  AnchorSpan? anchorSpan,  DocumentStatus status,  String? spanSnapshot,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _DocumentNode() when $default != null:
return $default(_that.id,_that.kind,_that.formatId,_that.blocks,_that.parentDocId,_that.anchorSpan,_that.status,_that.spanSnapshot,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DocumentNode implements DocumentNode {
  const _DocumentNode({required this.id, this.kind = 'doc', this.formatId,  List<Block> blocks = const <Block>[], this.parentDocId, this.anchorSpan, this.status = DocumentStatus.open, this.spanSnapshot, required this.createdAt, required this.updatedAt}): _blocks = blocks;
  factory _DocumentNode.fromJson(Map<String, dynamic> json) => _$DocumentNodeFromJson(json);

@override final  NodeId id;
/// Only 'doc' today; extensible later without model changes.
@override@JsonKey() final  String kind;
/// Replaces sealed format enums: 'gdd', 'prd', or any template id.
/// Null = unformatted doc.
@override final  String? formatId;
 final  List<Block> _blocks;
@override@JsonKey() List<Block> get blocks {
  if (_blocks is EqualUnmodifiableListView) return _blocks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_blocks);
}

/// Null = root/head document.
@override final  NodeId? parentDocId;
/// Required when [parentDocId] != null.
@override final  AnchorSpan? anchorSpan;
@override@JsonKey() final  DocumentStatus status;
/// Snapshot of anchored text at creation — the "history note" that
/// future-proofs against edits, sync bugs, and storage migrations.
@override final  String? spanSnapshot;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of DocumentNode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DocumentNodeCopyWith<_DocumentNode> get copyWith => __$DocumentNodeCopyWithImpl<_DocumentNode>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DocumentNodeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DocumentNode&&(identical(other.id, id) || other.id == id)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.formatId, formatId) || other.formatId == formatId)&&const DeepCollectionEquality().equals(other._blocks, _blocks)&&(identical(other.parentDocId, parentDocId) || other.parentDocId == parentDocId)&&(identical(other.anchorSpan, anchorSpan) || other.anchorSpan == anchorSpan)&&(identical(other.status, status) || other.status == status)&&(identical(other.spanSnapshot, spanSnapshot) || other.spanSnapshot == spanSnapshot)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,kind,formatId,const DeepCollectionEquality().hash(_blocks),parentDocId,anchorSpan,status,spanSnapshot,createdAt,updatedAt);

@override
String toString() {
  return 'DocumentNode(id: $id, kind: $kind, formatId: $formatId, blocks: $blocks, parentDocId: $parentDocId, anchorSpan: $anchorSpan, status: $status, spanSnapshot: $spanSnapshot, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$DocumentNodeCopyWith<$Res> implements $DocumentNodeCopyWith<$Res> {
  factory _$DocumentNodeCopyWith(_DocumentNode value, $Res Function(_DocumentNode) _then) = __$DocumentNodeCopyWithImpl;
@override @useResult
$Res call({
 NodeId id, String kind, String? formatId, List<Block> blocks, NodeId? parentDocId, AnchorSpan? anchorSpan, DocumentStatus status, String? spanSnapshot, DateTime createdAt, DateTime updatedAt
});


@override $AnchorSpanCopyWith<$Res>? get anchorSpan;

}
/// @nodoc
class __$DocumentNodeCopyWithImpl<$Res>
    implements _$DocumentNodeCopyWith<$Res> {
  __$DocumentNodeCopyWithImpl(this._self, this._then);

  final _DocumentNode _self;
  final $Res Function(_DocumentNode) _then;

/// Create a copy of DocumentNode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? kind = null,Object? formatId = freezed,Object? blocks = null,Object? parentDocId = freezed,Object? anchorSpan = freezed,Object? status = null,Object? spanSnapshot = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_DocumentNode(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as NodeId,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,formatId: freezed == formatId ? _self.formatId : formatId // ignore: cast_nullable_to_non_nullable
as String?,blocks: null == blocks ? _self._blocks : blocks // ignore: cast_nullable_to_non_nullable
as List<Block>,parentDocId: freezed == parentDocId ? _self.parentDocId : parentDocId // ignore: cast_nullable_to_non_nullable
as NodeId?,anchorSpan: freezed == anchorSpan ? _self.anchorSpan : anchorSpan // ignore: cast_nullable_to_non_nullable
as AnchorSpan?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DocumentStatus,spanSnapshot: freezed == spanSnapshot ? _self.spanSnapshot : spanSnapshot // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of DocumentNode
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnchorSpanCopyWith<$Res>? get anchorSpan {
    if (_self.anchorSpan == null) {
    return null;
  }

  return $AnchorSpanCopyWith<$Res>(_self.anchorSpan!, (value) {
    return _then(_self.copyWith(anchorSpan: value));
  });
}
}

// dart format on
