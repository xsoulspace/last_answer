/// The LA-side media planefor conversation beats and note attachments
/// (native-image-assets Wave D2, LA ADR 0029). ONE card renders BOTH
/// shapes honestly:
///
/// - a harness beat whose text is the `asset-media v1` sibling header
///   (Wave A's record — [AssetMediaProvenance.tryParse] is the owner of
///   that grammar; LA adds only the alt-body read), and
/// - a LA-local note attachment (`NoteAssetModel` metadata + a resolved
///   absolute path).
///
/// The law the card keeps: pixels render FROM THE FILE, never from the
/// record; an unresolvable or missing file shows the honest metadata
/// placeholder (mime · dimensions · size · alt) instead of pretending;
/// the alt text is the accessibility label — a text-only reader (or a
/// screen reader) gets the meaning, not silence.
library;

import 'package:flutter/widgets.dart';
import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';
import 'package:la_ui/la_ui.dart';
import 'package:universal_io/io.dart';
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart'
    show AssetMediaProvenance;

/// A parsed media beat: the header's provenance plus the derived alt
/// text when the header declares `alt=text` (the caption rides the beat
/// BODY under the header line).
final class MediaBeat {
  const MediaBeat({required this.provenance, this.altText});
  final AssetMediaProvenance provenance;

  /// The derived caption, when the header declared text and the body
  /// carries it. Null = honest absence (`alt=none`).
  final String? altText;

  static MediaBeat? tryParse(final String beatText) {
    final provenance = AssetMediaProvenance.tryParse(beatText);
    if (provenance == null) return null;
    final newline = beatText.indexOf('\n');
    if (!provenance.alt || newline < 0) {
      return MediaBeat(provenance: provenance);
    }
    final body = beatText.substring(newline + 1).trim();
    if (body.isEmpty) return MediaBeat(provenance: provenance);
    return MediaBeat(provenance: provenance, altText: body);
  }
}

/// Resolves a `file:` path from a beat against an optional sandbox root
/// override. Absolute paths pass through; relative paths need the root.
/// Null = not resolvable HERE (the honest placeholder).
String? resolveMediaPath(final String path, {final String? rootOverride}) {
  if (path.startsWith('/')) return path;
  final root = rootOverride?.trim() ?? '';
  if (root.isEmpty) return null;
  return '$root/$path';
}

/// One image asset rendered from the file, with the honest metadata
/// fallback. Compact by design: max width ~320, cover fit, a hairline
/// border on the surface grid, and a metadata line
/// (`png · 1024×768 · 47 kB`) that is useful even with pixels.
class MediaAssetCard extends StatelessWidget {
  const MediaAssetCard({
    required this.mimeType,
    required this.byteLength,
    required this.width,
    required this.height,
    required this.altText,
    required this.absPath,
    required this.revision,
    super.key,
  });

  /// Builds the card for a parsed harness beat; [rootOverride] is the
  /// sandbox root when the caller knows one (the agent-doc workspace),
  /// null leaves relative paths honestly unresolved (placeholder).
  factory MediaAssetCard.fromBeat(
    final MediaBeat beat, {
    final String? rootOverride,
  }) => MediaAssetCard(
    mimeType: beat.provenance.mimeType,
    byteLength: beat.provenance.byteLength,
    width: beat.provenance.width ?? 0,
    height: beat.provenance.height ?? 0,
    altText: beat.altText,
    absPath: resolveMediaPath(beat.provenance.path, rootOverride: rootOverride),
    revision: beat.provenance.revision,
  );

  /// Builds the card from a STRUCTURED `media v1` attachment map (the
  /// conversation-native vocabulary — the beat's attachments list).
  /// The dims/rev ride the entry, so this never sniffs or decodes to
  /// render a row (the scale law).
  factory MediaAssetCard.fromAttachment(
    final Map<String, Object?> attachment, {
    final String? rootOverride,
  }) {
    final path = attachment['path'];
    final mime = attachment['mimeType'];
    final bytes = attachment['byteLength'];
    final revision = attachment['revision'];
    final width = attachment['width'];
    final height = attachment['height'];
    final alt = attachment['alt'];
    return MediaAssetCard(
      mimeType: mime is String ? mime : 'application/octet-stream',
      byteLength: bytes is int ? bytes : 0,
      width: width is int ? width : 0,
      height: height is int ? height : 0,
      altText: alt is String && alt.isNotEmpty ? alt : null,
      absPath: path is String
          ? resolveMediaPath(path, rootOverride: rootOverride)
          : null,
      revision: revision is String && revision.isNotEmpty
          ? revision
          : 'unknown',
    );
  }

  /// Builds the card for a LA-local note attachment row.
  factory MediaAssetCard.fromNoteAsset({
    required final NoteAssetModel asset,
    required final String absPath,
  }) => MediaAssetCard(
    mimeType: asset.mime,
    byteLength: asset.bytes,
    width: asset.width,
    height: asset.height,
    altText: asset.alt.isEmpty ? null : asset.alt,
    absPath: absPath,
    revision: asset.id,
  );

  final String mimeType;
  final int byteLength;
  final int width;
  final int height;
  final String? altText;

  /// The absolute file path, or null when it cannot be resolved HERE
  /// (web, unknown sandbox root) — the honest placeholder, not silence.
  final String? absPath;

  /// The asset-plane revision (the harness's sha256-16 or the LA asset
  /// id) — the widget-key family so tests and agents address the card.
  final String revision;

  bool get _hasPixels => width > 0 && height > 0;

  String get _metaLine {
    final kb = (byteLength / 1024).round();
    final dims = _hasPixels ? '$width×$height · ' : '';
    return '$mimeType · $dims${kb < 1 ? '<1' : kb} kB';
  }

  @override
  Widget build(final BuildContext context) {
    final laUi = context.laUi;
    final border = BorderSide(color: laUi.rule);
    final path = absPath;
    final hasFile = path != null && File(path).existsSync();
    final Widget visual;
    if (hasFile) {
      visual = ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320, maxHeight: 240),
          child: Image.file(
            File(path),
            fit: BoxFit.cover,
            errorBuilder: (final context, _, _) => _Placeholder(
              mimeType: mimeType,
              metaLine: _metaLine,
              missingFile: true,
            ),
          ),
        ),
      );
    } else {
      visual = _Placeholder(mimeType: mimeType, metaLine: _metaLine);
    }
    return Semantics(
      label: altText ?? '$_metaLine (image)',
      container: true,
      explicitChildNodes: true,
      child: LaBox(
        key: ValueKey('media.asset.$revision'),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(6),
        border: border,
        radius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            visual,
            const SizedBox(height: 4),
            Text(
              altText ?? _metaLine,
              style: laUi.compact,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (altText != null) Text(_metaLine, style: laUi.micro),
          ],
        ),
      ),
    );
  }
}

/// The honest placeholder: named metadata, no pixels, no pretending.
class _Placeholder extends StatelessWidget {
  const _Placeholder({
    required this.mimeType,
    required this.metaLine,
    this.missingFile = false,
  });
  final String mimeType;
  final String metaLine;
  final bool missingFile;
  @override
  Widget build(final BuildContext context) {
    final laUi = context.laUi;
    return Container(
      width: 240,
      height: 120,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: laUi.surfaceRaised,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.image_outlined, size: 28),
          const SizedBox(height: 6),
          Text(
            missingFile ? metaLine : '$metaLine · file not resolved',
            style: laUi.micro,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
