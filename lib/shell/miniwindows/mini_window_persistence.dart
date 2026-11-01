/// Miniwindow persistence (ADR 0027 follow-up): the shell's storage
/// lane for open windows — the records in `shell.miniwindows.v1`, the
/// same SharedPreferences family as the tab strip. The controller
/// stays pure (no I/O); this class binds one to storage: restore on
/// boot, debounced save on change. An unresolvable id (a DM whose
/// actor was deleted) restores as nothing — skipped, never thrown.
library;

import 'dart:async';

import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:lastanswer/shell/miniwindows/mini_window.dart';

import 'package:shared_preferences/shared_preferences.dart';

/// The persisted-strip key, beside `shell.tabs.v1`.
const String kMiniWindowsPrefsKey = 'shell.miniwindows.v1';

/// Restore + debounced save for one [MiniWindowController].
final class MiniWindowPersistence {
  MiniWindowPersistence({this.prefsKey = kMiniWindowsPrefsKey});

  final String prefsKey;

  Timer? _saveTimer;
  VoidCallback? _boundListener;
  MiniWindowController? _boundController;
  var _restoring = false;

  /// Restores every persisted record the factory can still resolve;
  /// returns how many windows came back. Bad JSON or a bad record is
  /// skipped, never fatal.
  Future<int> restoreInto(
    final MiniWindowController controller,
    final MiniWindowSpec? Function(String id) specFor,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(prefsKey);
    if (raw == null || raw.isEmpty) return 0;
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on Object {
      return 0;
    }
    if (decoded is! List) return 0;
    var restored = 0;
    for (final entry in decoded) {
      try {
        final record = MiniWindowRecord.fromJson(entry);
        final spec = specFor(record.id);
        if (spec == null) continue;
        controller.restore(record, spec);
        restored++;
      } on Object {
        // One unreadable record never takes the shell down.
      }
    }
    return restored;
  }

  /// Binds a debounced save (500ms) to the controller's changes.
  void bind(final MiniWindowController controller) {
    if (_boundController != null) return;
    _boundController = controller;
    _boundListener = () {
      _saveTimer?.cancel();
      _saveTimer = Timer(const Duration(milliseconds: 500), _save);
    };
    controller.addListener(_boundListener!);
  }

  Future<void> _save() async {
    final controller = _boundController;
    if (controller == null || _restoring) return;
    final prefs = await SharedPreferences.getInstance();
    final payload = [
      for (final record in controller.records) record.toJson(),
    ];
    await prefs.setString(prefsKey, jsonEncode(payload));
  }

  /// Releases the listener and the pending timer (the shell's dispose).
  void dispose() {
    _saveTimer?.cancel();
    final controller = _boundController;
    final listener = _boundListener;
    if (controller != null && listener != null) {
      controller.removeListener(listener);
    }
    _boundController = null;
    _boundListener = null;
  }
}
