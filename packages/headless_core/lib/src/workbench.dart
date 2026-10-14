import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'document_node.dart';
import 'document_repository.dart';

/// Exact content revision, independent of wall-clock timestamps.
String _snapshotRevision(Object snapshot) =>
    sha256.convert(utf8.encode(jsonEncode(snapshot))).toString();
String workRevision(DocumentNode node) => _snapshotRevision(node.toJson());

enum KnowledgeKind { authored, suggestion, observation, decision, question }

enum EvidenceRelation { supports, contradicts, unresolved }

enum WorkProjection { document, spatial, runtime }

final class WorkbenchRef {
  const WorkbenchRef({
    required this.project,
    required this.object,
    required this.revision,
  });
  final String project;
  final String object;
  final String revision;
  Map<String, Object?> toJson() => {
    'project': project,
    'object': object,
    'revision': revision,
  };
}

final class WorkbenchRefusal implements Exception {
  const WorkbenchRefusal(this.code);
  final String code;
  @override
  String toString() => code;
}

/// Pure transformations over existing stable blocks. No duplicate content store.
final class ArticleOperations {
  static List<Block> move(DocumentNode node, String blockId, int destination) {
    final blocks = List<Block>.of(node.blocks);
    final index = blocks.indexWhere((b) => b.id.value == blockId);
    if (index < 0) throw const WorkbenchRefusal('block_missing');
    if (destination < 0 || destination >= blocks.length) {
      throw const WorkbenchRefusal('destination_invalid');
    }
    blocks.insert(destination, blocks.removeAt(index));
    return blocks;
  }

  static List<Block> moveSection(
    DocumentNode node,
    String headingId,
    String beforeId,
  ) {
    final blocks = List<Block>.of(node.blocks);
    final start = blocks.indexWhere(
      (b) => b.id.value == headingId && b.type == BlockType.heading,
    );
    final destination = blocks.indexWhere(
      (b) => b.id.value == beforeId && b.type == BlockType.heading,
    );
    if (start < 0 || destination < 0) {
      throw const WorkbenchRefusal('section_missing');
    }
    final level = blocks[start].level ?? 1;
    var end = start + 1;
    while (end < blocks.length &&
        !(blocks[end].type == BlockType.heading &&
            (blocks[end].level ?? 1) <= level)) {
      end++;
    }
    final section = blocks.sublist(start, end);
    if (section.any((b) => b.id.value == beforeId)) {
      throw const WorkbenchRefusal('section_destination_inside_source');
    }
    blocks.removeRange(start, end);
    final target = blocks.indexWhere((b) => b.id.value == beforeId);
    blocks.insertAll(target, section);
    return blocks;
  }

  static List<Block> split(
    DocumentNode node,
    String blockId,
    int offset,
    String newId,
  ) {
    final blocks = List<Block>.of(node.blocks);
    final index = blocks.indexWhere((b) => b.id.value == blockId);
    if (index < 0) throw const WorkbenchRefusal('block_missing');
    final block = blocks[index];
    if (newId.isEmpty || blocks.any((b) => b.id.value == newId)) {
      throw const WorkbenchRefusal('block_id_collision');
    }
    if (offset <= 0 ||
        offset >= block.content.length ||
        block.type != BlockType.paragraph) {
      throw const WorkbenchRefusal('split_invalid');
    }
    // Refuse splitting within a UTF-16 surrogate pair.
    final a = block.content.codeUnitAt(offset - 1);
    final b = block.content.codeUnitAt(offset);
    if (a >= 0xd800 && a <= 0xdbff && b >= 0xdc00 && b <= 0xdfff) {
      throw const WorkbenchRefusal('split_unicode_boundary');
    }
    blocks[index] = block.copyWith(content: block.content.substring(0, offset));
    blocks.insert(
      index + 1,
      block.copyWith(
        id: NodeId(newId),
        content: block.content.substring(offset),
      ),
    );
    return blocks;
  }

  static List<Block> rewrite(DocumentNode node, String blockId, String text) =>
      [
        for (final b in node.blocks)
          b.id.value == blockId ? b.copyWith(content: text) : b,
      ];
}

