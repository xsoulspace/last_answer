import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'chrome.dart';
import 'pressable.dart';
import 'theme.dart';

/// The kit's selection toolbar: a quiet floating row built from the engine's
/// own [ContextMenuButtonItem]s (cut/copy/paste/select-all), positioned at
/// the engine's context-menu anchors. Shared by [LaSelectableText] and the
/// LaField selection menu — the Material adaptive toolbar is banned by the
/// component-carrier law.
class LaSelectionToolbar extends StatelessWidget {
  /// A context menu for a text selection.
  const LaSelectionToolbar({
    required this.items,
    required this.anchors,
    required this.labelFor,
    super.key,
  });

  /// The engine-provided button items.
  final List<ContextMenuButtonItem> items;

  /// The engine-provided anchors (global overlay coordinates).
  final TextSelectionToolbarAnchors anchors;

  /// Localized label for a button type (the app feeds its l10n bundle).
  final String Function(ContextMenuButtonType type) labelFor;

  @override
  Widget build(final BuildContext context) {
    final theme = context.laUi;
    return Stack(
      children: [
        Positioned(
          top: anchors.primaryAnchor.dy,
          left: anchors.primaryAnchor.dx,
          child: FractionalTranslation(
            translation: const Offset(-0.5, -1.3),
            child: LaBox(
              color: theme.surfaceOverlay,
              radius: theme.smallRadius,
              border: BorderSide(color: theme.rule),
              floating: true,
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final item in items)
                    LaPressable(
                      onTap: item.onPressed,
                      radius: BorderRadius.circular(4),
                      scaleOnPress: false,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Text(
                        labelFor(item.type),
                        style: theme.compact.copyWith(color: theme.ink),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The kit's selection handles + toolbar controls for [SelectableRegion]
/// (the widgets-layer replacement for Material's selectable-text stack):
/// small accent circles as handles, [LaSelectionToolbar] as the menu.
class LaSelectableRegionControls extends TextSelectionControls {
  /// Kit selection controls.
  LaSelectableRegionControls();

  /// The shared instance.
  static final LaSelectableRegionControls instance =
      LaSelectableRegionControls();

  @override
  Size getHandleSize(final double textLineHeight) =>
      Size.square(textLineHeight * 0.75);

  @override
  Widget buildHandle(
    final BuildContext context,
    final TextSelectionHandleType type,
    final double textLineHeight, [
    final VoidCallback? onTap,
  ]) {
    final size = getHandleSize(textLineHeight);
    final theme = LaUiTheme.of(context);
    Widget handle = DecoratedBox(
      decoration: BoxDecoration(
        color: theme.accent,
        borderRadius: switch (type) {
          TextSelectionHandleType.left => const BorderRadius.only(
            bottomRight: Radius.circular(64),
          ),
          TextSelectionHandleType.right => const BorderRadius.only(
            bottomLeft: Radius.circular(64),
          ),
          _ => BorderRadius.circular(64),
        },
      ),
      child: SizedBox.fromSize(size: size),
    );
    if (onTap != null) {
      handle = GestureDetector(onTap: onTap, child: handle);
    }
    return handle;
  }

  @override
  Offset getHandleAnchor(
    final TextSelectionHandleType type,
    final double textLineHeight,
  ) {
    final size = getHandleSize(textLineHeight);
    return switch (type) {
      TextSelectionHandleType.left => Offset(size.width, 0),
      TextSelectionHandleType.right => Offset.zero,
      _ => Offset(size.width / 2, 0),
    };
  }

  @override
  // The toolbar rides SelectableRegion.contextMenuBuilder instead.
  // ignore: deprecated_member_use
  Widget buildToolbar(
    final BuildContext context,
    final Rect globalEditableRegion,
    final double textLineHeight,
    final Offset selectionMidpoint,
    final List<TextSelectionPoint> endpoints,
    final TextSelectionDelegate delegate,
    final ValueListenable<ClipboardStatus>? clipboardStatus,
    final Offset? lastSecondaryTapDownPosition,
  ) => const SizedBox.shrink();
}

/// Localized selection-toolbar labels — the app sets these ONCE at startup
/// from its l10n bundle (the kit ships honest English defaults). Shared by
/// LaField's context menu and [LaSelectableText].
class LaSelectionLabels {
  LaSelectionLabels._();

  /// "Cut" label.
  static String cut = 'Cut';

  /// "Copy" label.
  static String copy = 'Copy';

  /// "Paste" label.
  static String paste = 'Paste';

  /// "Select all" label.
  static String selectAll = 'Select all';

  /// Maps an engine button type to its localized label.
  static String labelFor(final ContextMenuButtonType type) => switch (type) {
    ContextMenuButtonType.cut => cut,
    ContextMenuButtonType.copy => copy,
    ContextMenuButtonType.paste => paste,
    ContextMenuButtonType.selectAll => selectAll,
    _ => '',
  };
}

/// Selectable body text (the widgets-layer replacement for Material's
/// SelectableText): a [SelectableRegion] over a styled [Text] — drag-select
/// and ⌘C work, no Material grammar.
class LaSelectableText extends StatefulWidget {
  /// Text the user can select and copy.
  const LaSelectableText(
    this.data, {
    this.style,
    this.textAlign,
    this.maxLines,
    this.semanticsLabel,
    super.key,
  });

  /// The text.
  final String data;

  /// Style override (defaults to the body token).
  final TextStyle? style;

  /// Alignment.
  final TextAlign? textAlign;

  /// Line cap.
  final int? maxLines;

  /// Semantics override.
  final String? semanticsLabel;

  @override
  State<LaSelectableText> createState() => _LaSelectableTextState();
}

class _LaSelectableTextState extends State<LaSelectableText> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final theme = context.laUi;
    return SelectableRegion(
      focusNode: _focusNode,
      selectionControls: LaSelectableRegionControls.instance,
      contextMenuBuilder: (context, state) => LaSelectionToolbar(
        items: state.contextMenuButtonItems,
        anchors: state.contextMenuAnchors,
        labelFor: LaSelectionLabels.labelFor,
      ),
      child: Text(
        widget.data,
        style: widget.style ?? theme.body,
        textAlign: widget.textAlign,
        maxLines: widget.maxLines,
        semanticsLabel: widget.semanticsLabel,
      ),
    );
  }
}

/// A selectable REGION over arbitrary children (the widgets-layer
/// replacement for Material's SelectionArea): drag-select and ⌘C across
/// any [child] subtree, kit selection handles + toolbar.
class LaSelectionArea extends StatefulWidget {
  /// Makes [child]'s text selectable.
  const LaSelectionArea({required this.child, super.key});

  /// The selectable subtree.
  final Widget child;

  @override
  State<LaSelectionArea> createState() => _LaSelectionAreaState();
}

class _LaSelectionAreaState extends State<LaSelectionArea> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => SelectableRegion(
    focusNode: _focusNode,
    selectionControls: LaSelectableRegionControls.instance,
    contextMenuBuilder: (context, state) => LaSelectionToolbar(
      items: state.contextMenuButtonItems,
      anchors: state.contextMenuAnchors,
      labelFor: LaSelectionLabels.labelFor,
    ),
    child: widget.child,
  );
}
