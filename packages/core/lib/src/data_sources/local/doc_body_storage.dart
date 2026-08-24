import 'dart:convert';

import '../../data_models/data_models.dart';

/// Path for a doc body in universal_storage: `docs/{id}.json`.
/// One file per document node; discussion children are separate nodes
/// with their own files (see ADR 0001).
String docBodyPath(final ProjectModelId id) => 'docs/${id.value}.json';

/// Serializes doc body (blocks) to JSON string.
String docBodyToJson(final List<DocBlockModel> blocks) =>
    jsonEncode(<String, dynamic>{
      'blocks': blocks.map((final b) => b.toJson()).toList(),
    });

/// Deserializes doc body from JSON string. Returns null if invalid.
List<DocBlockModel>? docBodyFromJson(final String? raw) {
  if (raw == null || raw.isEmpty) return null;
  try {
    final map = jsonDecode(raw) as Map<String, dynamic>?;
    final blocksList = map?['blocks'] as List<dynamic>?;
    return blocksList
        ?.map(
          (final e) => DocBlockModel.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  } catch (_) {
    return null;
  }
}
