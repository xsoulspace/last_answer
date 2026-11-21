import 'package:flutter/widgets.dart';

import 'icons.dart';
import 'motion.dart';
import 'pressable.dart';
import 'squircle.dart';
import 'theme.dart';

/// The kit switch: 36×20 track, 16 px thumb, 150 ms settle (v6). Replaces
/// Material Switch.
class LaSwitch extends StatelessWidget {
  /// A boolean toggle.
  const LaSwitch({
    required this.value,
    this.onChanged,
    this.enabled = true,
    this.semanticLabel,
    super.key,
  });

  /// On/off truth.
  final bool value;

  /// Toggle callback; null disables.
  final ValueChanged<bool>? onChanged;

  /// Explicit enabled flag (ANDed with [onChanged] presence).
  final bool enabled;

  /// Semantics label.
  final String? semanticLabel;

  @override
  Widget build(final BuildContext context) {
    final theme = context.laUi;
    final live = enabled && onChanged != null;
    final track = !live
        ? theme.surfaceRaised
        : value
        ? theme.accent
        : theme.surfaceOverlay;
    final thumb = !live
        ? theme.inkQuiet
        : value
        ? theme.onAccent
        : theme.inkMuted;
    return Semantics(
      toggled: value,
      enabled: live,
      label: semanticLabel,
      child: LaPressable(
        onTap: live ? () => onChanged?.call(!value) : null,
        enabled: live,
        radius: BorderRadius.circular(10),
        scaleOnPress: false,
        padding: EdgeInsets.zero,
        child: AnimatedContainer(
          duration: laMotion(context, theme.motionSettle),
          curve: theme.motionCurve,
          width: 36,
          height: 20,
          padding: const EdgeInsets.all(2),
          decoration: ShapeDecoration(
            color: track,
            shape: SquircleShape(
              radius: BorderRadius.circular(10),
              side: value ? BorderSide.none : BorderSide(color: theme.rule),
              exponent: theme.squircleExponent,
            ),
          ),
          child: AnimatedAlign(
            duration: laMotion(context, theme.motionSettle),
            curve: theme.motionCurve,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 16,
              height: 16,
              decoration: ShapeDecoration(
                color: thumb,
                shape: const SquircleShape(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The kit checkbox: 16 px squircle, accent fill + check glyph when on,
/// dash when tristate-null. Replaces Material Checkbox.
class LaCheckbox extends StatelessWidget {
  /// A boolean (or tristate) toggle.
  const LaCheckbox({
    required this.value,
    this.onChanged,
    this.tristate = false,
    this.enabled = true,
    this.size = 16,
    this.semanticLabel,
    super.key,
  });

  /// Checked truth (null = indeterminate when [tristate]).
  final bool? value;

  /// Toggle callback; null disables.
  final ValueChanged<bool?>? onChanged;

  /// Allow the null state in the cycle.
  final bool tristate;

  /// Explicit enabled flag.
  final bool enabled;

  /// Box edge length.
  final double size;

  /// Semantics label.
  final String? semanticLabel;

  void _next() {
    if (value == null) {
      onChanged?.call(true);
    } else if (value == true) {
      onChanged?.call(tristate ? null : false);
    } else {
      onChanged?.call(true);
    }
  }

  @override
  Widget build(final BuildContext context) {
    final theme = context.laUi;
    final live = enabled && onChanged != null;
    final on = value == true;
    final mixed = value == null;
    final radius = BorderRadius.circular(4);
    return Semantics(
      checked: on,
      mixed: mixed,
      enabled: live,
      label: semanticLabel,
      child: LaPressable(
        onTap: live ? _next : null,
        enabled: live,
        radius: radius,
        scaleOnPress: false,
        padding: const EdgeInsets.all(2),
        child: AnimatedContainer(
          duration: laMotion(context, theme.motionFast),
          width: size,
          height: size,
          decoration: squircleDecoration(
            color: (on || mixed)
                ? (live ? theme.accent : theme.surfaceRaised)
                : null,
            radius: radius,
            side: (on || mixed)
                ? null
                : BorderSide(color: live ? theme.inkQuiet : theme.rule),
            exponent: theme.squircleExponent,
          ),
          child: (on || mixed)
              ? Center(
                  child: on
                      ? LaCheck(
                          size: size - 4,
                          color: live ? theme.onAccent : theme.inkQuiet,
                        )
                      : Container(
                          width: size - 8,
                          height: 2,
                          color: live ? theme.onAccent : theme.inkQuiet,
                        ),
                )
              : null,
        ),
      ),
    );
  }
}

/// The kit radio: 16 px ring, accent dot when selected. Replaces Material
/// Radio.
class LaRadio<T> extends StatelessWidget {
  /// A single-choice option; pair with a shared [groupValue].
  const LaRadio({
    required this.value,
    required this.groupValue,
    this.onChanged,
    this.enabled = true,
    this.size = 16,
    this.semanticLabel,
    super.key,
  });

  /// This option's value.
  final T value;

  /// The group's current value.
  final T? groupValue;

  /// Selection callback; null disables.
  // ignore: unsafe_variance
  final ValueChanged<T?>? onChanged;

  /// Explicit enabled flag.
  final bool enabled;

  /// Outer diameter.
  final double size;

  /// Semantics label.
  final String? semanticLabel;

  @override
  Widget build(final BuildContext context) {
    final theme = context.laUi;
    final live = enabled && onChanged != null;
    final selected = value == groupValue;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      enabled: live,
      label: semanticLabel,
      child: LaPressable(
        onTap: live ? () => onChanged?.call(value) : null,
        enabled: live,
        radius: BorderRadius.circular(size / 2),
        scaleOnPress: false,
        padding: const EdgeInsets.all(2),
        child: AnimatedContainer(
          duration: laMotion(context, theme.motionFast),
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: !live
                  ? theme.rule
                  : selected
                  ? theme.accent
                  : theme.inkQuiet,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Center(
            child: AnimatedContainer(
              duration: laMotion(context, theme.motionFast),
              width: selected ? size - 8 : 0,
              height: selected ? size - 8 : 0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: live ? theme.accent : theme.inkQuiet,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