/// Persisted executable configuration; its order is constrained, not arbitrary
/// wires whose meaning is inferred from their drawing.
final class ReturnBehaviour {
  const ReturnBehaviour({
    this.restore = true,
    this.focus = true,
    this.width = 720,
  });
  factory ReturnBehaviour.fromJson(Map<String, dynamic> json) {
    final width = (json['width'] as num? ?? 720).toDouble();
    if (!width.isFinite || width < 320 || width > 1200) {
      throw const WorkbenchRefusal('reading_width_invalid');
    }
    return ReturnBehaviour(
      restore: json['restore'] as bool? ?? true,
      focus: json['focus'] as bool? ?? true,
      width: width,
    );
  }
  final bool restore;
  final bool focus;
  final double width;
  List<String> get sequence => [
    'open',
    if (restore) 'restore',
    if (focus) 'focus',
  ];
  Map<String, Object?> toJson() => {
    'restore': restore,
    'focus': focus,
    'width': width,
  };
}

/// Local domain owner over DocumentRepository. Shared callers must enter through
/// the harness owner; this serialized writer is not a distributed claim service.
final class WorkbenchOwner {
  WorkbenchOwner(this.repository);
  final DocumentRepository repository;
  Future<void> _tail = Future.value();
  static const _format = 'workbench.metadata.v1';

  Future<T> _serial<T>(Future<T> Function() action) {
    final done = Completer<T>();
    _tail = _tail.then((_) async {
      try {
        done.complete(await action());
      } on Object catch (e, s) {
        done.completeError(e, s);
      }
    });
    return done.future;
  }

  Future<DocumentNode> read(String project) async {
    final result = await repository.get(NodeId(project));
    if (result is DocFound) return result.node;
    throw WorkbenchRefusal(
      result is DocError ? 'project_read_failed' : 'project_missing',
    );
  }

  NodeId _metaId(String project) =>
      NodeId('workbench-${Uri.encodeComponent(project)}');
  Future<Map<String, dynamic>> _metadata(String project) async {
    final result = await repository.get(_metaId(project));
    if (result is DocNotFound) {
      return {
        'proposals': <String, dynamic>{},
        'history': <dynamic>[],
        'knowledge': <dynamic>[],
        'links': <dynamic>[],
      };
    }
    if (result is! DocFound ||
        result.node.formatId != _format ||
        result.node.blocks.length != 1) {
      throw const WorkbenchRefusal('workbench_metadata_invalid');
    }
    return jsonDecode(result.node.blocks.single.content)
        as Map<String, dynamic>;
  }

