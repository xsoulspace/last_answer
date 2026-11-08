import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/doc/code_view.dart';

/// 2a — the code format's laws: the language is DERIVED from the
/// filename (never stored twice), the content rides the doc's first
/// paragraph block (zero migration on the shared spine), and the
/// editor persists through the registry's own lane on a debounce.
void main() {
  group('the pure helpers', () {
    test('the language word derives from the extension, honestly', () {
      expect(codeLanguageOf('main.dart'), 'dart');
      expect(codeLanguageOf('tool.py'), 'python');
      expect(codeLanguageOf('app.ts'), 'typescript');
      expect(codeLanguageOf('Justfile'), 'text');
      expect(codeLanguageOf('notes.'), 'text');
      expect(codeLanguageOf(''), 'text');
      expect(codeLanguageOf('README.MD'), 'markdown');
    });

    test('the content block is the FIRST paragraph — replaced, never '
        'duplicated; a doc without one grows it on save', () {
      final heading = DocBlockModel(
        id: DocBlockId.generate(),
        type: DocBlockType.heading,
        content: 'h',
      );
      final para = DocBlockModel(
        id: DocBlockId.generate(),
        type: DocBlockType.paragraph,
        content: 'old',
      );
      expect(codeBlockIndexOf([heading, para]), 1);
      final after = codeBlocksAfter([heading, para], 'new');
      expect(after, hasLength(2));
      expect(after[1].content, 'new');
      expect(after[1].id, para.id); // the SAME block, replaced in place
      final grown = codeBlocksAfter([heading], 'code');
      expect(grown, hasLength(2));
      expect(grown.last.content, 'code');
      expect(codeBlockIndexOf([]), -1);
    });

    test('a fresh code doc is one paragraph block on the doc spine', () {
      final doc = ProjectModel.emptyCode(title: 'main.dart') as ProjectModelDoc;
      expect(doc.formatId, DocFormatIds.code);
      expect(doc.title, 'main.dart');
      expect(doc.blocks, hasLength(1));
      expect(doc.blocks.single.type, DocBlockType.paragraph);
      expect(doc.blocks.single.content, '');
    });
  });

  testWidgets('the editor seeds from the block and saves on the debounce',
      (final tester) async {
    final doc = ProjectModel.emptyCode(title: 'tool.py') as ProjectModelDoc;
    final seeded = doc.copyWith(
      blocks: codeBlocksAfter(doc.blocks, 'print("hi")'),
    );
    ProjectModelDoc? saved;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CodeDocumentView(
            doc: seeded,
            onSave: (final updated) => saved = updated,
          ),
        ),
      ),
    );
    await tester.pump();

    // Seeded: the editor shows the block's content; the head facts the
    // derived language and the calm saved state.
    final editor = find.byKey(const ValueKey('code.editor'));
    expect(tester.widget<TextField>(editor).controller!.text, 'print("hi")');
    expect(find.text('python'), findsOneWidget);
    expect(find.text('saved'), findsOneWidget);

    // A keystroke marks the doc dirty…
    await tester.enterText(editor, 'print("bye")');
    await tester.pump();
    expect(find.text('…'), findsOneWidget);
    expect(saved, isNull); // never per keystroke

    // …and the debounce persists through the save lane.
    await tester.pump(const Duration(milliseconds: 700));
    expect(saved, isNotNull);
    expect(saved!.blocks.single.content, 'print("bye")');
    expect(find.text('saved'), findsOneWidget);

    // The title edit re-derives the language word live.
    await tester.enterText(
      find.byKey(const ValueKey('code.title')),
      'tool.rs',
    );
    await tester.pump();
    expect(find.text('rust'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 700));
    expect(saved!.title, 'tool.rs');
  });
}
