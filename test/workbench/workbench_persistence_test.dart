import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:headless_core/headless_core.dart';
import 'package:universal_storage_filesystem/universal_storage_filesystem.dart';
import 'package:universal_storage_interface/universal_storage_interface.dart';

void main() {
  test(
    'filesystem reopen retains candidate, checkpoint, undo and fresh reapply',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'workbench_reopen_',
      );
      FileSystemStorageProvider? active;
      Future<WorkbenchOwner> reopen() async {
        await active?.dispose();
        active = FileSystemStorageProvider();
        await active!.initWithConfig(
          FileSystemConfig(
            filePathConfig: FilePathConfig.create(
              path: directory.path,
              macOSBookmarkData: MacOSBookmark.fromDirectory(directory),
            ),
          ),
        );
        return WorkbenchOwner(
          StorageDocumentRepository(service: StorageService(active!)),
        );
      }

      try {
        var owner = await reopen();
        final original = DocumentNode(
          id: const NodeId('article'),
          createdAt: DateTime.utc(2026),
          updatedAt: DateTime.utc(2026),
          blocks: const [
            Block(
              id: NodeId('shared'),
              type: BlockType.paragraph,
              content: 'Before',
            ),
            Block(
              id: NodeId('private'),
              type: BlockType.paragraph,
              content: 'Private',
            ),
          ],
        );
        await owner.repository.save(original);
        await owner.saveView('article', {
          'version': 1,
          'selected': 'shared',
        }, viewerId: 'document-view');
        final proposal = await owner.propose(
          project: 'article',
          actor: 'fixture-reviewer',
          intent: 'Revise shared block',
          operation: 'rewrite_block',
          arguments: {'block': 'shared', 'text': 'After'},
        );
        owner = await reopen();
        var metadata = await owner.state('article');
        expect(
          ((metadata['proposals'] as Map)[proposal] as Map)['status'],
          'staged',
        );
        expect(
          ((metadata['views'] as Map)['document-view'] as Map)['selected'],
          'shared',
        );
        expect(
          workRevision(await owner.read('article')),
          workRevision(original),
        );
        await owner.adopt('article', proposal);
        owner = await reopen();
        metadata = await owner.state('article');
        expect(
          ((metadata['proposals'] as Map)[proposal] as Map)['status'],
          'adopted',
        );
        expect(
          (await owner.read(
            'article',
          )).blockById(const NodeId('shared'))!.content,
          'After',
        );
        await owner.undo('article', proposal);
        owner = await reopen();
        expect(
          workRevision(await owner.read('article')),
          workRevision(original),
        );
        final fresh = await owner.reapply(
          'article',
          proposal,
          actor: 'fixture-reviewer',
        );
        owner = await reopen();
        metadata = await owner.state('article');
        final proposals = metadata['proposals'] as Map;
        expect((proposals[proposal] as Map)['status'], 'undone');
        expect((proposals[fresh] as Map)['status'], 'staged');
        expect((proposals[fresh] as Map)['priorProposal'], proposal);
        expect(
          workRevision(await owner.read('article')),
          workRevision(original),
        );
        await owner.adopt('article', fresh);
        final externallyChanged = (await owner.read('article')).withBlocks([
          const Block(
            id: NodeId('shared'),
            type: BlockType.paragraph,
            content: 'External',
          ),
          const Block(
            id: NodeId('private'),
            type: BlockType.paragraph,
            content: 'Private',
          ),
        ]);
        await owner.repository.save(externallyChanged);
        owner = await reopen();
        await expectLater(
          owner.undo('article', fresh),
          throwsA(isA<WorkbenchRefusal>()),
        );
        expect(
          workRevision(await owner.read('article')),
          workRevision(externallyChanged),
        );
      } finally {
        await active?.dispose();
        await directory.delete(recursive: true);
      }
    },
  );
}
