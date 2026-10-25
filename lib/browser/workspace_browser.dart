/// The embedded browser window: an address bar, navigation controls, and a
/// page area that renders anything the embedded engine supports.
///
/// The window is a general browser, not a React renderer and not a Dart
/// compiler: it shows web pages. It never runs or compiles project code, and
/// it never starts a server — whoever owns a server owns its lifecycle.
///
/// The design follows DESIGN.md: no cards, no filled buttons, no decorative
/// chrome. One grid, hairlines instead of boxes, small-caps labels, and
/// stable widget keys (`browser.*`) as the agent-facing contract.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:lastanswer/browser/browser_address.dart';
import 'package:lastanswer/browser/browser_bridge.dart';
import 'package:lastanswer/browser/browser_strings.dart';
import 'package:lastanswer/browser/browser_view.dart';
import 'package:lastanswer/browser/browser_windows.dart';
import 'package:lastanswer/browser/native_browser_view.dart';

/// A general embedded browser window.
class WorkspaceBrowser extends StatefulWidget {
  const WorkspaceBrowser({super.key, this.initialUrl, this.viewBuilder});

  /// The address opened when the window mounts, when given.
  ///
  /// It is only opened if it is a navigable `http`/`https` address.
  final Uri? initialUrl;

  /// Builds the page area. Defaults to the native embedded view; widget
  /// tests inject a fake.
  final BrowserViewBuilder? viewBuilder;

  @override
  State<WorkspaceBrowser> createState() => _WorkspaceBrowserState();
}

class _WorkspaceBrowserState extends State<WorkspaceBrowser> {
  final BrowserBridge _bridge = BrowserBridge();
  late final String _windowId;
  late final TextEditingController _address = TextEditingController(
    text: widget.initialUrl?.toString() ?? '',
  );
  late final FocusNode _addressFocus = FocusNode();
  bool _canGoBack = false;
  bool _canGoForward = false;

  @override
  void initState() {
    super.initState();
    _windowId = BrowserWindows.register(_bridge);
    _bridge.addListener(_onBridgeChanged);
    final initial = widget.initialUrl;
    if (initial != null && isNavigableAddress(initial)) {
      // Primed, not loaded: the view takes the pending address (native
      // views open it directly; test views load it when they attach), so
      // the page is opened exactly once.
      _bridge.primeUrl(initial);
    }
  }

  @override
  void dispose() {
    BrowserWindows.unregister(_windowId);
    _bridge.removeListener(_onBridgeChanged);
    _address.dispose();
    _addressFocus.dispose();
    super.dispose();
  }

  void _onBridgeChanged() {
    if (!mounted) return;
    final url = _bridge.url;
    if (url != null && !_addressFocus.hasFocus) {
      final text = url.toString();
      if (_address.text != text) {
        _address.value = TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      }
    }
    setState(() {});
    unawaited(_refreshHistoryFlags());
  }

  Future<void> _refreshHistoryFlags() async {
    final back = await _bridge.canGoBack();
    final forward = await _bridge.canGoForward();
    if (!mounted) return;
    setState(() {
      _canGoBack = back;
      _canGoForward = forward;
    });
  }

  void _openTypedAddress() {
    final strings = BrowserStrings.of(context);
    final parsed = parseBrowserAddress(_address.text);
    if (!parsed.isAccepted) {
      final unsupported =
          parsed.rejection == BrowserAddressRejection.unsupportedScheme;
      _bridge.reportError(
        unsupported ? strings.unsupportedAddress : strings.malformedAddress,
      );
      return;
    }
    _bridge
      ..reportError(null)
      ..load(parsed.url!);
    unawaited(_refreshHistoryFlags());
  }

