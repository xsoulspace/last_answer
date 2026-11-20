// ignore_for_file: lines_longer_than_80_chars

/// Native-image-assets WAVE D2 — the media card contract: the
/// `asset-media v1` header parses (alt body consumed), relative paths
/// resolve only against a known root, the pixels render FROM THE FILE,
/// a missing file shows the honest placeholder (never a crash, never
/// silence), and the alt text is the accessibility label.
library;

import 'package:lastanswer/common_imports.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/ui_chat/media_asset_card.dart';

const header = 'asset-media v1 mime=image/png bytes=312 width=1024 '
    'height=768 alt=none rev=0123456789abcdef by=scout '
    'file:generated/img-1.png;';

void main() {
  group('MediaBeat.tryParse', () {
    test('the header parses with dims and an honest alt absence', () {
      final beat = MediaBeat.tryParse(header);
      expect(beat, isNotNull);
      expect(beat!.provenance.mimeType, 'image/png');
      expect(beat.provenance.width, 1024);
      expect(beat.provenance.height, 768);
      expect(beat.provenance.path, 'generated/img-1.png');
      expect(beat.provenance.revision, '0123456789abcdef');
      expect(beat.altText, isNull);
    });

    test('a caption on the body rides as the alt text', () {
      const captioned = 'asset-media v1 mime=image/png bytes=312 '
          'width=1024 height=768 alt=text rev=0123456789abcdef by=scout '
          'file:generated/img-1.png;';
      final beat = MediaBeat.tryParse('$captioned\na lighthouse at dawn');
      expect(beat!.altText, 'a lighthouse at dawn');
      // alt=none NEVER lies about a caption, even with a body present.
      expect(MediaBeat.tryParse('$header\nplain text below')!.altText,
          isNull);
    });

    test('non-media text parses as null (the text path stays text)', () {
      expect(MediaBeat.tryParse('a plain message'), isNull);
      expect(MediaBeat.tryParse('asset-map v1 sections=3'), isNull);
    });
  });

  group('resolveMediaPath', () {
    test('absolute paths pass through; relative need the root', () {
      expect(resolveMediaPath('/tmp/x.png'), '/tmp/x.png');
      expect(resolveMediaPath('generated/x.png'), isNull);
      expect(
        resolveMediaPath('generated/x.png', rootOverride: '/ws'),
        '/ws/generated/x.png',
      );
      expect(
        resolveMediaPath('generated/x.png', rootOverride: '  '),
        isNull,
      );
    });
  });

  group('MediaAssetCard (widget)', () {
    testWidgets('a missing file shows the honest placeholder with '
        'metadata, never a crash', (final tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MediaAssetCard(
              mimeType: 'image/png',
              byteLength: 312,
              width: 1024,
              height: 768,
              altText: null,
              absPath: '/definitely/not/here.png',
              revision: '0123456789abcdef',
            ),
          ),
        ),
      );
      expect(find.byKey(const ValueKey('media.asset.0123456789abcdef')),
          findsOneWidget);
      // The placeholder names the truth once; no pixels pretend.
      expect(find.textContaining('file not resolved'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('an unresolvable (null) path renders the placeholder too',
        (final tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MediaAssetCard(
              mimeType: 'image/jpeg',
              byteLength: 40,
              width: 0,
              height: 0,
              altText: null,
              absPath: null,
              revision: 'aaaaaaaaaaaaaaaa',
            ),
          ),
        ),
      );
      expect(find.textContaining('file not resolved'), findsOneWidget);
      expect(find.textContaining('image/jpeg'), findsWidgets);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('the alt text is the semantics label and the caption',
        (final tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MediaAssetCard(
              mimeType: 'image/png',
              byteLength: 312,
              width: 1024,
              height: 768,
              altText: 'a lighthouse at dawn',
              absPath: null,
              revision: 'aaaaaaaaaaaaaaaa',
            ),
          ),
        ),
      );
      expect(find.text('a lighthouse at dawn'), findsOneWidget);
      final semantics = tester.getSemantics(
        find.byKey(const ValueKey('media.asset.aaaaaaaaaaaaaaaa')),
      );
      expect(semantics.label, 'a lighthouse at dawn');
    });

    test('a LA-local attachment row maps into the card honestly', () {
      // The pixels-from-file branch is one Image.file call whose real
      // decode cannot run under the widget-test fake zone (it hangs,
      // two patterns tried) — the card's OWN decisions are the
      // contract: the LA row maps field-for-field, no invention.
      final card = MediaAssetCard.fromNoteAsset(
        asset: const NoteAssetModel(
          id: 'asset-9',
          path: 'note-assets/n1/asset-9.png',
          mime: 'image/webp',
          alt: 'a sketch',
          width: 640,
          height: 480,
          bytes: 2048,
        ),
        absPath: '/docs/note-assets/n1/asset-9.png',
      );
      expect(card.absPath, '/docs/note-assets/n1/asset-9.png');
      expect(card.mimeType, 'image/webp');
      expect(card.altText, 'a sketch');
      expect(card.revision, 'asset-9');
      expect(card.width, 640);
      expect(card.height, 480);
    });
  });

  group('MediaAssetCard.fromBeat', () {
    test('a beat with a known root builds a card at the resolved path', () {
      final card = MediaAssetCard.fromBeat(
        MediaBeat.tryParse(header)!,
        rootOverride: '/ws',
      );
      expect(card.absPath, '/ws/generated/img-1.png');
      expect(card.altText, isNull);
    });
  });
}
