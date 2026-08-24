import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/settings/features/features.dart';
import 'package:lastanswer/settings/features/mesh_storage_service.dart';
import 'package:qr/qr.dart';

export 'mesh_qr_scan_page.dart' show MeshQrScanPage;

/// Seamless mesh setup UI: pick a role, scan or paste one code — done.
///
/// Regular users never see endpoints, ports, or peer ids; those live in
/// the collapsed "Advanced settings (debug)" section at the bottom.
class MeshSyncPanel extends StatefulWidget {
  const MeshSyncPanel({super.key});

  @override
  State<MeshSyncPanel> createState() => _MeshSyncPanelState();
}

class _MeshSyncPanelState extends State<MeshSyncPanel> {
  final StorageBackendsNotifier _notifier = StorageBackendsNotifier.instance;
  final _relayController = TextEditingController();
  final _meshPathController = TextEditingController();
  final _peerIdController = TextEditingController();
  var _advancedInitialized = false;
  Uint8List? _qrPayload;

  @override
  void initState() {
    super.initState();
    unawaited(_refreshQr());
  }

  @override
  void dispose() {
    _relayController.dispose();
    _meshPathController.dispose();
    _peerIdController.dispose();
    super.dispose();
  }

  /// Fills the debug fields once; afterwards they belong to the user.
  void _initAdvancedFieldsIfNeed() {
    if (_advancedInitialized) return;
    _advancedInitialized = true;
    _meshPathController.text = _notifier.meshStorePath;
    _peerIdController.text = _notifier.meshPeerId;
    _relayController.text = _notifier.meshRelayEndpoint;
  }

  Future<void> _refreshQr() async {
    if (_notifier.meshRole != MeshRole.main) return;
    try {
      final service = await _notifier.ensureMeshService();
      final code = await service.createPairingCode();
      if (!mounted) return;
      setState(() => _qrPayload = base64Decode(code));
    } on Object {
      if (mounted) setState(() => _qrPayload = null);
    }
  }

  Future<void> _becomeMain() async {
    try {
      await _notifier.becomeMainDevice();
      await _refreshQr();
    } on Object catch (error) {
      if (!mounted) return;
      await Toasts.of(
        context,
      ).showBottomToast(message: error.toString());
    }
  }

  Future<void> _join() async {
    final l10n = context.l10n;
    final code = await showDialog<String>(
      context: context,
      builder: (final context) => _PairingCodeDialog(
        showScanButton: _cameraAvailable,
      ),
    );
    if (code == null || code.isEmpty || !mounted) return;
    try {
      final report = await _notifier.joinWithCode(code);
      if (!mounted) return;
      await Toasts.of(context).showBottomToast(
        message: report.ok
            ? l10n.storageMeshJoinedStatus
            : l10n.storageMeshPairingFailed(report.message),
      );
    } on Object catch (error) {
      if (!mounted) return;
      await Toasts.of(
        context,
      ).showBottomToast(message: l10n.storageMeshPairingFailed('$error'));
    }
  }

  Future<void> _syncNow() async {
    final l10n = context.l10n;
    try {
      final service = await _notifier.ensureMeshService();
      await service.backup(await _notifier.buildPayload());
      await service.sync();
      final report = await _notifier.restoreNow(
        backend: StorageBackendId.mesh,
      );
      if (!mounted) return;
      await Toasts.of(context).showBottomToast(
        message:
            report.ok ? l10n.storageMeshSyncDone : report.message,
      );
    } on Object catch (error) {
      if (!mounted) return;
      await Toasts.of(
        context,
      ).showBottomToast(message: l10n.storageMeshPairingFailed('$error'));
    }
  }

  Future<void> _unpair() async {
    final l10n = context.l10n;
    final confirmed = await Modals.of(context).showWarningDialog(
      title: l10n.storageMeshUnpair,
      noActionText: l10n.cancel,
      yesActionText: l10n.confirm,
      description: l10n.beCarefulItsInreversableAction,
    );
    if (!confirmed || !mounted) return;
    await _notifier.leaveMesh();
    if (mounted) setState(() => _qrPayload = null);
  }

  Future<void> _copyCode() async {
    final l10n = context.l10n;
    if (_qrPayload == null) return;
    await Clipboard.setData(ClipboardData(text: base64Encode(_qrPayload!)));
    if (!mounted) return;
    await Toasts.of(context).showBottomToast(
      message: l10n.storageMeshCodeCopied,
    );
  }