  Future<void> _saveMetadata(String project, Map<String, dynamic> data) async {
    final existing = await repository.get(_metaId(project));
    if (existing is DocError ||
        (existing is DocFound && existing.node.formatId != _format)) {
      throw const WorkbenchRefusal('workbench_metadata_collision');
    }
    final now = DateTime.now().toUtc();
    await repository.save(
      DocumentNode(
        id: _metaId(project),
        kind: 'workbench_metadata',
        formatId: _format,
        createdAt: existing is DocFound ? existing.node.createdAt : now,
        updatedAt: now,
        blocks: [
          Block(
            id: NodeId('${_metaId(project)}-state'),
            type: BlockType.paragraph,
            content: jsonEncode(data),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> state(String project) => _serial(() async {
    final metadata = await _metadata(project);
    await _reconcile(project, metadata);
    return {
      ...metadata,
      'project': project,
      'revision': workRevision(await read(project)),
      'authority': 'document_repository_local_owner',
    };
  });

  Future<String> propose({
    required String project,
    required String actor,
    required String intent,
    required String operation,
    required Map<String, dynamic> arguments,
    String origin = 'surfaceInput',
    String? expectedRevision,
    bool Function()? authorizationStillValid,
  }) => _serial(
    () => _stageProposal(
      project: project,
      actor: actor,
      intent: intent,
      operation: operation,
      arguments: arguments,
      origin: origin,
      expectedRevision: expectedRevision,
      authorizationStillValid: authorizationStillValid,
    ),
  );

  /// Reapply stages a new candidate against current state; adoption remains a
  /// separate decision. The prior candidate and its history remain unchanged.
  Future<String> reapply(String project, String id, {required String actor}) =>
      _serial(() async {
        final metadata = await _metadata(project);
        await _reconcile(project, metadata);
        final prior = _proposal(metadata, id);
        if (prior['status'] != 'undone') {
          throw const WorkbenchRefusal('proposal_not_undone');
        }
        return _stageProposal(
          project: project,
          actor: actor,
          intent: prior['intent'] as String,
          operation: prior['operation'] as String,
          arguments: Map<String, dynamic>.from(prior['arguments'] as Map),
          origin: 'reapply',
          priorProposal: id,
        );
      });

  Future<String> _stageProposal({
    required String project,
    required String actor,
    required String intent,
    required String operation,
    required Map<String, dynamic> arguments,
    required String origin,
    String? expectedRevision,
    bool Function()? authorizationStillValid,
    String? priorProposal,
  }) async {
    if (actor.isEmpty || intent.isEmpty) {
      throw const WorkbenchRefusal('attribution_required');
    }
    final before = await read(project);
    if (expectedRevision != null && expectedRevision != workRevision(before)) {
      throw const WorkbenchRefusal('proposal_scope_stale');
    }
    final metadata = await _metadata(project);
    await _reconcile(project, metadata);
    final proposals = metadata['proposals'] as Map<String, dynamic>;
    final id =
        'proposal-${DateTime.now().microsecondsSinceEpoch}-${proposals.length}';
    DocumentNode? after;
    Map<String, Object?>? config;
    switch (operation) {
      case 'move_block':
        after = before.withBlocks(
          ArticleOperations.move(
            before,
            arguments['block'] as String,
            arguments['destination'] as int,
          ),
        );
      case 'move_section':
        after = before.withBlocks(
          ArticleOperations.moveSection(
            before,
            arguments['block'] as String,
            arguments['before'] as String,
          ),
        );
      case 'split_block':
        after = before.withBlocks(
          ArticleOperations.split(
            before,
            arguments['block'] as String,
            arguments['offset'] as int,
            arguments['newId'] as String,
          ),
        );
      case 'rewrite_block':
        if (before.blockById(NodeId(arguments['block'] as String)) == null) {
          throw const WorkbenchRefusal('block_missing');
        }
        after = before.withBlocks(
          ArticleOperations.rewrite(
            before,
            arguments['block'] as String,
            arguments['text'] as String,
          ),
        );
      case 'return_behaviour':
        config = ReturnBehaviour.fromJson(arguments).toJson();
      default:
        throw const WorkbenchRefusal('operation_unsupported');
    }
    proposals[id] = {
      'id': id,
      'project': project,
      'actor': actor,
      'origin': origin,
      'priorProposal': ?priorProposal,
      'intent': intent,
      'operation': operation,
      'arguments': arguments,
      'baseRevision': workRevision(before),
      'before': before.toJson(),
      if (after != null) 'after': after.toJson(),
      'config': ?config,
      'baseBehaviour': metadata['behaviour'],
      'status': 'staged',
      'evidence': <dynamic>[],
    };
    if (authorizationStillValid != null && !authorizationStillValid()) {
      throw const WorkbenchRefusal('workbench_task_not_bound');
    }
    await _saveMetadata(project, metadata);
    return id;
  }

  Future<void> adopt(String project, String id) => _serial(() async {
    final data = await _metadata(project);
    await _reconcile(project, data);
    final proposal = _proposal(data, id);
    if (proposal['status'] != 'staged') {
      throw const WorkbenchRefusal('proposal_not_staged');
    }
    if (proposal['baseRevision'] != workRevision(await read(project)) ||
        jsonEncode(proposal['baseBehaviour']) !=
            jsonEncode(data['behaviour'])) {
      proposal['status'] = 'stale';
      await _saveMetadata(project, data);
      throw const WorkbenchRefusal('proposal_stale');
    }
    proposal['status'] = 'applying';
    data['pending'] = id;
    await _saveMetadata(project, data); // write-ahead before the content effect
    if (proposal['after'] != null) {
      await repository.save(
        DocumentNode.fromJson(
          Map<String, dynamic>.from(proposal['after'] as Map),
        ),
      );
    } else {
      data['behaviour'] = proposal['config'];
    }
    proposal['status'] = 'adopted';
    (data['history'] as List).add({
      'proposal': id,
      'event': 'adopted',
      'actor': proposal['actor'],
      'at': DateTime.now().toUtc().toIso8601String(),
    });
    data.remove('pending');
    await _saveMetadata(project, data);
  });

  Future<void> reject(String project, String id) => _serial(() async {
    final data = await _metadata(project);
    final proposal = _proposal(data, id);
    if (!['staged', 'stale'].contains(proposal['status'])) {
      throw const WorkbenchRefusal('proposal_cannot_reject');
    }
    proposal['status'] = 'rejected';
    await _saveMetadata(project, data);
  });

  Future<void> undo(String project, String id) => _serial(() async {
    final data = await _metadata(project);
    await _reconcile(project, data);
    final proposal = _proposal(data, id);
    if (proposal['status'] != 'adopted') {
      throw const WorkbenchRefusal('proposal_not_adopted');
    }
    final current = await read(project);
    if (proposal['after'] != null &&
        workRevision(current) != _snapshotRevision(proposal['after']!)) {
      throw const WorkbenchRefusal('undo_source_drift');
    }
    if (proposal['config'] != null &&
        jsonEncode(data['behaviour']) != jsonEncode(proposal['config'])) {
      throw const WorkbenchRefusal('undo_behaviour_drift');
    }
    proposal['status'] = 'undoing';
    data['pending'] = id;
    await _saveMetadata(project, data);
    if (proposal['after'] != null) {
      await repository.save(
        DocumentNode.fromJson(
          Map<String, dynamic>.from(proposal['before'] as Map),
        ),
      );
    } else {
      data['behaviour'] = proposal['baseBehaviour'];
    }
    proposal['status'] = 'undone';
    data.remove('pending');
    (data['history'] as List).add({
      'proposal': id,
      'event': 'undone',
      'at': DateTime.now().toUtc().toIso8601String(),
    });
    await _saveMetadata(project, data);
  });

  Map<String, dynamic> _proposal(Map<String, dynamic> data, String id) {
    final value = (data['proposals'] as Map)[id];
    if (value is! Map) throw const WorkbenchRefusal('proposal_missing');
    return value as Map<String, dynamic>;
  }

  Future<void> _reconcile(String project, Map<String, dynamic> data) async {
    final pending = data['pending'];
    if (pending == null) return;
    final proposal = _proposal(data, pending as String);
    if (proposal['after'] == null) {
      // Config writes settle in the metadata write itself. A persisted pending
      // config has not yet adopted its effect.
      proposal['status'] = proposal['status'] == 'undoing'
          ? 'adopted'
          : 'staged';
    } else {
      final actual = workRevision(await read(project));
      final before = _snapshotRevision(proposal['before']!);
      final after = _snapshotRevision(proposal['after']!);
      if (actual != before && actual != after) {
        throw const WorkbenchRefusal('recovery_source_unknown');
      }
      proposal['status'] = actual == after
          ? 'adopted'
          : (proposal['status'] == 'undoing' ? 'undone' : 'staged');
    }
    (data['history'] as List).add({
      'proposal': pending,
      'event': 'reconciled',
      'status': proposal['status'],
    });
    data.remove('pending');
    await _saveMetadata(project, data);
  }

  Future<void> addKnowledge(
    String project, {
    required KnowledgeKind kind,
    required String text,
    required String actor,
    String? object,
    String? discussion,
  }) => _serial(() async {
    final data = await _metadata(project);
    (data['knowledge'] as List).add({
      'kind': kind.name,
      'text': text,
      'actor': actor,
      'object': object,
      'discussion': discussion,
      'at': DateTime.now().toUtc().toIso8601String(),
    });
    await _saveMetadata(project, data);
  });

  Future<void> linkEvidence(
    String project, {
    required String claim,
    required String source,
    required EvidenceRelation relation,
    required String actor,
  }) => _serial(() async {
    final node = await read(project);
    if (node.blockById(NodeId(claim)) == null || source.trim().isEmpty) {
      throw const WorkbenchRefusal('evidence_target_invalid');
    }
    final data = await _metadata(project);
    (data['links'] as List).add({
      'claim': claim,
      'source': source,
      'relation': relation.name,
      'actor': actor,
    });
    await _saveMetadata(project, data);
  });

  Future<void> recordObservation(
    String project,
    Map<String, Object?> observation, {
    String? proposal,
  }) => _serial(() async {
    final data = await _metadata(project);
    final event = {
      ...observation,
      'at': DateTime.now().toUtc().toIso8601String(),
    };
    (data['history'] as List).add(event);
    if (proposal != null) {
      (_proposal(data, proposal)['evidence'] as List).add(event);
    }
    await _saveMetadata(project, data);
  });

  Future<void> saveView(
    String project,
    Map<String, dynamic> view, {
    String? viewerId,
  }) => _serial(() async {
    final data = await _metadata(project);
    if (viewerId == null) {
      data['view'] = view;
    } else {
      if (viewerId.trim().isEmpty) throw ArgumentError('invalid_viewer_id');
      final views = Map<String, dynamic>.from(data['views'] as Map? ?? {});
      views[viewerId] = view;
      data['views'] = views;
    }
    await _saveMetadata(project, data);
  });
}
