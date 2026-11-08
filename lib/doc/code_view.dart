/// 2a — the `code` format: a code/file document on the open formatId
/// registry (zero migration). One monospace editor over the doc's
/// content block (the Menlo law: code is code — never the prose grid),
/// the filename in the head (the language is DERIVED from its
/// extension, never stored twice), and the registry's own persistence
/// lane (debounced `updateProject` — the same composition point the
/// agent-doc surface uses).
///
/// The highlighter is the named runway: day one renders plain mono —
/// an honest, license-clean baseline; a lightweight highlighter slots
/// onto the same painter seam later without a model change.
library;

import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/shell/shell_theme.dart';

/// The language word for a filename (the head chip's fact). Unknown
/// extensions and no extension fall back to `text` — honest, never a
/// guess. Pure so tests and the runway highlighter share one truth.
String codeLanguageOf(final String title) {
  final dot = title.lastIndexOf('.');
  if (dot < 0 || dot == title.length - 1) return 'text';
  return switch (title.substring(dot + 1).toLowerCase()) {
    'dart' => 'dart',
    'py' => 'python',
    'js' || 'mjs' => 'javascript',
    'ts' => 'typescript',
    'json' => 'json',
    'yaml' || 'yml' => 'yaml',
    'md' || 'mdx' => 'markdown',
    'sh' || 'zsh' || 'bash' => 'shell',
    'rs' => 'rust',
    'go' => 'go',
    'swift' => 'swift',
    'kt' => 'kotlin',
    'html' => 'html',
    'css' => 'css',
    'c' || 'h' => 'c',
    'cpp' || 'cc' || 'hpp' => 'c++',
    'java' => 'java',
    'rb' => 'ruby',
    'php' => 'php',
    'sql' => 'sql',
    'toml' => 'toml',
    'xml' => 'xml',
    'txt' => 'text',
    _ => 'text',
  };
}

/// The content block's index: the FIRST paragraph block carries the
/// code (the format's one-block law); -1 when the doc has none (a
/// migrated/foreign shape — the editor appends on first save).
int codeBlockIndexOf(final List<DocBlockModel> blocks) {
  for (var i = 0; i < blocks.length; i++) {
    if (blocks[i].type == DocBlockType.paragraph) return i;
  }
  return -1;
}

/// The blocks after an editor save: the first paragraph block's
/// content replaced (or one appended when the doc carried none).
/// Pure — pinned by tests, shared by the save lane.
List<DocBlockModel> codeBlocksAfter(
  final List<DocBlockModel> blocks,
  final String text,
) {
  final index = codeBlockIndexOf(blocks);
  if (index < 0) {
    return [
      ...blocks,
      DocBlockModel(
        id: DocBlockId.generate(),
        type: DocBlockType.paragraph,
        content: text,
      ),
    ];
  }
  return [
    for (var i = 0; i < blocks.length; i++)
      if (i == index) blocks[i].copyWith(content: text) else blocks[i],
  ];
}

/// The code document's surface: filename head + one mono editor.
/// [onSave] is the test seam; production persists through the
/// registry's own `OpenedProjectNotifier.updateProject` lane.
final class CodeDocumentView extends StatefulWidget {
  const CodeDocumentView({required this.doc, this.onSave, super.key});

  final ProjectModelDoc doc;
  final void Function(ProjectModelDoc updated)? onSave;

  @override
  State<CodeDocumentView> createState() => CodeDocumentViewState();
}

class CodeDocumentViewState extends State<CodeDocumentView> {
  late final TextEditingController _title;
  late final TextEditingController _editor;
  Timer? _debounce;
  var _dirty = false;

  /// Debounce window — the editor saves while the human pauses, never
  /// per keystroke (the registry's put is a real write).
  static const saveDebounce = Duration(milliseconds: 600);

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.doc.title);
    final blocks = widget.doc.blocks;
    final index = codeBlockIndexOf(blocks);
    _editor = TextEditingController(
      text: index < 0 ? '' : blocks[index].content,
    );
  }

  @override
  void didUpdateWidget(final CodeDocumentView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A different document arrived (tab reuse): re-seed. The same
    // document re-rendered keeps the editor's live text (never fight
    // the human's cursor with an echo of their own save).
    if (oldWidget.doc.id != widget.doc.id) {
      _title.text = widget.doc.title;
      final blocks = widget.doc.blocks;
      final index = codeBlockIndexOf(blocks);
      _editor.text = index < 0 ? '' : blocks[index].content;
      _dirty = false;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _title.dispose();
    _editor.dispose();
    super.dispose();
  }

  void _changed() {
    _dirty = true;
    _debounce?.cancel();
    _debounce = Timer(saveDebounce, _save);
    if (mounted) setState(() {});
  }

  void _save() {
    if (!mounted) return;
    final updated = widget.doc.copyWith(
      title: _title.text.trim(),
      blocks: codeBlocksAfter(widget.doc.blocks, _editor.text),
      updatedAt: DateTime.now(),
    );
    final onSave = widget.onSave;
    if (onSave != null) {
      onSave(updated);
    } else {
      context.read<OpenedProjectNotifier>().updateProject(updated);
    }
    setState(() => _dirty = false);
  }

  @override
  Widget build(final BuildContext context) {
    final language = codeLanguageOf(_title.text.trim());
    return Column(
      key: const ValueKey('code.view'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  key: const ValueKey('code.title'),
                  controller: _title,
                  onChanged: (_) => _changed(),
                  style: LaTokens.mono(13, context.la.ink),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    hintText: 'filename.dart',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                language,
                key: const ValueKey('code.lang'),
                style: LaTokens.mono(10.5, context.la.inkQuiet),
              ),
              const SizedBox(width: 10),
              Text(
                _dirty ? '…' : 'saved',
                key: const ValueKey('code.saveState'),
                style: LaTokens.mono(10.5, context.la.inkQuiet),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: context.shellHairline),
        Expanded(
          child: TextField(
            key: const ValueKey('code.editor'),
            controller: _editor,
            onChanged: (_) => _changed(),
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            keyboardType: TextInputType.multiline,
            style: LaTokens.mono(
              12.5,
              context.la.ink,
            ).copyWith(height: 1.55),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.fromLTRB(14, 10, 14, 24),
            ),
          ),
        ),
      ],
    );
  }
}
