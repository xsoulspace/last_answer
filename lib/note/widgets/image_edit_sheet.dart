import 'package:lastanswer/coding_agent/image_generation_service.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/note/image_edit_ops.dart';
import 'package:lastanswer/note/note_asset_store.dart';
import 'package:lastanswer/note/widgets/image_prompt_dialog.dart';
import 'package:xsoulspace_agentic_harness/xsoulspace_agentic_harness.dart'
    show sniffAssetMedia;
import 'package:xsoulspace_inference_core/xsoulspace_inference_core.dart'
    show InferenceImageInput;

/// The D3 edit flow (native-image-assets Wave D3, LA ADR 0029):
/// deterministic FIRST (rotate / crop / annotate — pure code, honest
/// `new file` receipts), generative SECOND (I2I via the composed
/// images lane: "make the sky stormy" on the selected image). Every
/// save produces a NEW file appended to the note's assets — the
/// original never mutates (the asset plane's generation law, mirrored
/// in the app). Strokes are DATA in the sheet state; only the explicit
/// export bakes them into pixels. Feedback (the "image added" toast)
/// belongs to the caller's [onNewAsset], not the sheet.
Future<void> showImageEditSheet(
  final BuildContext context, {
  required final NoteAssetModel asset,
  required final ProjectModelId noteId,
  required final NoteAssetStore store,
  required final void Function(NoteAssetModel newAsset) onNewAsset,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (final sheetContext) => _ImageEditSheet(
      asset: asset,
      noteId: noteId,
      store: store,
      onNewAsset: onNewAsset,
    ),
  );
}

class _ImageEditSheet extends StatefulWidget {
  const _ImageEditSheet({
    required this.asset,
    required this.noteId,
    required this.store,
    required this.onNewAsset,
  });
  final NoteAssetModel asset;
  final ProjectModelId noteId;
  final NoteAssetStore store;
  final void Function(NoteAssetModel newAsset) onNewAsset;
  @override
  State<_ImageEditSheet> createState() => _ImageEditSheetState();
}

class _ImageEditSheetState extends State<_ImageEditSheet> {
  Uint8List? _bytes;
  String? _errorCode;
  bool _annotating = false;
  bool _busy = false;
  final _strokes = <ImageStroke>[];
  ImageStroke? _currentStroke;

  @override
  void initState() {
    super.initState();
    final file = widget.store.resolve(widget.asset);
    if (file.existsSync()) {
      _bytes = file.readAsBytesSync();
    } else {
      _errorCode = 'note_asset_file_missing';
    }
  }