  void _submitAdvanced(final String _) => unawaited(
    _notifier.setMeshConfig(
      storePath: _meshPathController.text.trim().isEmpty
          ? _notifier.meshStorePath
          : _meshPathController.text.trim(),
      relayEndpoint: _relayController.text.trim(),
      port: _notifier.meshPort,
    ),
  );

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    _initAdvancedFieldsIfNeed();
    return ListenableBuilder(
      listenable: _notifier,
      builder: (final context, final _) => switch (_notifier.meshRole) {
        MeshRole.none => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.storageMeshHint, style: context.textTheme.bodySmall),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                if (MeshStorageService.canHostRelay)
                  FilledButton.icon(
                    key: const ValueKey('mesh-become-main'),
                    onPressed: () => unawaited(_becomeMain()),
                    icon: const Icon(Icons.qr_code_2),
                    label: Text(l10n.storageMeshBecomeMain),
                  ),
                OutlinedButton.icon(
                  key: const ValueKey('mesh-join'),
                  onPressed: () => unawaited(_join()),
                  icon: const Icon(Icons.paste),
                  label: Text(l10n.storageMeshJoinWithCode),
                ),
              ],
            ),
            _advancedSection(l10n),
          ],
        ),
        MeshRole.main => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _roleBadge(l10n.storageMeshMainBadge, Icons.star_rounded),
            const SizedBox(height: 12),
            Center(
              child: _qrPayload == null
                  ? const CircularProgressIndicator()
                  : _QrCard(payload: _qrPayload!),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.storageMeshWaitingHint(l10n.storageMeshJoinWithCode),
              style: context.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                TextButton.icon(
                  onPressed: () => unawaited(_copyCode()),
                  icon: const Icon(Icons.copy),
                  label: Text(l10n.storageMeshCopyCode),
                ),
                TextButton.icon(
                  onPressed: () => unawaited(_syncNow()),
                  icon: const Icon(Icons.sync),
                  label: Text(l10n.storageMeshSyncNow),
                ),
              ],
            ),
            _advancedSection(l10n),
          ],
        ),
        MeshRole.joined => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.storageMeshJoinedStatus,
              style: context.textTheme.bodySmall,
            ),
            if (_notifier.meshService case final service?)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  l10n.storageMeshConnectedCount(service.peers.length),
                  style: context.textTheme.bodySmall,
                ),
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                TextButton.icon(
                  onPressed: () => unawaited(_syncNow()),
                  icon: const Icon(Icons.sync),
                  label: Text(l10n.storageMeshSyncNow),
                ),
                TextButton.icon(
                  onPressed: () => unawaited(_unpair()),
                  icon: const Icon(Icons.link_off),
                  label: Text(l10n.storageMeshUnpair),
                ),
              ],
            ),
            _advancedSection(l10n),
          ],
        ),
      },
    );
  }

  Widget _roleBadge(final String text, final IconData icon) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 16),
      const SizedBox(width: 4),
      Text(text, style: context.textTheme.labelMedium),
    ],
  );

  Widget _advancedSection(final S l10n) => Theme(
    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
    child: ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 8),
      title: Text(
        l10n.storageMeshAdvanced,
        style: context.textTheme.bodySmall,
      ),
      children: [
        TextField(
          controller: _meshPathController,
          decoration: const InputDecoration(
            labelText: 'Store path',
            isDense: true,
          ),
          onSubmitted: _submitAdvanced,
        ),
        const SizedBox(height: 8),
        TextField(
          readOnly: true,
          controller: _peerIdController,
          decoration: const InputDecoration(
            labelText: 'Peer ID',
            isDense: true,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _relayController,
          decoration: const InputDecoration(
            labelText: 'Relay URL',
            hintText: 'ws://192.168.1.20:8080',
            isDense: true,
          ),
          onSubmitted: _submitAdvanced,
        ),
        const SizedBox(height: 4),
        Text(
          'Changes apply after the next sync or reconnect.',
          style: context.textTheme.bodySmall,
        ),
      ],
    ),
  );
}

bool get _cameraAvailable {
  if (kIsWeb) return true;
  return defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;
}

class _QrCard extends StatelessWidget {
  const _QrCard({required this.payload});

  final Uint8List payload;

  @override
  Widget build(final BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: CustomPaint(
      size: const Size.square(220),
      painter: _MeshQrPainter(payload),
    ),
  );
}

class _MeshQrPainter extends CustomPainter {
  const _MeshQrPainter(this.payload);

  final List<int> payload;

  @override
  void paint(final Canvas canvas, final Size size) {
    final image = QrImage(
      QrCode(
        payload: QrPayload.fromTypedData(Uint8List.fromList(payload)),
      ),
    );
    final module = size.width / image.moduleCount;
    final paint = Paint()..color = Colors.black;
    for (var y = 0; y < image.moduleCount; y++) {
      for (var x = 0; x < image.moduleCount; x++) {
        if (!image.isDark(y, x)) continue;
        canvas.drawRect(
          Rect.fromLTWH(x * module, y * module, module, module),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(final _MeshQrPainter oldDelegate) =>
      payload.length != oldDelegate.payload.length ||
      payload.indexed.any(
        (final record) => record.$2 != oldDelegate.payload[record.$1],
      );
}

class _PairingCodeDialog extends StatefulWidget {
  const _PairingCodeDialog({required this.showScanButton});

  final bool showScanButton;

  @override
  State<_PairingCodeDialog> createState() => _PairingCodeDialogState();
}

class _PairingCodeDialogState extends State<_PairingCodeDialog> {
  final _controller = TextEditingController();

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.storageMeshPasteTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            maxLines: 4,
            decoration: const InputDecoration(hintText: 'mesh-pair/v1 …'),
          ),
          if (widget.showScanButton)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () async {
                  final code = await Navigator.of(context).push<String>(
                    MaterialPageRoute<String>(
                      builder: (final context) => const MeshQrScanPage(),
                    ),
                  );
                  if (code != null && code.isNotEmpty && mounted) {
                    setState(() => _controller.text = code);
                  }
                },
                icon: const Icon(Icons.qr_code_scanner),
                label: Text(l10n.storageMeshScanQr),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: Text(l10n.storageMeshConnectButton),
        ),
      ],
    );
  }
}
