/// Headless document CLI over `packages/headless_core` (ADR 0034).
///
/// Runs as plain Dart — no Flutter, no accounts: `dart bin/doc_cli.dart
/// <workspace-dir> <command> [args]`. Purity law: this file (and anything
/// else under `bin/`) must never import `package:lastanswer` or Flutter;
/// `just bin-gates` enforces it.
///
/// Commands:
///   list                    list root document ids
///   show <docId>            print a document's blocks
///   new [--text <t>]        create a root document
///   discuss <docId> <blockIndex>   open an ADR 0001 discussion child
///   append <docId> <text>   append a paragraph block
///   delete <docId>          delete a document
library;

import 'dart:io';
import 'dart:math';

import 'package:headless_core/headless_core.dart';
import 'package:universal_storage_filesystem/universal_storage_filesystem.dart';
import 'package:universal_storage_interface/universal_storage_interface.dart';

Future<void> main(final List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln('usage: dart bin/doc_cli.dart <workspace-dir> <command> '
        '[args]  (commands: list, show, new, discuss, append, delete)');
    exit(64);
  }
  final workspace = Directory(args[0]);
  if (!workspace.existsSync()) {
    stderr.writeln('workspace does not exist: ${workspace.path}');
    exit(64);
  }
  final command = args.length > 1 ? args[1] : 'list';
  final rest = args.sublist(args.length > 1 ? 2 : 2);

  final provider = FileSystemStorageProvider();
  await provider.initWithConfig(
    FileSystemConfig(
      filePathConfig: FilePathConfig({'path': workspace.path}),
    ),
  );
  final service = StorageService(provider);
  final repo = StorageDocumentRepository(service: service);

  switch (command) {
    case 'list':
      final ids = await repo.childrenOf(null);
      for (final id in ids) {
        final result = await repo.get(id);
        stdout.writeln(
          switch (result) {
            DocFound(:final node) =>
              '${node.id.value}\t${node.status.name}\t'
              '${node.blocks.length} blocks',
            DocError(:final message) => '${id.value}\tERROR\t$message',
            DocNotFound() => '${id.value}\tMISSING\t(index stale)',
          },
        );
      }
    case 'show':
      final result = await repo.get(NodeId(_required(rest, 0)));
      if (result is! DocFound) {
        stderr.writeln('doc not readable: $result');
        exit(66);
      }
      final node = result.node;
      stdout.writeln('doc ${node.id.value} (${node.status.name})');
      for (final (i, block) in node.blocks.indexed) {
        stdout.writeln('[$i] ${block.type.name}: ${block.content}');
      }
    case 'new':
      final text = _option(rest, '--text') ?? '';
      final now = DateTime.now();
      final node = DocumentNode(
        id: NodeId(_uuidV4()),
        createdAt: now,
        updatedAt: now,
        blocks: [Block(id: NodeId(_uuidV4()), type: BlockType.paragraph, content: text)],
      );
      await repo.save(node);
      stdout.writeln(node.id.value);
    case 'discuss':
      final docId = NodeId(_required(rest, 0));
      final index = int.tryParse(_required(rest, 1));
      final result = await repo.get(docId);
      if (result is! DocFound) {
        stderr.writeln('doc not readable: $result');
        exit(66);
      }
      final blocks = result.node.blocks;
      if (index == null || index < 0 || index >= blocks.length) {
        stderr.writeln('block index out of range');
        exit(64);
      }
      final child = Discussions.childNode(
        parent: result.node,
        anchor: blocks[index],
        newId: () => NodeId(_uuidV4()),
        now: DateTime.now(),
      );
      await repo.save(child);
      stdout.writeln(child.id.value);
    case 'append':
      final docId = NodeId(_required(rest, 0));
      final text = rest.skip(1).join(' ');
      final result = await repo.get(docId);
      if (result is! DocFound) {
        stderr.writeln('doc not readable: $result');
        exit(66);
      }
      final node = result.node.copyWith(
        blocks: [
          ...result.node.blocks,
          Block(id: NodeId(_uuidV4()), type: BlockType.paragraph, content: text),
        ],
        updatedAt: DateTime.now(),
      );
      await repo.save(node);
      stdout.writeln('appended to ${node.id.value}');
    case 'delete':
      await repo.delete(NodeId(_required(rest, 0)));
      stdout.writeln('deleted');
    default:
      stderr.writeln('unknown command: $command');
      exit(64);
  }
}

String _required(final List<String> args, final int i) {
  if (i >= args.length) {
    stderr.writeln('missing argument $i');
    exit(64);
  }
  return args[i];
}

String? _option(final List<String> args, final String name) {
  final i = args.indexOf(name);
  if (i < 0 || i + 1 >= args.length) return null;
  return args[i + 1];
}

/// Local id generation for the CLI (plain uuid-shape; the domain accepts
/// any string id — see `NodeId` in headless_core).
String _uuidV4() {
  final r = Random.secure();
  final b = List<int>.generate(16, (_) => r.nextInt(256));
  b[6] = (b[6] & 0x0f) | 0x40;
  b[8] = (b[8] & 0x3f) | 0x80;
  final h = [for (final v in b) v.toRadixString(16).padLeft(2, '0')].join();
  return '${h.substring(0, 8)}-${h.substring(8, 12)}-'
      '${h.substring(12, 16)}-${h.substring(16, 20)}-${h.substring(20)}';
}
