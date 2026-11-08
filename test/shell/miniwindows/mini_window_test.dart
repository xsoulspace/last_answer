// The miniwindow surface class (ADR 0027): open/close/move/focus/resize
// as a plain ChangeNotifier, the floating layer's keys and chrome, the
// loose clamp + resize laws, the persistence record codec, and the
// layer's one courtesy to the app below — gestures outside window
// bounds pass straight through.
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:lastanswer/shell/miniwindows/mini_window.dart';

MiniWindowSpec _spec(
  final String id, {
  final String? title,
  final Size size = const Size(320, 220),
}) =>
    MiniWindowSpec(
      id: id,
      title: title ?? id.toUpperCase(),
      initialSize: size,
      builder: (context) => Text('content:$id'),
    );

Future<MiniWindowController> _pumpLayer(
  final WidgetTester tester, {
  final Widget child = const SizedBox.expand(),
}) async {
  final MiniWindowController controller = MiniWindowController();
  addTearDown(controller.dispose);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: MiniWindowLayer(controller: controller, child: child),
      ),
    ),
  );
  return controller;
}

Finder _window(final String id) => find.byKey(Key('miniwindow.$id'));

/// Center of a window's title bar in tester coordinates.
Offset _titleBarCenter(final Rect windowRect) =>
    windowRect.topLeft +
    Offset(windowRect.width / 2, MiniWindowLayer.titleBarHeight / 2);

