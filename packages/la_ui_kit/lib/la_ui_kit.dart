/// LaUi — the Last Answer design-system kit (DESIGN.md v6 component-carrier
/// law): shadcn zinc discipline × Discord squircle grammar × Linear density.
///
/// The kit is widgets-layer only (flutter/widgets + painting + gestures +
/// flutter_portal); it never imports `package:flutter/material.dart`. Colors,
/// type, radii and motion come from [LaUiTheme] — registered once by the app
/// from the existing zinc palette, with standalone dark/light defaults.
///
/// Layer map:
/// - L0 tokens: [LaUiTheme], [LaUiThemeProvider].
/// - geometry: [SquircleShape], [squirclePath], [LaClipSquircle] (v6 squircle
///   law — continuous-curvature superellipse corners).
/// - L1 primitives: [LaPressable], [LaFocusRing], [LaButton], [LaRow],
///   [LaField], [LaTextArea], [LaMenuAnchor], [LaMenu], [LaSelect],
///   [LaDialog], [showLaDialog], [LaConfirm], [showLaConfirm], [LaSheet],
///   [showLaSheet], [LaToast], [LaTooltip], [LaSwitch], [LaCheckbox],
///   [LaRadio], [LaSlider], [LaSpinner], [LaProgress], [LaPill], [LaBadge],
///   [LaHairline], [LaBox], [LaScaffold], [LaTopBar], [LaScrollArea].
library;

export 'src/button.dart';
export 'src/chrome.dart';
export 'src/dialog.dart';
export 'src/field.dart';
export 'src/icons.dart';
export 'src/layout.dart';
export 'src/menu.dart';
export 'src/motion.dart';
export 'src/pill.dart';
export 'src/pressable.dart';
export 'src/progress.dart';
export 'src/row.dart';
export 'src/scroll.dart';
export 'src/select.dart';
export 'src/selectable.dart';
export 'src/slider.dart';
export 'src/squircle.dart';
export 'src/theme.dart';
export 'src/toast.dart';
export 'src/toggles.dart';
export 'src/tooltip.dart';
