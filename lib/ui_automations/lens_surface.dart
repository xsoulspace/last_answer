import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/ui_automations/automation_mcp_client.dart';
import 'package:universal_automation_lens/universal_automation_lens.dart';

/// The Lens surface (ADR 0010 phase 3): the live view of ANY surface
/// agents act on — a background browser, an admin panel, a driven app —
/// hosted in-process. Texture plane straight from the plugin (zero Dart
/// bytes per frame); the presence layer polls the resident serve's
/// `automation_presence` (KB-scale JSON, never frames) and draws one
/// cursor per agent; `burst` grabs the on-demand evidence thumbnail.
///
/// The serve is NOT in the pixel path: capture lives in this process
/// (the plugin); the serve remains the act/observe brain.
final class LensSurface extends StatefulWidget {
  const LensSurface({super.key, this.client, this.attachOnPick = true});

  /// The automation client; null → presence overlay stays idle (the
  /// texture plane still works — the lens never requires the serve).
  final AutomationMcpClient? client;

  final bool attachOnPick;

  @override
  State<LensSurface> createState() => _LensSurfaceState();
}

final class _LensSurfaceState extends State<LensSurface> {
  final LensController _lens = LensController();
  List<LensWindowInfo> _windows = const [];
  int? _selected;
  LensEnergyMode _mode = LensEnergyMode.balanced;
  bool _consent = false;
  String? _error;
  Timer? _presenceTimer;
  List<LensPresence> _presences = const [];
  static const _presenceColors = [
    Color(0xFF008080),
    Color(0xFFB5651D),
    Color(0xFF7A5FB5),
    Color(0xFF2E7D32),
  ];

  @override
  void initState() {
    super.initState();
    unawaited(_refresh());
    _startPresencePolling();
  }

  @override
  void dispose() {
    _presenceTimer?.cancel();
    _lens.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    try {
      final consent = await _lens.consentPreflight();
      final windows = consent ? await _lens.listWindows() : const <LensWindowInfo>[];
      if (!mounted) return;
      setState(() {
        _consent = consent;
        _windows = windows;
        _error = null;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _error = '$error');
    }
  }

  void _startPresencePolling() {
    final client = widget.client;
    if (client == null) return;
    _presenceTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => unawaited(_pollPresence(client)),
    );
    unawaited(_pollPresence(client));
  }

  Future<void> _pollPresence(AutomationMcpClient client) async {
    try {
      final payload = await client.presence();
      final agents = payload['agents'];
      if (agents is! List) return;
      if (!mounted) return;
      setState(() {
        _presences = [
          for (final (index, agent) in agents.indexed)
            if (agent is Map &&
                agent['agentId'] is String &&
                agent['surface'] is String)
              LensPresence(
                agentId: agent['agentId']! as String,
                label: '${agent['lastVerb'] ?? 'active'}',
                color: _presenceColors[index % _presenceColors.length],
                x: (agent['pointerX'] as num?)?.toDouble() ?? 0.5,
                y: (agent['pointerY'] as num?)?.toDouble() ?? 0.08,
                receipt: agent['lastReceipt'] as String?,
              ),
        ];
      });
    } on Object {
      // Serve down / not converged: the lens texture still shows; the
      // overlay just stays empty. Loud, not silent — the status row
      // renders the last error.
    }
  }

  Future<void> _burstEvidence() async {
    final id = _selected;
    if (id == null) return;
    final bytes = await _lens.burst(id);
    if (!mounted) return;
    setState(() {
      _error = bytes == null
          // Honest refusal below macOS 14: the one-shot API is absent.
          ? 'burst: no frame (macOS 14+ one-shot only)'
          : 'burst: ${bytes.length ~/ 1024} KB evidence PNG';
    });
  }

  @override
  Widget build(BuildContext context) {
    final la = context.la;
    final selected = _selected == null
        ? null
        : _windows.where((w) => w.windowId == _selected).firstOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Text(
                selected == null
                    ? (context.l10n.viewLensTitle)
                    : '${selected.appName} — ${selected.title}',
                style: context.laUi.compact,
              ),
              const Spacer(),
              // The energy switch (ADR 0010): fps presets — kit buttons,
              // the ONE component carrier (no Material widgets here).
              for (final (mode, label) in const [
                (LensEnergyMode.performance, '60'),
                (LensEnergyMode.balanced, '30'),
                (LensEnergyMode.saver, '10'),
              ])
                LaButton(
                  key: ValueKey('lens.energy.$label'),
                  variant: _mode == mode
                      ? LaButtonVariant.primary
                      : LaButtonVariant.ghost,
                  onPressed: () => setState(() => _mode = mode),
                  label: label,
                ),
              const SizedBox(width: 8),
              LaButton(
                key: const ValueKey('lens.burst'),
                variant: LaButtonVariant.ghost,
                onPressed: _selected == null ? null : _burstEvidence,
                label: 'PNG',
              ),
              const SizedBox(width: 8),
              LaButton(
                key: const ValueKey('lens.refresh'),
                variant: LaButtonVariant.ghost,
                onPressed: _refresh,
                label: '⟳',
              ),
            ],
          ),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              _error!,
              style: context.laUi.micro.copyWith(color: la.inkMuted),
            ),
          ),
        Expanded(
          child: _selected == null
              ? _WindowPicker(
                  consent: _consent,
                  windows: _windows,
                  error: _error,
                  onPick: (id) => setState(() => _selected = id),
                  onRequestConsent: () => unawaited(_requestConsent()),
                )
              : LensView(
                  key: ValueKey('lens.view.${_selected!}'),
                  controller: _lens,
                  windowId: _selected!,
                  energy: LensEnergy(mode: _mode),
                  presences: _presences,
                  onStatus: (status) => debugPrint('lens: $status'),
                ),
        ),
      ],
    );
  }

  Future<void> _requestConsent() async {
    await _lens.consentRequest();
    await _refresh();
  }
}

final class _WindowPicker extends StatelessWidget {
  const _WindowPicker({
    required this.consent,
    required this.windows,
    required this.error,
    required this.onPick,
    required this.onRequestConsent,
  });

  final bool consent;
  final List<LensWindowInfo> windows;
  final String? error;
  final ValueChanged<int> onPick;
  final VoidCallback onRequestConsent;

  @override
  Widget build(BuildContext context) {
    final la = context.la;
    if (!consent) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.visibility_off_outlined),
            const SizedBox(height: 8),
            const Text(
              'Screen recording consent needed for this app',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            LaButton(
              key: const ValueKey('lens.consent'),
              variant: LaButtonVariant.ghost,
              onPressed: onRequestConsent,
              label: 'Request',
            ),
          ],
        ),
      );
    }
    if (windows.isEmpty) {
      return Center(
        child: Text(
          error ?? 'No layer-0 windows found — refresh?',
          style: context.laUi.compact.copyWith(color: la.inkMuted),
        ),
      );
    }
    return ListView(
      children: [
        for (final window in windows)
          LaRow(
            key: ValueKey('lens.window.${window.windowId}'),
            titleText: window.title.isEmpty
                ? window.appName
                : '${window.appName} — ${window.title}',
            metaText: 'windowId: ${window.windowId}',
            onTap: () => onPick(window.windowId),
          ),
      ],
    );
  }
}