  @override
  Widget build(BuildContext context) {
    final strings = BrowserStrings.of(context);
    final theme = Theme.of(context);
    final viewBuilder = widget.viewBuilder ?? buildNativeBrowserView;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AddressRow(
          controller: _address,
          focusNode: _addressFocus,
          strings: strings,
          onSubmit: _openTypedAddress,
        ),
        Divider(height: 0.6, color: theme.dividerColor),
        _ControlRow(
          strings: strings,
          canGoBack: _canGoBack,
          canGoForward: _canGoForward,
          onBack: () async {
            await _bridge.goBack();
            await _refreshHistoryFlags();
          },
          onForward: () async {
            await _bridge.goForward();
            await _refreshHistoryFlags();
          },
          onReload: () async {
            await _bridge.reload();
            await _refreshHistoryFlags();
          },
        ),
        Divider(height: 0.6, color: theme.dividerColor),
        _ProgressLine(progress: _bridge.progress, loading: _bridge.isLoading),
        _TitleLine(title: _bridge.title, url: _bridge.url),
        if (_bridge.error != null)
          _ErrorLine(message: _bridge.error!, strings: strings),
        Expanded(child: viewBuilder(context, _bridge)),
      ],
    );
  }
}

class _AddressRow extends StatelessWidget {
  const _AddressRow({
    required this.controller,
    required this.focusNode,
    required this.strings,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final BrowserStrings strings;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            key: const Key('browser.address'),
            controller: controller,
            focusNode: focusNode,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: strings.addressHint,
              hintStyle: TextStyle(
                color: Theme.of(context).hintColor,
                fontSize: 12,
              ),
            ),
            onSubmitted: (_) => onSubmit(),
          ),
        ),
        TextButton(
          key: const Key('browser.go'),
          onPressed: onSubmit,
          child: Text(strings.go),
        ),
      ],
    ),
  );
}

class _ControlRow extends StatelessWidget {
  const _ControlRow({
    required this.strings,
    required this.canGoBack,
    required this.canGoForward,
    required this.onBack,
    required this.onForward,
    required this.onReload,
  });

  final BrowserStrings strings;
  final bool canGoBack;
  final bool canGoForward;
  final VoidCallback onBack;
  final VoidCallback onForward;
  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: Row(
      children: [
        TextButton(
          key: const Key('browser.back'),
          onPressed: canGoBack ? onBack : null,
          child: Text(strings.back),
        ),
        TextButton(
          key: const Key('browser.forward'),
          onPressed: canGoForward ? onForward : null,
          child: Text(strings.forward),
        ),
        TextButton(
          key: const Key('browser.reload'),
          onPressed: onReload,
          child: Text(strings.reload),
        ),
      ],
    ),
  );
}

class _ProgressLine extends StatelessWidget {
  const _ProgressLine({required this.progress, required this.loading});

  final double progress;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    // A plain 2px rule: the bar carries the reported progress and nothing
    // else. No spinner, no animation that outlives the load.
    if (!loading) return const SizedBox(height: 2);
    return SizedBox(
      key: const Key('browser.progress'),
      height: 2,
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: progress <= 0 ? 0.02 : progress,
          child: Container(color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }
}

class _TitleLine extends StatelessWidget {
  const _TitleLine({required this.title, required this.url});

  final String? title;
  final Uri? url;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = title?.trim();
    final text = (label == null || label.isEmpty)
        ? (url?.toString() ?? '')
        : label;
    if (text.isEmpty) return const SizedBox(height: 0.6);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.dividerColor, width: 0.6),
        ),
      ),
      child: Text(
        text,
        key: const Key('browser.title'),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 9.5,
          letterSpacing: 1.2,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _ErrorLine extends StatelessWidget {
  const _ErrorLine({required this.message, required this.strings});

  final String message;
  final BrowserStrings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: theme.colorScheme.error.withValues(alpha: 0.08),
      child: Text(
        message.isEmpty ? strings.loadFailed : message,
        key: const Key('browser.error'),
        style: TextStyle(fontSize: 12, color: theme.colorScheme.error),
      ),
    );
  }
}
