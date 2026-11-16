// ignore: depend_on_referenced_packages -- resolved transitively via core
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lastanswer/coding_agent/image_generation_service.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/note/note_asset_store.dart';
import 'package:lastanswer/note/widgets/image_prompt_dialog.dart';

/// The attach menu (native-image-assets Wave D1, LA ADR 0029):
/// gallery · camera (mobile only) · generate (the composed images lane,
/// absent honestly when no key is configured). Picked files COPY into
/// the note's asset dir — the source never moves. Answers the new
/// asset rows through [onAssets]; the caller owns persistence and
/// feedback.
Future<void> showNoteAssetAttachSheet(
  final BuildContext context, {
  required final ProjectModelId noteId,
  required final void Function(List<NoteAssetModel> assets) onAssets,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    builder: (final sheetContext) => _AttachSheet(
      noteId: noteId,
      onAssets: onAssets,
    ),
  );
}

class _AttachSheet extends StatelessWidget {
  const _AttachSheet({required this.noteId, required this.onAssets});
  final ProjectModelId noteId;
  final void Function(List<NoteAssetModel> assets) onAssets;

  Future<void> _pick(
    final BuildContext context, {
    required final bool camera,
  }) async {
    try {
      final String? sourcePath;
      if (camera) {
        final picked = await ImagePicker().pickImage(
          source: ImageSource.camera,
        );
        sourcePath = picked?.path;
      } else if (Platform.isAndroid || Platform.isIOS) {
        final picked = await ImagePicker().pickImage(
          source: ImageSource.gallery,
        );
        sourcePath = picked?.path;
      } else {
        final result = await FilePicker.pickFiles(type: FileType.image);
        sourcePath = (result == null || result.files.isEmpty)
            ? null
            : result.files.first.path;
      }
      if (sourcePath == null) return;
      final store = await NoteAssetStore.instance();
      final asset = await store.importFile(
        sourcePath: sourcePath,
        noteId: noteId,
      );
      onAssets([asset]);
      if (!context.mounted) return;
      Navigator.of(context).pop();
    } on NoteAssetException {
      if (context.mounted) {
        await Toasts.of(context).showBottomToast(
          message: context.l10n.imageEditFailed,
        );
      }
    }
  }

  Future<void> _generate(final BuildContext context) async {
    final l10n = context.l10n;
    final service = await composeForNotes();
    if (service == null) {
      if (context.mounted) {
        await Toasts.of(context).showBottomToast(
          message: context.l10n.imageGenerationFailed,
        );
      }
      return;
    }
    // The sheet's context rides the composition await above; the
    // mounted guards below handle the later gaps.
    // ignore: use_build_context_synchronously
    final prompt = await askImagePrompt(context);
    if (prompt == null || prompt.trim().isEmpty) return;
    final result = await service.generate(prompt: prompt.trim());
    final images = result.data?.images ?? const <GeneratedImage>[];
    if (!result.success || images.isEmpty) {
      if (context.mounted) {
        await Toasts.of(context).showBottomToast(
          message: l10n.imageGenerationFailed,
        );
      }
      return;
    }
    final store = await NoteAssetStore.instance();
    final assets = <NoteAssetModel>[];
    for (final image in images) {
      try {
        assets.add(
          await store.importBytes(
            bytes: File(image.filePath).readAsBytesSync(),
            noteId: noteId,
          ),
        );
      } on NoteAssetException {
        continue;
      }
    }
    if (assets.isEmpty) {
      if (context.mounted) {
        await Toasts.of(context).showBottomToast(
          message: l10n.imageGenerationFailed,
        );
      }
      return;
    }
    onAssets(assets);
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final isMobile = Platform.isAndroid || Platform.isIOS;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_outlined),
            title: Text(l10n.chooseImage),
            onTap: () => unawaited(_pick(context, camera: false)),
          ),
          if (isMobile)
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l10n.takePhoto),
              onTap: () => unawaited(_pick(context, camera: true)),
            ),
          ListTile(
            leading: const Icon(Icons.auto_awesome_outlined),
            title: Text(l10n.generateImage),
            onTap: () => unawaited(_generate(context)),
          ),
        ],
      ),
    );
  }
}
