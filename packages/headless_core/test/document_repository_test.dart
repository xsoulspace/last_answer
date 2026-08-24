import 'dart:io';

import 'package:headless_core/headless_core.dart';
import 'package:test/test.dart';
import 'package:universal_storage_filesystem/universal_storage_filesystem.dart';
import 'package:universal_storage_interface/universal_storage_interface.dart';

/// Shared conformance suite run against every [DocumentRepository].
void conformanceSuite(DocumentRepository Function() makeRepo) {
  late DocumentRepository repo;

  DocumentNode root() => DocumentNode(
    id: const NodeId('root'),
    blocks: const [
      Block(
        id: NodeId('rb1'),
        type: BlockType.heading,
        content: 'Head',
        level: 1,
      ),
      Block(id: NodeId('rb2'), type: BlockType.paragraph, content: 'Body'),
    ],
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );

  DocumentNode child(String id) => DocumentNode(
    id: NodeId(id),
    parentDocId: const NodeId('root'),
    anchorSpan: const AnchorSpan(blockId: NodeId('rb2')),
    spanSnapshot: 'Body',
    createdAt: DateTime.utc(2026, 1, 2),
    updatedAt: DateTime.utc(2026, 1, 2),
  );

  setUp(() => repo = makeRepo());

  test('save + get round-trips a node', () async {
    final node = root();
    await repo.save(node);
    final result = await repo.get(const NodeId('root'));
    expect(result, isA<DocFound>());
    expect((result as DocFound).node, node);
  });

  test('get on missing id returns DocNotFound', () async {
    final result = await repo.get(const NodeId('nope'));
    expect(result, isA<DocNotFound>());
  });

  test('childrenOf lists direct children; roots under null', () async {
    await repo.save(root());
    await repo.save(child('c1'));
    await repo.save(child('c2'));

    final roots = await repo.childrenOf(null);
    expect(roots.map((n) => n.value), ['root']);
    final kids = await repo.childrenOf(const NodeId('root'));
    expect(kids.map((n) => n.value).toSet(), {'c1', 'c2'});
  });

  test('child without invariants is rejected', () async {
    final bad = DocumentNode(
      id: const NodeId('bad'),
      parentDocId: const NodeId('root'),
      // missing anchorSpan and spanSnapshot
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
    expect(() => repo.save(bad), throwsA(isA<InvariantViolation>()));
  });

  test('delete removes the node from listing and children', () async {
    await repo.save(root());
    await repo.save(child('c1'));
    await repo.delete(const NodeId('c1'));
    expect(await repo.get(const NodeId('c1')), isA<DocNotFound>());
    expect(await repo.childrenOf(const NodeId('root')), isEmpty);
  });

  test('allIds lists everything stored', () async {
    await repo.save(root());
    await repo.save(child('c1'));
    final ids = (await repo.allIds()).map((n) => n.value).toSet();
    expect(ids, {'root', 'c1'});
  });
}

void main() {
  group('InMemoryDocumentRepository', () {
    conformanceSuite(InMemoryDocumentRepository.new);
  });

  group('StorageDocumentRepository (filesystem)', () {
    late Directory dir;
    late StorageService service;

    setUp(() async {
      dir = Directory.systemTemp.createTempSync('la_storage_test');
      final provider = FileSystemStorageProvider();
      await provider.initWithConfig(
        FileSystemConfig(
          filePathConfig: FilePathConfig.create(
            path: dir.path,
            macOSBookmarkData: MacOSBookmark.fromDirectory(dir),
          ),
        ),
      );
      service = StorageService(provider);
    });

    tearDown(() => dir.delete(recursive: true));

    conformanceSuite(() => StorageDocumentRepository(service: service));
  });
}
