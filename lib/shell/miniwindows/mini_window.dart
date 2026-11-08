/// The MiniWindow surface class (ADR 0027): ONE surface, THREE
/// presentations — a right-panel tab, a center tab, and a window.
/// This file supplies the surface model ([MiniWindowSpec]), the
/// presentation-independent controller ([MiniWindowController]) and the
/// v1 presentation: a floating in-app overlay ([MiniWindowLayer]) that
/// renders quiet Tufte windows above the app's child without any new
/// dependency. A later backing may drive real OS windows behind the
/// same controller interface; callers do not change (DESIGN §2–3:
/// hairline chrome, typography as hierarchy; §8: keys are the contract).
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:lastanswer/shell/shell_theme.dart';

/// A floating window request: a stable surface id, a title, the content
/// builder and the v1 fixed size. The id is the address every
/// presentation shares ('dm:iris', 'inspector') — re-opening an open id
/// focuses the existing window instead of duplicating it.
@immutable
class MiniWindowSpec {
  const MiniWindowSpec({
    required this.id,
    required this.title,
    required this.builder,
    this.initialSize = const Size(360, 280),
  });

  /// Stable surface id — the same vocabulary as the shell's surface
  /// ids. Equality and idempotency are by id.
  final String id;

  /// Small-caps title rendered in the window's title bar.
  final String title;

  /// The surface's content. Windows render it clipped, sized to the
  /// controller's current size (starting at [initialSize], resizable
  /// through the layer's corner handle).
  final WidgetBuilder builder;

  /// Window size at open. The user can resize afterwards; the size is
  /// never smaller than [MiniWindowLayer.minWindowSize].
  final Size initialSize;
}

/// Session-scoped state for the open miniwindows: the open specs, each
/// window's position and size, and the z-order (list order back →
/// front; focusing brings a window to the front). A plain
/// [ChangeNotifier] — no Provider scope, no store: the integrator
/// supplies it and owns persistence (ADR 0027) — [records] snapshots
/// the state for saving, [restore] brings a saved window back.
class MiniWindowController extends ChangeNotifier {
  final List<_MiniWindowRecord> _records = <_MiniWindowRecord>[];

  /// The open windows, back → front. The last entry is the front
  /// (focused) window and paints above the rest.
  List<MiniWindowSpec> get windows =>
      List<MiniWindowSpec>.unmodifiable(
        _records.map((record) => record.spec),
      );

  /// The id of the front (focused) window, or null when none is open.
  String? get frontId => _records.isEmpty ? null : _records.last.spec.id;

  /// Position of the window with [id], or null when it is not open.
  Offset? positionOf(final String id) => _record(id)?.position;

  /// Size of the window with [id], or null when it is not open.
  Size? sizeOf(final String id) => _record(id)?.size;

  /// Whether a window with [id] is open.
  bool contains(final String id) => _record(id) != null;

  /// Opens [spec], or — when a window with the same id is already open
  /// — focuses the existing window and keeps its original spec,
  /// position and size (idempotent on id).
  void open(final MiniWindowSpec spec) {
    final _MiniWindowRecord? existing = _record(spec.id);
    if (existing != null) {
      _bringToFront(existing);
      notifyListeners();
      return;
    }
    final double cascade = defaultCascade * _records.length;
    _records.add(
      _MiniWindowRecord(
        spec: spec,
        position: Offset(defaultLeft + cascade, defaultLeft + cascade),
      ),
    );
    notifyListeners();
  }

  /// Closes the window with [id]. Closing an unknown id is a no-op.
  void close(final String id) {
    final int index = _records.indexWhere((record) => record.spec.id == id);
    if (index < 0) {
      return;
    }
    _records.removeAt(index);
    notifyListeners();
  }

  /// Brings the window with [id] to the front. Focusing an unknown id
  /// is a no-op; focusing the already-front window does not notify.
  void focus(final String id) {
    final _MiniWindowRecord? record = _record(id);
    if (record == null || identical(_records.last, record)) {
      return;
    }
    _bringToFront(record);
    notifyListeners();
  }

  /// Repositions the window with [id]. Callers clamp with
  /// [MiniWindowLayer.clampPosition] — the controller has no parent
  /// bounds of its own. Moving an unknown id is a no-op.
  void moveTo(final String id, final Offset position) {
    final _MiniWindowRecord? record = _record(id);
    if (record == null) {
      return;
    }
    record.position = position;
    notifyListeners();
  }

