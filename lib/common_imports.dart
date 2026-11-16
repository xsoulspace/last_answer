// ignore: dangling_library_doc_comments
/// Consolidate imports that are common across the app.
///
/// ui-kit-rewrite 2026-11-16 (DESIGN.md v6 component-carrier law): the
/// Material export is GONE. `package:flutter/widgets.dart` supplies the
/// widgets-layer engine; the only Material surface left is the data-only
/// `show Icons, Colors` glyph/color constants (an allowlist of
/// engine-host files may import Material fully — see
/// tool/check_ui_gates.dart, `just ui-gates`). The kit
/// (`package:la_ui/la_ui.dart`) is the ONE component carrier: buttons,
/// fields, rows, menus, dialogs, toasts, toggles all come from there.

export 'dart:async';

export 'package:collection/collection.dart';
export 'package:core/core.dart';
export 'package:extra_alignments/extra_alignments.dart';
export 'package:flextras/flextras.dart';
export 'package:flutter/material.dart' show Colors, Icons, ThemeMode;
export 'package:flutter/cupertino.dart' show CupertinoPageRoute;
export 'package:flutter/services.dart';
export 'package:flutter/widgets.dart';
export 'package:flutter_hooks/flutter_hooks.dart' hide Dispose;
export 'package:flutter_portal/flutter_portal.dart';
export 'package:gap/gap.dart';
export 'package:go_router/go_router.dart';
export 'package:json_annotation/json_annotation.dart';
export 'package:la_ui/la_ui.dart';
export 'package:lastanswer/ui/la_ui_bridge.dart';
export 'package:provider/provider.dart';
export 'package:recase/recase.dart';
export 'package:rxdart/rxdart.dart';
export 'package:shared_models/shared_models.dart';
export 'package:universal_io/io.dart';
