// ignore_for_file: lines_longer_than_80_chars

/// Native-image-assets WAVE D3 — the deterministic edit ops: every op
/// answers NEW bytes (a new generation), the input never mutates, and
/// the failures are named. The stroke bake turns DATA strokes into
/// pixels only at the explicit export.
library;

import 'dart:convert' show utf8;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:lastanswer/note/image_edit_ops.dart';

/// A VALID png (real CRC — the deterministic ops DECODE, so the
/// fixture must survive the image package's own checksum validation).
Uint8List pngBytes({int width = 64, int height = 48}) =>
    Uint8List.fromList(
      img.encodePng(img.Image(width: width, height: height)),
    );

int pngWidth(final Uint8List bytes) => (bytes[16] << 24) | (bytes[17] << 16) |
    (bytes[18] << 8) | bytes[19];
int pngHeight(final Uint8List bytes) => (bytes[20] << 24) | (bytes[21] << 16) |
    (bytes[22] << 8) | bytes[23];

void main() {
  group('applyDeterministicOp', () {
    test('rotate 90 swaps the dimensions and answers NEW bytes', () {
      final original = pngBytes();
      final rotated = applyDeterministicOp(
        original,
        ImageEditOp.rotateClockwise,
      );
      expect(pngWidth(rotated), 48);
      expect(pngHeight(rotated), 64);
      // The generation law: the original bytes are untouched.
      expect(pngWidth(original), 64);
      expect(pngHeight(original), 48);
      expect(rotated, isNot(original));
    });

    test('counter-clockwise rotation swaps back', () {
      final original = pngBytes();
      final once = applyDeterministicOp(
        original,
        ImageEditOp.rotateCounterClockwise,
      );
      expect(pngWidth(once), 48);
      final back = applyDeterministicOp(once, ImageEditOp.rotateClockwise);
      expect(pngWidth(back), 64);
      expect(pngHeight(back), 48);
    });

    test('cropCenterSquare answers a square of the SHORT side', () {
      final rotated = applyDeterministicOp(
        pngBytes(),
        ImageEditOp.cropCenterSquare,
      );
      expect(pngWidth(rotated), 48);
      expect(pngHeight(rotated), 48);
    });

    test('a non-media input refuses by name', () {
      final text = Uint8List.fromList(utf8.encode('# not an image'));
      expect(
        () => applyDeterministicOp(text, ImageEditOp.rotateClockwise),
        throwsA(isA<ImageEditException>().having(
          (e) => e.code,
          'code',
          'image_edit_not_media',
        )),
      );
    });
  });

  group('applyStrokes', () {
    test('empty strokes return the input unchanged (no-op honest)',
        () async {
      final original = pngBytes();
      final baked = await applyStrokes(bytes: original, strokes: const []);
      expect(baked, same(original));
    });

    test('a stroke bakes into NEW png bytes at the image size', () async {
      final original = pngBytes();
      const stroke = ImageStroke(
        points: [
          Offset(2, 2),
          Offset(30, 20),
          Offset(60, 40),
        ],
        color: 0xffe53935,
        width: 4,
      );
      final baked = await applyStrokes(
        bytes: original,
        strokes: [stroke],
      );
      expect(pngWidth(baked), 64);
      expect(pngHeight(baked), 48);
      expect(baked, isNot(original));
      // The bake is a real png (the sniffable signature rides).
      expect(baked.sublist(0, 8), original.sublist(0, 8));
    });

    test('strokes stay DATA: offsetBy moves the points', () {
      const stroke = ImageStroke(
        points: [Offset(0, 0), Offset(10, 10)],
        color: 0xff000000,
        width: 2,
      );
      final moved = stroke.offsetBy(5, 7);
      expect(moved.points.first, const Offset(5, 7));
      expect(moved.points.last, const Offset(15, 17));
      expect(stroke.points.first, const Offset(0, 0));
    });
  });
}
