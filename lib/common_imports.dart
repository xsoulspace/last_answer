// ignore: dangling_library_doc_comments
/// Consolidate imports that are common across the app.
///
/// ui-kit-rewrite 2026-11-16 (DESIGN.md v6 component-carrier law): the
/// Material export is GONE. `package:flutter/widgets.dart` supplies the
/// widgets-layer engine; the only Material surface left is the data-only
/// `show Icons, Colors` glyph/color constants (an allowlist of
/// engine-host files may import Material fully — see
/// tool/check_ui_gates.dart, `just ui-gates`). The kit
/// (`package:la_ui_kit/la_ui_kit.dart`) is the ONE component carrier: buttons,
/// fields, rows, menus, dialogs, toasts, toggles all come from there.

export 'dart:async';

export 'package:collection/collection.dart';
export 'package:cupertino_ui/cupertino_ui.dart' show CupertinoPageRoute;
export 'package:extra_alignments/extra_alignments.dart';
export 'package:flextras/flextras.dart';
export 'package:flutter/services.dart';
export 'package:flutter/widgets.dart';
export 'package:flutter_hooks/flutter_hooks.dart' hide Dispose;
export 'package:flutter_portal/flutter_portal.dart';
export 'package:gap/gap.dart';
export 'package:go_router/go_router.dart';
export 'package:json_annotation/json_annotation.dart';
// The former `package:core` data layer dissolved into the app's concern
// folders (ADR 0035): its barrels are re-exported here so callers keep one
// import. Localization (la_locale) rode the core barrel too — it is
// exported directly now.
export 'package:la_locale/la_locale.dart';
export 'package:la_ui_kit/la_ui_kit.dart';
export 'package:lastanswer/data_emoji/data_emoji.dart';
export 'package:lastanswer/data_monetization/data_monetization.dart';
export 'package:lastanswer/data_notifications/data_notifications.dart';
export 'package:lastanswer/data_projects/data_projects.dart';
export 'package:lastanswer/data_user/data_user.dart';
export 'package:lastanswer/foundation/foundation.dart';
export 'package:lastanswer/ui_root/la_ui_kit_bridge.dart';
export 'package:lastanswer/ui_root/ui_root.dart';
export 'package:material_ui/material_ui.dart' show Colors, Icons, ThemeMode;
export 'package:provider/provider.dart';
export 'package:recase/recase.dart';
export 'package:rxdart/rxdart.dart';
export 'package:universal_io/io.dart';
