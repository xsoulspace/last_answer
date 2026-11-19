import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/ui_legacy/note/note_asset_store.dart';
import 'package:lastanswer/ui_legacy/note/widgets/image_edit_sheet.dart';

/// The note's attachment strip (native-image-assets Wave D1, LA ADR
/// 0029): one thumbnail per asset row, the FILE is the pixels (resolved
/// through the store), alt text is the accessibility label, and a tap
/// opens the honest actions — edit (deterministic/generative), caption
/// (alt text), remove. Rows whose file is missing render the honest
/// placeholder; they never silently vanish.
class NoteAssetStrip extends HookWidget {
  const NoteAssetStrip({
    required this.note,
    required this.onAssetsChanged,
    super.key,
  });
  final ProjectModelNote note;
  final void Function(List<NoteAssetModel> assets) onAssetsChanged;

  Future<void> _showActions(
    final BuildContext context,
    final NoteAssetStore store,
    final NoteAssetModel asset,
  ) async {
    final l10n = context.l10n;
    await showLaSheet<void>(
      context: context,
      builder: (final sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LaRow(
              leading: const Icon(Icons.edit_outlined),
              titleText: l10n.editImage,
              onTap: () {
                Navigator.of(sheetContext).pop();
                unawaited(
                  showImageEditSheet(
                    context,
                    asset: asset,
                    noteId: note.id,
                    store: store,
                    onNewAsset: (final newAsset) => onAssetsChanged([
                      ...note.assets,
                      newAsset,
                    ]),
                  ),
                );
              },
            ),
            LaRow(
              leading: const Icon(Icons.subtitles_outlined),
              titleText: l10n.captionImage,
              onTap: () {
                Navigator.of(sheetContext).pop();
                unawaited(_editCaption(context, store, asset));
              },
            ),
            LaRow(
              leading: const Icon(Icons.delete_outline),
              titleText: l10n.removeImage,
              onTap: () {
                Navigator.of(sheetContext).pop();
                unawaited(_remove(context, store, asset));
              },
            ),
          ],
        ),
      ),
    );
  }

  /// The alt caption — human-entered, stored on the row (the honest
  /// `alt=` of the local plane; a vision describe pass would fill the
  /// same slot).
  Future<void> _editCaption(
    final BuildContext context,
    final NoteAssetStore store,
    final NoteAssetModel asset,
  ) async {
    final controller = TextEditingController(text: asset.alt);
    final alt = await showLaDialog<String>(
      context: context,
      builder: (final dialogContext) => LaDialog(
        titleText: dialogContext.l10n.captionImage,
        content: LaTextArea(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          placeholder: dialogContext.l10n.altTextHint,
        ),
        actions: [
          LaButton(
            label: dialogContext.l10n.cancel,
            variant: LaButtonVariant.ghost,
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          LaButton(
            label: dialogContext.l10n.captionImage,
            variant: LaButtonVariant.primary,
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text),
          ),
        ],
      ),
    );
    if (alt == null) return;
    onAssetsChanged([
      for (final a in note.assets)
        if (a.id == asset.id) a.copyWith(alt: alt.trim()) else a,
    ]);
  }

  /// Removing deletes the FILE and the row — the note is the owner of
  /// its attachments' lifecycle.
  Future<void> _remove(
    final BuildContext context,
    final NoteAssetStore store,
    final NoteAssetModel asset,
  ) async {
    await store.deleteAssets(noteId: note.id, assets: [asset]);
    onAssetsChanged(
      note.assets.where((final a) => a.id != asset.id).toList(),
    );
  }

  @override
  Widget build(final BuildContext context) {
    final assets = note.assets;
    if (assets.isEmpty) return const SizedBox.shrink();
    final storeSnapshot = useFuture(
      useMemoized(NoteAssetStore.instance, const <Object?>[]),
    );
    final store = storeSnapshot.data;
    if (store == null) return const SizedBox.shrink();
    return SizedBox(
      height: 84,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            for (final asset in assets)
              Padding(
                key: ValueKey('note.asset.${asset.id}'),
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => unawaited(_showActions(context, store, asset)),
                  child: Semantics(
                    label: asset.alt.isEmpty
                        ? context.l10n.editImage
                        : asset.alt,
                    button: true,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 72,
                        height: 72,
                        // The thumbnail renders FROM THE FILE; a missing
                        // file shows the honest placeholder icon (the
                        // row survives — it never silently vanishes).
                        child: store.exists(asset)
                            ? Image.file(
                                store.resolve(asset),
                                fit: BoxFit.cover,
                                width: 72,
                                height: 72,
                                errorBuilder: (final context, _, _) =>
                                    const Icon(Icons.broken_image_outlined),
                              )
                            : const Icon(Icons.image_outlined),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
