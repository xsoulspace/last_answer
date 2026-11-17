
import 'package:crypto/crypto.dart' as crypto;
// ignore: depend_on_referenced_packages -- resolved transitively via core
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:lastanswer/common_imports.dart';
import 'package:xsoulspace_agentic_harness/xsoulspace_agentic_harness.dart'
    show sniffAssetMedia;
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart'
    show buildMediaAttachment;

/// The human side of the conversation media plane (native-image-assets
/// DMs/channels wave): pick an image, COPY it into the realm's
/// world-adjacent asset dir (`<worldHome>/assets/<threadId>/` — the
/// original never moves), and build the `media v1` attachment entry
/// from the SNIFFED mime + dims and the sha256-16 revision — the same
/// vocabulary the actors' `message` verb validates.
///
/// The v1.1 path form is WORLD-RELATIVE under the share root
/// (`assets/<threadId>/<file>` — the multi-device law: durable beats
/// never embed device-fingered absolute paths; the resolution rule
/// lives in the host's `resolveConversationMediaPath`, which the card
/// and the dispatch's vision branch share). Absolute v1 records keep
/// reading forever — the readers tolerate both forms.
final class RealmChatMediaShare {
  RealmChatMediaShare({required this.worldHome});
  final Directory worldHome;

  /// Picks one image and materializes it as a media attachment entry,
  /// or null when the human canceled. Throws `NoteAssetException`-free
  /// named refusals as [RealmMediaShareException].
  Future<Map<String, Object?>?> pickAndBuild({
    required final String threadId,
  }) async {
    if (kIsWeb) {
      throw const RealmMediaShareException('media_share_unsupported_on_web');
    }
    final result = await FilePicker.pickFiles(type: FileType.image);
    if (result == null || result.files.isEmpty) return null;
    final picked = result.files.first;
    final bytes = await picked.readAsBytes();
    return buildFromBytes(
      bytes: bytes,
      threadId: threadId,
      nameHint: picked.name,
    );
  }

  /// Builds the attachment entry from raw bytes (the paste path).
  Future<Map<String, Object?>> buildFromBytes({
    required final List<int> bytes,
    required final String threadId,
    final String? nameHint,
  }) async {
    final asBytes = bytes is Uint8List ? bytes : Uint8List.fromList(bytes);
    final meta = sniffAssetMedia(asBytes, byteLength: asBytes.length);
    if (meta == null) {
      throw const RealmMediaShareException('media_share_not_media');
    }
    final assetId = createId();
    final ext = switch (meta.mimeType) {
      'image/png' => 'png',
      'image/jpeg' => 'jpg',
      'image/webp' => 'webp',
      'image/gif' => 'gif',
      _ => nameHint != null && nameHint.contains('.')
          ? nameHint.split('.').last.toLowerCase()
          : 'img',
    };
    final dir = Directory('${worldHome.path}/assets/$threadId');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    final file = File('${dir.path}/$assetId.$ext');
    await file.writeAsBytes(asBytes, flush: true);
    final digest = crypto.sha256.convert(asBytes).toString().substring(0, 16);
    return buildMediaAttachment(
      // WORLD-RELATIVE (v1.1): the file lands inside the world tree;
      // the entry names it relative to the world home.
      path: 'assets/$threadId/$assetId.$ext',
      mimeType: meta.mimeType,
      byteLength: meta.byteLength,
      width: meta.width,
      height: meta.height,
      revision: digest,
    );
  }
}

/// A named human-share failure:
/// `media_share_unsupported_on_web` · `media_share_not_media`.
final class RealmMediaShareException implements Exception {
  const RealmMediaShareException(this.code);
  final String code;
  @override
  String toString() => code;
}
