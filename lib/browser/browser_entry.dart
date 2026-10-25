/// Entry points for the embedded browser window.
///
/// Used by the home launcher and coding workspace's served preview. A route
/// builder is also available for surfaces that need a full page.
library;

import 'package:flutter/material.dart';

import 'package:lastanswer/browser/browser_strings.dart';
import 'package:lastanswer/browser/browser_view.dart';
import 'package:lastanswer/browser/workspace_browser.dart';

/// Opens the browser window as a dialog over the current surface.
///
/// [initialUrl] is opened when it is a navigable `http`/`https` address.
/// Returns when the dialog is closed.
Future<void> openWorkspaceBrowser(
  BuildContext context, {
  Uri? initialUrl,
  BrowserViewBuilder? viewBuilder,
}) => showDialog<void>(
  context: context,
  builder: (context) {
    final size = MediaQuery.sizeOf(context);
    return Dialog(
      key: const Key('browser.dialog'),
      insetPadding: const EdgeInsets.all(24),
      child: SizedBox(
        width: (size.width - 48).clamp(0, 1100),
        height: (size.height - 48).clamp(0, 760),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DialogHeader(onClose: () => Navigator.of(context).maybePop()),
            Expanded(
              child: WorkspaceBrowser(
                initialUrl: initialUrl,
                viewBuilder: viewBuilder,
              ),
            ),
          ],
        ),
      ),
    );
  },
);

/// Builds the browser window as a routable page.
///
/// A router owner can use this as a `pageBuilder`; no route is registered
/// here.
class WorkspaceBrowserPage extends StatelessWidget {
  const WorkspaceBrowserPage({super.key, this.initialUrl, this.viewBuilder});

  final Uri? initialUrl;
  final BrowserViewBuilder? viewBuilder;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: WorkspaceBrowser(initialUrl: initialUrl, viewBuilder: viewBuilder),
    ),
  );
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final strings = BrowserStrings.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 0.6),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              strings.windowTitle,
              style: const TextStyle(fontSize: 9.5, letterSpacing: 1.2),
            ),
          ),
          TextButton(
            key: const Key('browser.close'),
            onPressed: onClose,
            child: Text(strings.close),
          ),
        ],
      ),
    );
  }
}