  /// Resizes the window with [id], clamped up to the
  /// [MiniWindowLayer.minWindowSize] floor (the pure law a controller
  /// can enforce without parent bounds — growing past the layer's
  /// edges is clamped by [MiniWindowLayer.clampSize] at the handle).
  /// Resizing an unknown id is a no-op.
  void resize(final String id, final Size size) {
    final _MiniWindowRecord? record = _record(id);
    if (record == null) {
      return;
    }
    record.size = Size(
      math.max(size.width, MiniWindowLayer.minWindowSize.width),
      math.max(size.height, MiniWindowLayer.minWindowSize.height),
    );
    notifyListeners();
  }

  /// Persistence snapshot of the open windows, back → front; each
  /// record's [MiniWindowRecord.order] mirrors its list index (0 =
  /// back). Saving this list is the integrator's job (the shell owns
  /// storage, ADR 0027); it comes back through [restore].
  List<MiniWindowRecord> get records =>
      List<MiniWindowRecord>.unmodifiable(<MiniWindowRecord>[
        for (var i = 0; i < _records.length; i++)
          MiniWindowRecord(
            id: _records[i].spec.id,
            position: _records[i].position,
            size: _records[i].size,
            order: i,
          ),
      ]);

  /// Restores one saved window: opens [spec] when its
  /// [MiniWindowRecord.id] is not open, then applies the recorded
  /// position and size — the size clamped up through the
  /// [MiniWindowLayer.minWindowSize] floor, the z slot from
  /// [MiniWindowRecord.order] (0 = back; an order past the live stack
  /// lands at the front). Layer-bounds clamping stays with the layer
  /// (see [MiniWindowLayer.clampPosition]/[clampSize]); the controller
  /// stays pure — no storage, no bounds — so this is directly testable.
  void restore(final MiniWindowRecord record, final MiniWindowSpec spec) {
    final Size size = Size(
      math.max(record.size.width, MiniWindowLayer.minWindowSize.width),
      math.max(record.size.height, MiniWindowLayer.minWindowSize.height),
    );
    _MiniWindowRecord? existing = _record(record.id);
    if (existing == null) {
      existing = _MiniWindowRecord(spec: spec, position: record.position)
        ..size = size;
      _records.add(existing);
    } else {
      existing
        ..size = size
        ..position = record.position;
    }
    final int slot =
        math.min(math.max(record.order, 0), _records.length - 1);
    _records
      ..remove(existing)
      ..insert(slot, existing);
    notifyListeners();
  }

  void _bringToFront(final _MiniWindowRecord record) {
    _records
      ..remove(record)
      ..add(record);
  }

  _MiniWindowRecord? _record(final String id) {
    for (final _MiniWindowRecord record in _records) {
      if (record.spec.id == id) {
        return record;
      }
    }
    return null;
  }

  /// Left edge of the first window; every next window cascades by
  /// [defaultCascade].
  static const double defaultLeft = 24;

  /// Cascade step for each additionally opened window.
  static const double defaultCascade = 28;
}

/// Per-window session state. Size starts at the spec's
/// [MiniWindowSpec.initialSize] and changes through
/// [MiniWindowController.resize].
class _MiniWindowRecord {
  _MiniWindowRecord({required this.spec, required this.position})
      : size = spec.initialSize;

  final MiniWindowSpec spec;
  Size size;
  Offset position;
}

/// A persistence record for one open miniwindow: the plain JSON codec
/// the integrator saves (the shell owns storage — nothing here does
/// I/O) and hands back through [MiniWindowController.restore].
@immutable
class MiniWindowRecord {
  const MiniWindowRecord({
    required this.id,
    required this.position,
    required this.size,
    required this.order,
  });

  factory MiniWindowRecord.fromJson(final Map<String, Object?> json) =>
      MiniWindowRecord(
        id: json['id']! as String,
        position: Offset(
          (json['x']! as num).toDouble(),
          (json['y']! as num).toDouble(),
        ),
        size: Size(
          (json['w']! as num).toDouble(),
          (json['h']! as num).toDouble(),
        ),
        order: (json['order']! as num).toInt(),
      );