void main() {
  group('controller (plain ChangeNotifier)', () {
    test('open adds the spec; position cascades', () {
      final MiniWindowController controller = MiniWindowController();
      addTearDown(controller.dispose);
      controller
        ..open(_spec('a'))
        ..open(_spec('b'));
      expect(controller.windows.map((w) => w.id), ['a', 'b']);
      expect(controller.positionOf('a'), const Offset(24, 24));
      expect(controller.positionOf('b'), const Offset(52, 52));
      expect(controller.sizeOf('a'), const Size(320, 220));
      expect(controller.frontId, 'b');
    });

    test('opening an open id keeps one window and focuses it', () {
      final MiniWindowController controller = MiniWindowController();
      addTearDown(controller.dispose);
      controller
        ..open(_spec('a'))
        ..open(_spec('b'))
        ..open(_spec('a', title: 'A-AGAIN'));
      expect(controller.windows.map((w) => w.id), ['b', 'a']);
      expect(controller.frontId, 'a');
      // The original spec is kept — idempotent on id, not a replacement.
      final MiniWindowSpec kept = controller.windows
          .singleWhere((w) => w.id == 'a');
      expect(kept.title, 'A');
    });

    test('close removes; unknown ids are no-ops', () {
      final MiniWindowController controller = MiniWindowController();
      addTearDown(controller.dispose);
      controller
        ..open(_spec('a'))
        ..close('a');
      expect(controller.windows, isEmpty);
      expect(controller.positionOf('a'), isNull);
      controller.close('missing');
      expect(controller.windows, isEmpty);
    });

    test('moveTo repositions; unknown ids are no-ops', () {
      final MiniWindowController controller = MiniWindowController();
      addTearDown(controller.dispose);
      controller
        ..open(_spec('a'))
        ..moveTo('a', const Offset(120, 80));
      expect(controller.positionOf('a'), const Offset(120, 80));
      controller.moveTo('missing', const Offset(1, 1));
      expect(controller.positionOf('a'), const Offset(120, 80));
    });

    test('clampPosition keeps a sliver and the title bar inside bounds', () {
      const Size size = Size(320, 220);
      const Size bounds = Size(800, 600);
      // Far off the left edge: at least minVisible px stay visible.
      expect(
        MiniWindowLayer.clampPosition(const Offset(-900, 0), size, bounds),
        Offset(MiniWindowLayer.minVisible - size.width, 0),
      );
      // Far off the right edge.
      expect(
        MiniWindowLayer.clampPosition(const Offset(5000, 0), size, bounds),
        Offset(bounds.width - MiniWindowLayer.minVisible, 0),
      );
      // Above and below: the title bar stays reachable.
      expect(
        MiniWindowLayer.clampPosition(const Offset(0, -40), size, bounds),
        Offset.zero,
      );
      expect(
        MiniWindowLayer.clampPosition(const Offset(0, 5000), size, bounds),
        Offset(0, bounds.height - MiniWindowLayer.titleBarHeight),
      );
      // A sane position passes through untouched.
      expect(
        MiniWindowLayer.clampPosition(const Offset(100, 100), size, bounds),
        const Offset(100, 100),
      );
    });
  });

  group('open (layer rendering)', () {
    testWidgets('a window renders with title, content and keys',
        (final tester) async {
      final MiniWindowController controller = await _pumpLayer(tester);
      controller.open(_spec('inspector', title: 'INSPECTOR'));
      await tester.pump();

      expect(find.byKey(const Key('miniwindow.layer')), findsOneWidget);
      expect(_window('inspector'), findsOneWidget);
      expect(
        find.byKey(const Key('miniwindow.inspector.close')),
        findsOneWidget,
      );
      expect(find.text('INSPECTOR'), findsOneWidget);
      expect(find.text('content:inspector'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('opening an open id renders one window, focused',
        (final tester) async {
      final MiniWindowController controller = await _pumpLayer(tester);
      controller
        ..open(_spec('a'))
        ..open(_spec('a', title: 'A-AGAIN'));
      await tester.pump();

      expect(_window('a'), findsOneWidget);
      expect(controller.windows.length, 1);
      expect(controller.frontId, 'a');
      // The original spec survived the idempotent re-open.
      expect(find.text('A'), findsOneWidget);
      expect(find.text('A-AGAIN'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('close', () {
    testWidgets('close removes the window from the layer',
        (final tester) async {
      final MiniWindowController controller = await _pumpLayer(tester);
      controller.open(_spec('a'));
      await tester.pump();
      expect(_window('a'), findsOneWidget);

      await tester.tap(find.byKey(const Key('miniwindow.a.close')));
      await tester.pump();

      expect(_window('a'), findsNothing);
      expect(controller.windows, isEmpty);
      expect(tester.takeException(), isNull);
    });
  });

  group('drag', () {
    testWidgets('a title-bar pan moves the window', (final tester) async {
      final MiniWindowController controller = await _pumpLayer(tester);
      controller.open(_spec('a'));
      await tester.pump();

      final Offset before = controller.positionOf('a')!;
      final Rect rect = tester.getRect(_window('a'));
      await tester.dragFrom(
        _titleBarCenter(rect),
        const Offset(120, 60),
      );
      await tester.pump();

      final Offset after = controller.positionOf('a')!;
      expect(after.dx, greaterThan(before.dx));
      expect(after.dy, greaterThan(before.dy));
      expect(after.dx, closeTo(before.dx + 120, 40));
      expect(after.dy, closeTo(before.dy + 60, 40));
      expect(tester.takeException(), isNull);
    });

    testWidgets('the drag stays clamped into the layer bounds',
        (final tester) async {
      final MiniWindowController controller = await _pumpLayer(tester);
      controller.open(_spec('a'));
      await tester.pump();

      final Size bounds =
          tester.getSize(find.byKey(const Key('miniwindow.layer')));
      const Size size = Size(320, 220);

      // Far past the bottom first: the title bar stays reachable.
      Rect rect = tester.getRect(_window('a'));
      await tester.dragFrom(_titleBarCenter(rect), const Offset(0, 2000));
      await tester.pump();
      expect(
        controller.positionOf('a')!.dy,
        bounds.height - MiniWindowLayer.titleBarHeight,
      );

      // Then far past the left edge — the drag starts on the part of
      // the title bar that is still visible.
      rect = tester.getRect(_window('a'));
      await tester.dragFrom(_titleBarCenter(rect), const Offset(-2000, 0));
      await tester.pump();
      expect(
        controller.positionOf('a'),
        MiniWindowLayer.clampPosition(
          controller.positionOf('a')!,
          size,
          bounds,
        ),
      );
      expect(
        controller.positionOf('a')!.dx,
        MiniWindowLayer.minVisible - size.width,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('pass-through', () {
    testWidgets('taps outside window bounds reach the child',
        (final tester) async {
      int taps = 0;
      final MiniWindowController controller = await _pumpLayer(
        tester,
        child: Center(
          child: TextButton(
            key: const Key('underneath'),
            onPressed: () => taps++,
            child: const Text('underneath'),
          ),
        ),
      );
      controller.open(_spec('a'));
      await tester.pump();

      // The button sits at the layer's center, well clear of the window.
      await tester.tap(find.text('underneath'));
      await tester.pump();
      expect(taps, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a tap inside a window does not reach the child',
        (final tester) async {
      int taps = 0;
      final MiniWindowController controller = await _pumpLayer(
        tester,
        child: Align(
          alignment: Alignment.topLeft,
          child: TextButton(
            key: const Key('underneath'),
            onPressed: () => taps++,
            child: const Text('underneath'),
          ),
        ),
      );
      controller.open(_spec('a'));
      await tester.pump();

      // The button sits under the window's body — the window absorbs it.
      final Offset buttonCenter =
          tester.getCenter(find.byKey(const Key('underneath')));
      await tester.tapAt(buttonCenter);
      await tester.pump();
      expect(taps, 0);
      expect(controller.frontId, 'a');
      expect(tester.takeException(), isNull);
    });
  });

  group('focus (z-order)', () {
    testWidgets('focus brings a window to the front, last-focus first',
        (final tester) async {
      final MiniWindowController controller = await _pumpLayer(tester);
      controller
        ..open(_spec('a'))
        ..open(_spec('b'));
      await tester.pump();
      expect(controller.frontId, 'b');

      controller.focus('a');
      await tester.pump();
      expect(controller.frontId, 'a');
      expect(controller.windows.map((w) => w.id), ['b', 'a']);

      // The layer Stack paints the focused window last (above the rest).
      final Stack layerStack =
          tester.widget<Stack>(find.byKey(const Key('miniwindow.layer')));
      expect(layerStack.children.last.key, const Key('miniwindow.a'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('tapping a window focuses it', (final tester) async {
      final MiniWindowController controller = await _pumpLayer(tester);
      controller
        ..open(_spec('a'))
        ..open(_spec('b'));
      await tester.pump();
      expect(controller.frontId, 'b');

      // A point on a's title bar that b (cascaded +28,+28) does not
      // cover and that clears the ✕ close at the bar's right end.
      final Rect rectA = tester.getRect(_window('a'));
      await tester.tapAt(
        Offset(
          rectA.right - 60,
          rectA.top + MiniWindowLayer.titleBarHeight / 2,
        ),
      );
      await tester.pump();
      expect(controller.frontId, 'a');
      expect(tester.takeException(), isNull);
    });
  });

  group('resize (controller)', () {
    test('resize sets the size; unknown ids are no-ops', () {
      final MiniWindowController controller = MiniWindowController();
      addTearDown(controller.dispose);
      controller
        ..open(_spec('a'))
        ..resize('a', const Size(420, 300));
      expect(controller.sizeOf('a'), const Size(420, 300));
      controller.resize('missing', const Size(500, 500));
      expect(controller.sizeOf('a'), const Size(420, 300));
    });

    test('resize clamps up to the minWindowSize floor', () {
      final MiniWindowController controller = MiniWindowController();
      addTearDown(controller.dispose);
      controller
        ..open(_spec('a'))
        ..resize('a', const Size(40, 40));
      expect(controller.sizeOf('a'), MiniWindowLayer.minWindowSize);
      expect(MiniWindowLayer.minWindowSize, const Size(280, 200));
    });

    test('clampSize keeps the window above the floor and inside bounds',
        () {
      const Size bounds = Size(800, 600);
      const Offset position = Offset(24, 24);
      // Growing past the right/bottom edges stops at the edges.
      expect(
        MiniWindowLayer.clampSize(
          const Size(1200, 900),
          position,
          bounds,
        ),
        const Size(776, 576),
      );
      // Shrinking below the floor stops at minWindowSize.
      expect(
        MiniWindowLayer.clampSize(
          const Size(40, 40),
          position,
          bounds,
        ),
        MiniWindowLayer.minWindowSize,
      );
      // A sane resize passes through untouched.
      expect(
        MiniWindowLayer.clampSize(
          const Size(400, 300),
          Offset.zero,
          bounds,
        ),
        const Size(400, 300),
      );
    });
  });

  group('records (persistence codec)', () {
    test('json round-trips position, size and order', () {
      const MiniWindowRecord record = MiniWindowRecord(
        id: 'inspector',
        position: Offset(12, 34),
        size: Size(300, 240),
        order: 2,
      );
      final MiniWindowRecord restored = MiniWindowRecord.fromJson(
        (jsonDecode(jsonEncode(record.toJson())) as Map)
            .cast<String, Object?>(),
      );
      expect(restored.id, 'inspector');
      expect(restored.position, const Offset(12, 34));
      expect(restored.size, const Size(300, 240));
      expect(restored.order, 2);
    });

    test('the snapshot lists the open windows back→front with orders',
        () {
      final MiniWindowController controller = MiniWindowController();
      addTearDown(controller.dispose);
      controller
        ..open(_spec('a'))
        ..moveTo('a', const Offset(10, 20))
        ..resize('a', const Size(300, 240))
        ..open(_spec('b'));
      final List<MiniWindowRecord> records = controller.records;
      expect(records.map((r) => r.id).toList(), ['a', 'b']);
      expect(records[0].order, 0);
      expect(records[1].order, 1);
      expect(records[0].position, const Offset(10, 20));
      expect(records[0].size, const Size(300, 240));
      expect(records[1].size, const Size(320, 220));
    });
  });

  group('restore', () {
    MiniWindowRecord record0(
      final String id, {
      final Offset position = Offset.zero,
      final Size size = const Size(320, 220),
      final int order = 0,
    }) =>
        MiniWindowRecord(
          id: id,
          position: position,
          size: size,
          order: order,
        );

    test('opens an absent window with the recorded position, size and z',
        () {
      final MiniWindowController controller = MiniWindowController();
      addTearDown(controller.dispose);
      controller.restore(
        record0('a', position: const Offset(40, 60), size: const Size(300, 240)),
        _spec('a'),
      );
      expect(controller.contains('a'), isTrue);
      expect(controller.positionOf('a'), const Offset(40, 60));
      expect(controller.sizeOf('a'), const Size(300, 240));
      expect(controller.frontId, 'a');
    });

    test('a size below the floor clamps to minWindowSize', () {
      final MiniWindowController controller = MiniWindowController();
      addTearDown(controller.dispose);
      controller.restore(
        record0('a', size: const Size(100, 100)),
        _spec('a'),
      );
      expect(controller.sizeOf('a'), MiniWindowLayer.minWindowSize);
    });

    test('records rebuild the saved z order back→front', () {
      final MiniWindowController controller = MiniWindowController();
      addTearDown(controller.dispose);
      controller
        ..restore(record0('b'), _spec('b'))
        ..restore(record0('a', order: 1), _spec('a'));
      expect(controller.windows.map((w) => w.id).toList(), ['b', 'a']);
      expect(controller.frontId, 'a');

      // An order past the live stack lands at the front.
      controller.restore(record0('c', order: 9), _spec('c'));
      expect(controller.windows.map((w) => w.id).toList(), ['b', 'a', 'c']);
      expect(controller.frontId, 'c');

      // Order 0 slots at the back without disturbing the front.
      controller.restore(record0('d'), _spec('d'));
      expect(controller.windows.map((w) => w.id).toList(), [
        'd',
        'b',
        'a',
        'c',
      ]);
      expect(controller.frontId, 'c');
    });

    test('restoring an open id repositions and re-slots, never duplicates',
        () {
      final MiniWindowController controller = MiniWindowController();
      addTearDown(controller.dispose);
      controller
        ..open(_spec('a'))
        ..open(_spec('b'))
        ..restore(
          record0('a', position: const Offset(70, 70)),
          _spec('a', title: 'A-AGAIN'),
        );
      expect(controller.windows.length, 2);
      expect(controller.positionOf('a'), const Offset(70, 70));
      // Order 0 → back; the idempotent open keeps the original spec.
      expect(controller.windows.map((w) => w.id).toList(), ['a', 'b']);
      expect(
        controller.windows.singleWhere((w) => w.id == 'a').title,
        'A',
      );

      controller.restore(record0('a', order: 5), _spec('a'));
      expect(controller.windows.map((w) => w.id).toList(), ['b', 'a']);
      expect(controller.frontId, 'a');
    });
  });

  group('resize (handle)', () {
    testWidgets('the corner handle exists and pans the size',
        (final tester) async {
      final MiniWindowController controller = await _pumpLayer(tester);
      controller.open(_spec('a'));
      await tester.pump();

      final Finder handle = find.byKey(const Key('miniwindow.a.resize'));
      expect(handle, findsOneWidget);
      final Size before = controller.sizeOf('a')!;
      await tester.dragFrom(
        tester.getCenter(handle),
        const Offset(100, 80),
      );
      await tester.pump();

      final Size after = controller.sizeOf('a')!;
      expect(after.width, closeTo(before.width + 100, 40));
      expect(after.height, closeTo(before.height + 80, 40));
      expect(tester.takeException(), isNull);
    });

    testWidgets('growth past the layer bounds stops at the edges',
        (final tester) async {
      final MiniWindowController controller = await _pumpLayer(tester);
      controller.open(_spec('a'));
      await tester.pump();

      await tester.dragFrom(
        tester.getCenter(find.byKey(const Key('miniwindow.a.resize'))),
        const Offset(5000, 5000),
      );
      await tester.pump();

      final Size bounds =
          tester.getSize(find.byKey(const Key('miniwindow.layer')));
      // The window opened at (24, 24): its edges stop at the bounds.
      expect(
        controller.sizeOf('a'),
        Size(bounds.width - 24, bounds.height - 24),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('a shrink below the floor stops at minWindowSize',
        (final tester) async {
      final MiniWindowController controller = await _pumpLayer(tester);
      controller.open(_spec('a'));
      await tester.pump();

      await tester.dragFrom(
        tester.getCenter(find.byKey(const Key('miniwindow.a.resize'))),
        const Offset(-5000, -5000),
      );
      await tester.pump();

      expect(controller.sizeOf('a'), MiniWindowLayer.minWindowSize);
      expect(tester.takeException(), isNull);
    });
  });
}
