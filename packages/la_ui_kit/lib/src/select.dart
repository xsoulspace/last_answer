import 'package:flutter/widgets.dart';

import 'package:la_ui_kit/src/icons.dart';
import 'package:la_ui_kit/src/menu.dart';
import 'package:la_ui_kit/src/pressable.dart';
import 'package:la_ui_kit/src/theme.dart';
import 'package:la_ui_kit/src/tooltip.dart';

/// One [LaSelect] option.
@immutable
class LaSelectItem<T> {
  /// A select option.
  const LaSelectItem({
    required this.value,
    required this.label,
    this.icon,
    this.enabled = true,
  });

  /// The selected value.
  final T value;

  /// Row label.
  final String label;

  /// Optional leading glyph.
  final Widget? icon;

  /// False greys the option out.
  final bool enabled;
}

/// The kit select: a quiet trigger (label + chevron) opening an anchored
/// [LaMenu] listbox with check marks — the shadcn Select grammar. Replaces
/// DropdownButton and DropdownButtonFormField.
class LaSelect<T> extends StatelessWidget {
  /// A dropdown select over [items].
  const LaSelect({
    required this.items,
    this.value,
    this.onChanged,
    this.placeholder,
    this.size = LaSelectSize.md,
    this.expand = false,
    this.enabled = true,
    this.minWidth = 180,
    this.maxHeight = 352,
    this.emptyHint,
    this.labelBuilder,
    super.key,
  });

  /// The options.
  final List<LaSelectItem<T>> items;

  /// Current value (null shows [placeholder]).
  final T? value;

  /// Selection callback; null disables.
  // ignore: unsafe_variance
  final ValueChanged<T?>? onChanged;

  /// Shown when [value] is null.
  final String? placeholder;

  /// Height step (md = 34, sm = 28).
  final LaSelectSize size;

  /// Fill the incoming width.
  final bool expand;

  /// False greys the trigger out.
  final bool enabled;

  /// Minimum popover width.
  final double minWidth;

  /// Height cap for the popover list (the shadcn dropdown law — Radix's
  /// 22rem): longer lists scroll instead of growing past the window.
  /// Null grows freely.
  final double? maxHeight;

  /// Tooltip naming the missing capability when [items] is empty — the
  /// honest-DISABLED law (DESIGN v4 §6): the trigger greys out and says why
  /// instead of opening a zero-row menu sliver.
  final String? emptyHint;

  /// Custom trigger label rendering.
  // ignore: unsafe_variance
  final Widget Function(T value)? labelBuilder;

  LaSelectItem<T>? get _selected {
    for (final item in items) {
      if (item.value == value) {
        return item;
      }
    }
    return null;
  }

  @override
  Widget build(final BuildContext context) {
    final theme = context.laUi;
    // No options: nothing to choose, so the trigger goes dormant (and
    // names the gap via [emptyHint]) rather than opening an empty menu.
    final interactive = enabled && onChanged != null && items.isNotEmpty;
    final height = size == LaSelectSize.sm ? 28.0 : 34.0;

    Widget trigger({required final bool live, final VoidCallback? onTap}) =>
        LaPressable.builder(
          onTap: onTap,
          enabled: live,
          cursor: live ? SystemMouseCursors.click : null,
          fill: theme.fieldFill,
          border: BorderSide(color: theme.rule),
          radius: theme.controlRadius,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          childBuilder: (context, state) => SizedBox(
            height: height,
            width: expand ? double.infinity : null,
            child: Row(
              mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
              children: [
                Expanded(child: _label(theme, live)),
                const SizedBox(width: 8),
                LaChevron(color: live ? theme.inkMuted : theme.inkQuiet),
              ],
            ),
          ),
        );

    if (!interactive) {
      final dormant = trigger(live: false);
      if (emptyHint == null) {
        return dormant;
      }
      return LaTooltip(message: emptyHint!, child: dormant);
    }

    return LaMenuAnchor.builder(
      minWidth: minWidth,
      maxHeight: maxHeight,
      alignRight: expand,
      childBuilder: (context, anchor) =>
          trigger(onTap: anchor.toggle, live: true),
      entries: [
        for (final item in items)
          LaMenuItem(
            label: item.label,
            icon: item.icon,
            enabled: item.enabled,
            checked: item.value == value,
            onPressed: item.enabled ? () => onChanged?.call(item.value) : null,
          ),
      ],
    );
  }

  Widget _label(final LaUiTheme theme, final bool live) {
    final selected = _selected;
    if (selected == null) {
      return Text(
        placeholder ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.control.copyWith(color: theme.inkQuiet),
      );
    }
    final custom = labelBuilder?.call(selected.value);
    if (custom != null) {
      return custom;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (selected.icon != null) ...[
          IconTheme.merge(
            data: IconThemeData(size: 14, color: theme.inkMuted),
            child: selected.icon!,
          ),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Text(
            selected.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.control.copyWith(
              color: live ? theme.ink : theme.inkQuiet,
            ),
          ),
        ),
      ],
    );
  }
}

/// Select height step.
enum LaSelectSize { sm, md }