  /// One deterministic op → NEW bytes → NEW asset row. The original
  /// file and row stay untouched.
  Future<void> _applyOp(final ImageEditOp op) async {
    final bytes = _bytes;
    if (bytes == null || _busy) return;
    setState(() {
      _busy = true;
      _errorCode = null;
    });
    try {
      final edited = applyDeterministicOp(bytes, op);
      final newAsset = await widget.store.importBytes(
        bytes: edited,
        noteId: widget.noteId,
      );
      widget.onNewAsset(newAsset);
    } on ImageEditException catch (error) {
      if (mounted) setState(() => _errorCode = error.code);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// The annotate export: strokes baked into a NEW png file.
  Future<void> _exportAnnotated() async {
    final bytes = _bytes;
    if (bytes == null || _strokes.isEmpty || _busy) return;
    setState(() {
      _busy = true;
      _annotating = false;
    });
    try {
      final baked = await applyStrokes(bytes: bytes, strokes: _strokes);
      final newAsset = await widget.store.importBytes(
        bytes: baked,
        noteId: widget.noteId,
        alt: widget.asset.alt,
      );
      widget.onNewAsset(newAsset);
      _strokes.clear();
    } on ImageEditException catch (error) {
      if (mounted) setState(() => _errorCode = error.code);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// The generative edit: the selected image rides the I2I lane with
  /// the prompt; the result lands as a NEW asset. The lane composes at
  /// CALL time (palette/budget rules then); null = the honest refusal.
  Future<void> _generateVariation() async {
    if (_busy) return;
    final prompt = await _askPrompt(context);
    if (prompt == null || prompt.trim().isEmpty) return;
    setState(() {
      _busy = true;
      _errorCode = null;
    });
    try {
      final service = await composeForNotes();
      if (service == null) {
        if (mounted) setState(() => _errorCode = 'openrouter_key_unavailable');
        return;
      }
      final result = await service.generate(
        prompt: prompt.trim(),
        reference: InferenceImageInput.filePath(
          filePath: widget.store.resolve(widget.asset).path,
          mimeType: widget.asset.mime,
        ),
      );
      if (!result.success || result.data == null) {
        if (mounted) setState(() => _errorCode = 'image_generation_failed');
        return;
      }
      final images = result.data!.images;
      if (images.isEmpty) {
        if (mounted) setState(() => _errorCode = 'image_generation_failed');
        return;
      }
      final newAsset = await widget.store.importBytes(
        bytes: File(images.first.filePath).readAsBytesSync(),
        noteId: widget.noteId,
      );
      widget.onNewAsset(newAsset);
    } on NoteAssetException catch (error) {
      if (mounted) setState(() => _errorCode = error.code);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<String?> _askPrompt(final BuildContext context) =>
      askImagePrompt(context);

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final bytes = _bytes;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                l10n.editImage,
                style: theme.textTheme.titleMedium,
              ),
              const Spacer(),
              if (_busy)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (_errorCode != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _errorCode == 'image_generation_failed'
                    ? l10n.imageGenerationFailed
                    : l10n.imageEditFailed,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          if (bytes == null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(child: Text(l10n.imageEditFailed)),
            )
          else
            _AnnotateCanvas(
              bytes: bytes,
              annotating: _annotating,
              strokes: _strokes,
              currentStroke: _currentStroke,
              onStrokeStart: (final offset) =>
                  setState(() => _currentStroke = ImageStroke(
                    points: [offset],
                    color: 0xffe53935,
                    width: 4,
                  )),
              onStrokeMove: (final offset) {
                final stroke = _currentStroke;
                if (stroke == null) return;
                setState(
                  () => _currentStroke = ImageStroke(
                    points: [...stroke.points, offset],
                    color: stroke.color,
                    width: stroke.width,
                  ),
                );
              },
              onStrokeEnd: () {
                final stroke = _currentStroke;
                if (stroke == null) return;
                setState(() {
                  _strokes.add(stroke);
                  _currentStroke = null;
                });
              },
            ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              IconButton(
                tooltip: l10n.rotateImage,
                onPressed: _busy || bytes == null
                    ? null
                    : () =>
                        unawaited(_applyOp(ImageEditOp.rotateCounterClockwise)),
                icon: const Icon(Icons.rotate_left),
              ),
              IconButton(
                tooltip: l10n.rotateImage,
                onPressed: _busy || bytes == null
                    ? null
                    : () => unawaited(_applyOp(ImageEditOp.rotateClockwise)),
                icon: const Icon(Icons.rotate_right),
              ),
              IconButton(
                tooltip: l10n.cropSquare,
                onPressed: _busy || bytes == null
                    ? null
                    : () => unawaited(_applyOp(ImageEditOp.cropCenterSquare)),
                icon: const Icon(Icons.crop_square),
              ),
              IconButton(
                tooltip: l10n.annotateImage,
                isSelected: _annotating,
                onPressed: bytes == null
                    ? null
                    : () => setState(() => _annotating = !_annotating),
                icon: const Icon(Icons.edit),
              ),
              if (_annotating && _strokes.isNotEmpty)
                TextButton(
                  onPressed: _busy ? null : () => unawaited(_exportAnnotated()),
                  child: Text(l10n.saveImageCopy),
                ),
              TextButton(
                onPressed: _busy || bytes == null
                    ? null
                    : () => unawaited(_generateVariation()),
                child: Text(
                  _busy ? l10n.generatingImage : l10n.generateImage,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The preview: the image at its contain scale inside the sheet, with
/// the stroke overlay drawn as VECTOR ink while annotating (strokes
/// are data; the bake happens only at export). Drag coordinates map
/// through the exact-fit scale, so a stroke lands where the pointer
/// was — no letterbox math.
class _AnnotateCanvas extends StatelessWidget {
  const _AnnotateCanvas({
    required this.bytes,
    required this.annotating,
    required this.strokes,
    required this.currentStroke,
    required this.onStrokeStart,
    required this.onStrokeMove,
    required this.onStrokeEnd,
  });
  final Uint8List bytes;
  final bool annotating;
  final List<ImageStroke> strokes;
  final ImageStroke? currentStroke;
  final void Function(Offset offset) onStrokeStart;
  final void Function(Offset offset) onStrokeMove;
  final VoidCallback onStrokeEnd;
  @override
  Widget build(final BuildContext context) {
    final meta = sniffAssetMedia(bytes, byteLength: bytes.length);
    final imageW = meta?.width ?? 1;
    final imageH = meta?.height ?? 1;
    return LayoutBuilder(
      builder: (final context, final constraints) {
        final scale = (constraints.maxWidth / imageW).clamp(0.0, 320 / imageH);
        final width = imageW * scale;
        final height = imageH * scale;
        return Center(
          child: SizedBox(
            width: width,
            height: height,
            child: GestureDetector(
              onPanStart: annotating
                  ? (final details) =>
                        onStrokeStart(details.localPosition / scale)
                  : null,
              onPanUpdate: annotating
                  ? (final details) =>
                        onStrokeMove(details.localPosition / scale)
                  : null,
              onPanEnd: annotating ? (_) => onStrokeEnd() : null,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.memory(bytes, fit: BoxFit.fill),
                  if (annotating)
                    CustomPaint(
                      painter: _StrokePainter(
                        strokes: [...strokes, ?currentStroke],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StrokePainter extends CustomPainter {
  const _StrokePainter({required this.strokes});
  final List<ImageStroke> strokes;
  @override
  void paint(final Canvas canvas, final Size size) {
    for (final stroke in strokes) {
      if (stroke.points.isEmpty) continue;
      final paint = Paint()
        ..color = Color(stroke.color)
        ..strokeWidth = stroke.width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      final path = Path()
        ..moveTo(stroke.points.first.dx, stroke.points.first.dy);
      for (var i = 1; i < stroke.points.length; i++) {
        path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }
  @override
  bool shouldRepaint(final _StrokePainter oldDelegate) =>
      oldDelegate.strokes != strokes;
}