  /// The window's surface id (the [MiniWindowSpec.id]).
  final String id;

  /// The recorded top-left position (layer coordinates).
  final Offset position;

  /// The recorded size (may be below the floor; [restore] clamps it).
  final Size size;

  /// Back→front z slot as of the save (0 = back).
  final int order;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'x': position.dx,
        'y': position.dy,
        'w': size.width,
        'h': size.height,
        'order': order,
      };
}

/// The v1 window presentation: a Stack with the app's [child] below and
/// the open windows above it. Windows intercept gestures only inside
/// their own bounds; taps outside them fall through to [child] untouched.
///
/// The layer observes [controller] and rebuilds on every change. Chrome
/// is quiet by law (DESIGN §2–3): an opaque surface fill, one hairline
/// border, a small-caps title bar that doubles as the drag handle, and
/// a `✕` close. Windows clamp loosely into the layer's bounds — at
/// least [minVisible] px stay visible horizontally and the whole title
/// bar stays reachable vertically.
class MiniWindowLayer extends StatelessWidget {
  const MiniWindowLayer({
    required this.controller,
    required this.child,
    super.key,
  });

  final MiniWindowController controller;

  /// The app below the windows. Non-positioned in the Stack: it keeps
  /// its own sizing and keeps receiving every gesture a window does not
  /// cover.
  final Widget child;

  @override
  Widget build(final BuildContext context) => ListenableBuilder(
        listenable: controller,
        builder: (context, _) => LayoutBuilder(
          builder: (context, constraints) {
            final Size bounds = constraints.biggest;
            return Stack(
              key: const Key('miniwindow.layer'),
              children: <Widget>[
                child,
                for (final MiniWindowSpec spec in controller.windows)
                  _MiniWindowView(
                    key: Key('miniwindow.${spec.id}'),
                    controller: controller,
                    spec: spec,
                    bounds: bounds,
                  ),
              ],
            );
          },
        ),
      );

  /// Title bar height — the drag handle and the vertical clamp
  /// reserve.
  static const double titleBarHeight = 28;

  /// How much of a window must stay visible inside the parent,
  /// horizontally, when dragged (the loose clamp law).
  static const double minVisible = 56;

  /// The resize floor: a window never shrinks below 280×200 — the
  /// smallest size its content stays usable at.
  static const Size minWindowSize = Size(280, 200);

  /// The resize handle's hit area, at the window's bottom-right corner.
  static const double resizeHandleSize = 16;

  /// The resize clamp law, shared by the layer's resize handle,
  /// integrators and tests: the size never goes below [minWindowSize]
  /// and never grows past the window's top-left corner's remaining
  /// room — the right and bottom edges stay inside the parent bounds.
  static Size clampSize(
    final Size size,
    final Offset position,
    final Size bounds,
  ) {
    final double maxWidth =
        math.max(minWindowSize.width, bounds.width - position.dx);
    final double maxHeight =
        math.max(minWindowSize.height, bounds.height - position.dy);
    return Size(
      size.width.clamp(minWindowSize.width, maxWidth),
      size.height.clamp(minWindowSize.height, maxHeight),
    );
  }

  /// The one clamp law, shared by the layer's drag handler, integrators
  /// and tests: the window keeps at least [minVisible] px inside the
  /// parent horizontally and its whole title bar vertically.
  static Offset clampPosition(
    final Offset position,
    final Size size,
    final Size bounds,
  ) {
    final double upperX = math.max(0, bounds.width - minVisible);
    final double upperY = math.max(0, bounds.height - titleBarHeight);
    final double lowerX = math.min(minVisible - size.width, upperX);
    return Offset(
      position.dx.clamp(lowerX, upperX),
      position.dy.clamp(0, upperY),
    );
  }
}

/// One floating window: positioned and sized from the controller
/// state, absorbing gestures inside its bounds (tapping anywhere
/// focuses it) and clipping the spec's content below the title bar.
class _MiniWindowView extends StatelessWidget {
  const _MiniWindowView({
    required this.controller,
    required this.spec,
    required this.bounds,
    super.key,
  });

  final MiniWindowController controller;
  final MiniWindowSpec spec;
  final Size bounds;

