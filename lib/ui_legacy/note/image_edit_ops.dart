/// Deterministic image edits (native-image-assets Wave D3, LA ADR 0029)
/// — pure bytes→bytes functions, no model, no platform channel. Every
/// result is NEW bytes the caller writes to a NEW file: the original
/// never mutates (the asset plane's generation law, mirrored in the
/// app). Generative edits ride `ImageGenerationService` instead — no
/// second lane here.
library;

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:image/image.dart' as img;
import 'package:xsoulspace_agentic_harness/xsoulspace_agentic_harness.dart'
    show sniffAssetMedia;

/// One annotation stroke — STROKES ARE DATA: points in preview-image
/// pixel space, an opaque ARGB color, a width. The editor renders them
/// as a vector overlay (ink stays vector in the widget) and only the
/// explicit export bakes them into a new file.
final class ImageStroke {
  const ImageStroke({
    required this.points,
    required this.color,
    required this.width,
  });
  final List<ui.Offset> points;
  final int color;
  final double width;

  ImageStroke offsetBy(final double dx, final double dy) => ImageStroke(
    points: [
      for (final p in points) ui.Offset(p.dx + dx, p.dy + dy),
    ],
    color: color,
    width: width,
  );
}

/// The named deterministic ops the editor exposes. Each answers NEW
/// bytes (a new generation) or throws [ImageEditException] by name.
enum ImageEditOp { rotateClockwise, rotateCounterClockwise, cropCenterSquare }

/// Applies [op] to [bytes]. The mime survives: png in → png out (jpeg
/// input encodes back to jpeg at quality 92 so rotation of photos does
/// not balloon).
Uint8List applyDeterministicOp(final Uint8List bytes, final ImageEditOp op) {
  final meta = sniffAssetMedia(bytes, byteLength: bytes.length);
  if (meta == null) {
    throw const ImageEditException('image_edit_not_media');
  }
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    throw const ImageEditException('image_edit_decode_failed');
  }
  final img.Image edited;
  switch (op) {
    case ImageEditOp.rotateClockwise:
      edited = img.copyRotate(decoded, angle: 90);
    case ImageEditOp.rotateCounterClockwise:
      edited = img.copyRotate(decoded, angle: -90);
    case ImageEditOp.cropCenterSquare:
      final side = decoded.width < decoded.height
          ? decoded.width
          : decoded.height;
      edited = img.copyCrop(
        decoded,
        x: (decoded.width - side) ~/ 2,
        y: (decoded.height - side) ~/ 2,
        width: side,
        height: side,
      );
  }
  return meta.mimeType == 'image/jpeg'
      ? img.encodeJpg(edited, quality: 92)
      : img.encodePng(edited);
}

/// Bakes [strokes] over the image into NEW bytes (the export path of
/// the annotate mode). The preview keeps the same strokes as a vector
/// overlay; this is the ONE place they become pixels.
Future<Uint8List> applyStrokes({
  required final Uint8List bytes,
  required final List<ImageStroke> strokes,
}) async {
  if (strokes.isEmpty) return bytes;
  final meta = sniffAssetMedia(bytes, byteLength: bytes.length);
  if (meta == null) {
    throw const ImageEditException('image_edit_not_media');
  }
  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  final image = frame.image;
  try {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(
      recorder,
      ui.Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
    );
    // A cascade cannot wrap the stroke loop — the receiver rides as an
    // argument into the helper.
    // ignore: cascade_invocations
    canvas.drawImage(image, ui.Offset.zero, ui.Paint());
    _drawStrokes(canvas, strokes);
    final picture = recorder.endRecording();
    final rendered = await picture.toImage(image.width, image.height);
    final data = await rendered.toByteData(format: ui.ImageByteFormat.png);
    if (data == null) {
      throw const ImageEditException('image_edit_rasterize_failed');
    }
    return data.buffer.asUint8List();
  } finally {
    image.dispose();
  }
}

void _drawStrokes(final ui.Canvas canvas, final List<ImageStroke> strokes) {
  for (final stroke in strokes) {
    final paint = ui.Paint()
      ..color = ui.Color(stroke.color)
      ..strokeWidth = stroke.width
      ..strokeCap = ui.StrokeCap.round
      ..strokeJoin = ui.StrokeJoin.round
      ..style = ui.PaintingStyle.stroke;
    canvas.drawPath(ui.Path()..addPolygon(stroke.points, false), paint);
  }
}

/// A named deterministic-edit failure:
/// `image_edit_not_media` · `image_edit_decode_failed` ·
/// `image_edit_rasterize_failed` · `image_edit_generation_refused` —
/// the honest refusal shape, never a bare exception.
final class ImageEditException implements Exception {
  const ImageEditException(this.code);
  final String code;
  @override
  String toString() => code;
}
