import 'dart:convert';

import 'package:headless_core/headless_core.dart';
import 'package:universal_storage_interface/universal_storage_interface.dart';

import 'document_repository.dart';

/// [DocumentRepository] backed by any [StorageService].
///
/// Layout (ADR 0001): one file per node under `docs/<id>.json`, plus an
/// index mapping parent id → child ids so `childrenOf` is O(1) without
/// scanning. The index degrades gracefully: corrupt/missing index rebuilds
/// from node files on the next save.
class StorageDocumentRepository implements DocumentRepository {
  StorageDocumentRepository({required StorageService service})
    : _service = service;

  final StorageService _service;

  static const _docsDir = 'docs';
  static const _indexPath = '$_docsDir/index.json';

  String _path(NodeId id) => '$_docsDir/$id.json';

  @override
  Future<DocResult> get(NodeId id) async {
    final String? raw;
    try {
      raw = await _service.readFile(_path(id));
    } on Object catch (e) {
      return DocError(id, 'read failed: $e');
    }
    if (raw == null) return DocNotFound(id);
    try {
      return DocFound(
        DocumentNode.fromJson(jsonDecode(raw) as Map<String, dynamic>),
      );
    } on Object catch (e) {
      return DocError(id, 'corrupt json: $e');
    }
  }

  @override
  Future<void> save(DocumentNode node) async {
    if (!node.satisfiesChildInvariants) {
      throw InvariantViolation(
        'node ${node.id} is a child but lacks anchorSpan or spanSnapshot',
      );
    }
    await _service.saveFile(
      _path(node.id),
      jsonEncode(node.toJson()),
      message: 'save doc ${node.id}',
    );
    await _updateIndex(node);
  }

  @override
  Future<void> delete(NodeId id) async {
    await _service.removeFile(_path(id), message: 'delete doc $id');
    await _removeFromIndex(id);
  }

  @override
  Future<List<NodeId>> childrenOf(NodeId? parentId) async {
    final index = await _loadIndex();
    final ids = index[parentId?.value ?? ''] ?? const <String>[];
    return ids.map(NodeId.new).toList();
  }

  @override
  Future<List<NodeId>> allIds() async {
    final entries = await _service.listDirectory(_docsDir);
    return entries
        .where((e) => !e.isDirectory && e.name.endsWith('.json'))
        .where((e) => e.name != 'index.json')
        .map((e) => NodeId(e.name.replaceAll('.json', '')))
        .toList();
  }

  Future<Map<String, List<String>>> _loadIndex() async {
    final raw = await _service.readFile(_indexPath);
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map(
        (k, v) => MapEntry(k, (v as List).cast<String>()),
      );
    } on Object {
      return {};
    }
  }

  Future<void> _updateIndex(DocumentNode node) async {
    final key = node.parentDocId?.value ?? '';
    final index = await _loadIndex();
    final children = List<String>.from(index[key] ?? const <String>[]);
    if (!children.contains(node.id.value)) children.add(node.id.value);
    index[key] = children;
    for (final entry in index.entries) {
      if (entry.key != key) entry.value.remove(node.id.value);
    }
    await _service.saveFile(_indexPath, jsonEncode(index));
  }

  Future<void> _removeFromIndex(NodeId id) async {
    final index = await _loadIndex();
    var changed = false;
    for (final entry in index.entries) {
      if (entry.value.remove(id.value)) changed = true;
    }
    if (changed) await _service.saveFile(_indexPath, jsonEncode(index));
  }
}