  @override
  Widget build(final BuildContext context) {
    final Offset position = controller.positionOf(spec.id)!;
    final Size size = controller.sizeOf(spec.id)!;
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Positioned(
      left: position.dx,
      top: position.dy,
      width: size.width,
      height: size.height,
      child: GestureDetector(
        onTap: () => controller.focus(spec.id),
        behavior: HitTestBehavior.opaque,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border.all(
                color: colors.outlineVariant,
              ),
            ),
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: Column(
                    children: <Widget>[
                      _MiniWindowTitleBar(
                        controller: controller,
                        spec: spec,
                        bounds: bounds,
                      ),
                      Expanded(
                        child: ClipRect(child: Builder(builder: spec.builder)),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: _MiniWindowResizeHandle(
                    controller: controller,
                    spec: spec,
                    bounds: bounds,
                  ),
                ),
              ],
            ),
          ),
      ),
    );
  }
}

/// The title bar: the window's one drag handle, carrying the small-caps
/// title and the `✕` close. Dragging pans the window in [bounds]-
/// clamped steps ([MiniWindowLayer.clampPosition]).
class _MiniWindowTitleBar extends StatelessWidget {
  const _MiniWindowTitleBar({
    required this.controller,
    required this.spec,
    required this.bounds,
  });

  final MiniWindowController controller;
  final MiniWindowSpec spec;
  final Size bounds;

  @override
  Widget build(final BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (details) {
          final Offset? position = controller.positionOf(spec.id);
          final Size? size = controller.sizeOf(spec.id);
          if (position == null || size == null) {
            return;
          }
          controller.moveTo(
            spec.id,
            MiniWindowLayer.clampPosition(
              position + details.delta,
              size,
              bounds,
            ),
          );
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.move,
          child: Container(
            height: MiniWindowLayer.titleBarHeight,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    spec.title.toUpperCase(),
                    style: shellSectionLabel(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  key: Key('miniwindow.${spec.id}.close'),
                  behavior: HitTestBehavior.opaque,
                  onTap: () => controller.close(spec.id),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 7,
                      ),
                      child: Text('✕', style: shellSectionLabel(context)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

/// The bottom-right resize handle: a [resizeHandleSize] hit area whose
/// pan resizes the window through [MiniWindowController.resize], every
/// step clamped by [MiniWindowLayer.clampSize] (never below
/// [MiniWindowLayer.minWindowSize], never past the layer bounds). A
/// tap on it still falls through to the window's focus tap.
class _MiniWindowResizeHandle extends StatelessWidget {
  const _MiniWindowResizeHandle({
    required this.controller,
    required this.spec,
    required this.bounds,
  });

  final MiniWindowController controller;
  final MiniWindowSpec spec;
  final Size bounds;

  @override
  Widget build(final BuildContext context) {
    final Color color = Theme.of(context).colorScheme.outlineVariant;
    return GestureDetector(
      key: Key('miniwindow.${spec.id}.resize'),
      behavior: HitTestBehavior.opaque,
      onPanUpdate: (details) {
        final Offset? position = controller.positionOf(spec.id);
        final Size? size = controller.sizeOf(spec.id);
        if (position == null || size == null) {
          return;
        }
        controller.resize(
          spec.id,
          MiniWindowLayer.clampSize(size + details.delta, position, bounds),
        );
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeDownRight,
        child: SizedBox(
          width: MiniWindowLayer.resizeHandleSize,
          height: MiniWindowLayer.resizeHandleSize,
          // Quiet grip: two hairline diagonals in the outline color.
          child: CustomPaint(painter: _ResizeGripPainter(color: color)),
        ),
      ),
    );
  }
}

/// The grip's two diagonal hairlines (DESIGN §2–3: hairline chrome).
class _ResizeGripPainter extends CustomPainter {
  _ResizeGripPainter({required this.color});

  final Color color;

  @override
  void paint(final Canvas canvas, final Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = ShellTokens.hairline
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawLine(
        Offset(size.width - 4, 4),
        Offset(4, size.height - 4),
        paint,
      )
      ..drawLine(
        Offset(size.width - 4, size.height * 0.55),
        Offset(size.width * 0.55, size.height - 4),
        paint,
      );
  }

  @override
  bool shouldRepaint(final _ResizeGripPainter oldDelegate) =>
      oldDelegate.color != color;
}
