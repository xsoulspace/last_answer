// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Block _$BlockFromJson(Map<String, dynamic> json) => _Block(
  id: json['id'] as NodeId,
  type: $enumDecode(_$BlockTypeEnumMap, json['type']),
  content: json['content'] as String? ?? '',
  level: (json['level'] as num?)?.toInt(),
);

Map<String, dynamic> _$BlockToJson(_Block instance) => <String, dynamic>{
  'id': instance.id,
  'type': _$BlockTypeEnumMap[instance.type]!,
  'content': instance.content,
  'level': instance.level,
};

const _$BlockTypeEnumMap = {
  BlockType.heading: 'heading',
  BlockType.paragraph: 'paragraph',
  BlockType.list: 'list',
};

_AnchorSpan _$AnchorSpanFromJson(Map<String, dynamic> json) => _AnchorSpan(
  blockId: json['blockId'] as NodeId,
  prefixHash: json['prefixHash'] as String?,
  suffixHash: json['suffixHash'] as String?,
);

Map<String, dynamic> _$AnchorSpanToJson(_AnchorSpan instance) =>
    <String, dynamic>{
      'blockId': instance.blockId,
      'prefixHash': instance.prefixHash,
      'suffixHash': instance.suffixHash,
    };

_DocumentNode _$DocumentNodeFromJson(Map<String, dynamic> json) =>
    _DocumentNode(
      id: json['id'] as NodeId,
      kind: json['kind'] as String? ?? 'doc',
      formatId: json['formatId'] as String?,
      blocks:
          (json['blocks'] as List<dynamic>?)
              ?.map((e) => Block.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <Block>[],
      parentDocId: json['parentDocId'] as NodeId?,
      anchorSpan: json['anchorSpan'] == null
          ? null
          : AnchorSpan.fromJson(json['anchorSpan'] as Map<String, dynamic>),
      status:
          $enumDecodeNullable(_$DocumentStatusEnumMap, json['status']) ??
          DocumentStatus.open,
      spanSnapshot: json['spanSnapshot'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$DocumentNodeToJson(_DocumentNode instance) =>
    <String, dynamic>{
      'id': instance.id,
      'kind': instance.kind,
      'formatId': instance.formatId,
      'blocks': instance.blocks,
      'parentDocId': instance.parentDocId,
      'anchorSpan': instance.anchorSpan,
      'status': _$DocumentStatusEnumMap[instance.status]!,
      'spanSnapshot': instance.spanSnapshot,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$DocumentStatusEnumMap = {
  DocumentStatus.open: 'open',
  DocumentStatus.collapsed: 'collapsed',
};
