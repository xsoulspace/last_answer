import 'dart:convert';

import '../../data_models/data_models.dart';

/// Path for a doc body in universal_storage: `docs/{gdd|prd}/{id}.json`.
String docBodyPath(final DocKind docKind, final ProjectModelId id) =>
    'docs/${docKind.name}/${id.value}.json';

/// Serializes doc body (blocks + threads) to JSON string.
String docBodyToJson(final List<DocBlockModel> blocks,
    final Map<SpanId, DocThreadModel> threads) {
  final threadsJson = threads.map(
    (final k, final v) => MapEntry(k.value, v.toJson()),
  );
  return jsonEncode(<String, dynamic>{
    'blocks': blocks.map((final b) => b.toJson()).toList(),
    'threads': threadsJson,
  });
}

/// Deserializes doc body from JSON string. Returns null if invalid.
(List<DocBlockModel> blocks, Map<SpanId, DocThreadModel> threads)?
    docBodyFromJson(final String? raw) {
  if (raw == null || raw.isEmpty) return null;
  try {
    final map = jsonDecode(raw) as Map<String, dynamic>?;
    if (map == null) return null;
    final blocksList = map['blocks'] as List<dynamic>?;
    final threadsMap = map['threads'] as Map<String, dynamic>?;
    final blocks = blocksList
            ?.map(
              (final e) =>
                  DocBlockModel.fromJson(e as Map<String, dynamic>),
            )
            .toList() ??
        <DocBlockModel>[];
    final threads = <SpanId, DocThreadModel>{};
    if (threadsMap != null) {
      for (final e in threadsMap.entries) {
        threads[SpanId(e.key)] =
            DocThreadModel.fromJson(e.value as Map<String, dynamic>);
      }
    }
    return (blocks, threads);
  } catch (_) {
    return null;
  }
}
