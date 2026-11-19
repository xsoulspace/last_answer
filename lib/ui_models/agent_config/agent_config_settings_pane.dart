import 'package:lastanswer/ui_models/agent_config/agent_config.dart';
import 'package:lastanswer/common_imports.dart';

/// The user-friendly wrapper over the agent-servers half of the one
/// agent config document (Zed-parity): register ACP agent servers
/// (`command`/`args`/`env`). Edits accumulate in a draft and land in
/// the file on SAVE — file and UI edit the same document, never
/// diverge.
///
/// ADR 0032 — this pane used to also edit inference providers, chat
/// defaults and the subscription plans; ALL of that lives in the
/// Models surface now (the world palette is the dispatch truth, the
/// subscription panes ride their catalog rows). The stored
/// `providers`/`chat` entries keep their read-only fallback role (the
/// brain pickers' hosted-model derivation) — this pane no longer
/// writes them.
///
/// DESIGN.md discipline: a pane, not a page; label gutter + mono fields;
/// hairlines separate regions; no cards/chips; every actionable element
/// carries an `agent_config.*` key.
class AgentConfigSettingsPane extends StatefulWidget {
  const AgentConfigSettingsPane({this.closeOnSave = true, super.key});

  /// True when shown modally (save closes the sheet); false when embedded
  /// as a settings section (save stays put).
  final bool closeOnSave;

  /// Re-opens the pane as a modal sheet from any surface (chat toolbar,
  /// agent-doc status rule).
  static Future<void> show(final BuildContext context) =>
      showLaSheet<void>(
        context: context,
        builder: (final context) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.9,
          builder: (final context, final scrollController) =>
              SingleChildScrollView(
                controller: scrollController,
                child: const Padding(
                  padding: EdgeInsets.only(bottom: 24),
                  child: AgentConfigSettingsPane(),
                ),
              ),
        ),
      );

  @override
  State<AgentConfigSettingsPane> createState() =>
      _AgentConfigSettingsPaneState();
}

class _AgentConfigSettingsPaneState extends State<AgentConfigSettingsPane> {
  AgentConfigStore get _store => context.read<AgentConfigStore>();

  final _serverControllers = <String, _ServerFields>{};
  String? _saveError;

  @override
  void initState() {
    super.initState();
    _resetFromStore();
  }

  void _resetFromStore() {
    _draft = _store.config;
    _serverControllers
      ..clear()
      ..addAll({
        for (final entry in _draft.agentServers.entries)
          entry.key: _ServerFields(entry.value),
      });
  }

  late AgentPlatformConfig _draft;

  Future<void> _save() async {
    try {
      await _store.save(
        _draft.copyWith(
          agentServers: {
            for (final entry in _serverControllers.entries)
              if (entry.key.trim().isNotEmpty)
                entry.key: entry.value.toConfig(),
          },
        ),
      );
      if (!mounted) return;
      setState(() => _saveError = null);
      if (mounted && widget.closeOnSave) Navigator.of(context).maybePop();
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _saveError = error.toString());
    }
  }

  @override
  Widget build(final BuildContext context) {
    final theme = context.laUi;
    // Self-scrolling: the pane must not overflow any host (sheet,
    // section, narrow window) as rows are added.
    return SingleChildScrollView(
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Row(
            children: [
              Text(
                context.l10n.agentSettingsTitle,
                style: theme.emphasis,
              ),
              const Spacer(),
              LaButton(
                key: const Key('agent_config.save'),
                variant: LaButtonVariant.ghost,
                onPressed: _save,
                label: context.l10n.save,
              ),
            ],
          ),
        ),
        if (_store.lastError != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              context.l10n.agentConfigUnreadable(_store.lastError!),
              key: const Key('agent_config.load_error'),
              style: theme.compact.copyWith(color: theme.danger),
            ),
          ),
        const _PaneDivider(),
        _agentsSection(theme),
        if (_saveError != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              _saveError!,
              style: theme.compact.copyWith(color: theme.danger),
            ),
          ),
      ],
      ),
    );
  }

  // ------------------------------------------------------------------
  // AGENT SERVERS
  // ------------------------------------------------------------------

  Widget _agentsSection(final LaUiTheme theme) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Row(
          children: [
            Text(
              context.l10n.agentServersSection.toUpperCase(),
              style: _sectionLabel(theme),
            ),
            const Spacer(),
            LaButton(
              key: const Key('agent_config.server.add'),
              variant: LaButtonVariant.ghost,
              onPressed: () => setState(() {
                _serverControllers['server-${_serverControllers.length + 1}'] =
                    _ServerFields(const AgentServerConfig(command: ''));
              }),
              label: '+ ${context.l10n.agentServerAdd}',
            ),
          ],
        ),
        if (_serverControllers.isEmpty)
          Text(context.l10n.agentServersEmptyHint, style: theme.compact),
        for (final entry in _serverControllers.entries)
          _serverRow(theme, entry.key, entry.value),
      ],
    ),
  );

  Widget _serverRow(
    final LaUiTheme theme,
    final String id,
    final _ServerFields fields,
  ) => Container(
    // A row container is a grouping rule on the grid, not decorative chrome.
    padding: const EdgeInsets.symmetric(vertical: 6),
    decoration: BoxDecoration(
      border: Border.all(color: theme.rule, width: 0.6),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        Row(
          children: [
            Expanded(
              child: _field(
                theme,
                key: Key('agent_config.server.$id.name'),
                controller: fields.name,
                hint: context.l10n.agentServerNameHint,

              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _field(
                theme,
                key: Key('agent_config.server.$id.command'),
                controller: fields.command,
                hint: context.l10n.agentServerCommandHint,

              ),
            ),
            LaButton.icon(
              key: Key('agent_config.server.$id.remove'),
              size: LaButtonSize.sm,
              tooltip: context.l10n.agentServerRemove,
              onPressed: () => setState(() {
                _serverControllers.remove(id);
              }),
              icon: const Icon(Icons.close, size: 16),
            ),
          ],
        ),
        _field(
          theme,
          key: Key('agent_config.server.$id.args'),
          controller: fields.args,
          hint: context.l10n.agentServerArgsHint,
        ),
        _field(
          theme,
          key: Key('agent_config.server.$id.env'),
          controller: fields.env,
          hint: context.l10n.agentServerEnvHint,
          maxLines: 2,
        ),
      ],
    ),
  );

  // ------------------------------------------------------------------
  // shared quiet widgets (no chrome — label + hairline underline)
  // ------------------------------------------------------------------

  Widget _field(
    final LaUiTheme theme, {
    required final Key key,
    required final TextEditingController controller,
    required final String hint,
    final int maxLines = 1,
  }) => LaField(
    key: key,
    controller: controller,
    maxLines: maxLines,
    style: _mono(theme),
    placeholder: hint,
    placeholderStyle: _mono(theme, color: theme.inkQuiet),
  );

  TextStyle _sectionLabel(final LaUiTheme theme) =>
      theme.micro.copyWith(letterSpacing: 1.2);

  TextStyle _mono(final LaUiTheme theme, {final Color? color}) =>
      color == null ? theme.mono : theme.mono.copyWith(color: color);
}

/// The pane's 16px hairline separator (was `Divider(height: 16)`).
class _PaneDivider extends StatelessWidget {
  const _PaneDivider();

  @override
  Widget build(final BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 8),
    child: LaHairline(),
  );
}

final class _ServerFields {
  _ServerFields(AgentServerConfig config)
    : name = TextEditingController(text: config.displayName ?? ''),
      command = TextEditingController(text: config.command),
      args = TextEditingController(text: config.args.join(', ')),
      env = TextEditingController(
        text: config.env.entries.map((e) => '${e.key}=${e.value}').join('\n'),
      );

  final TextEditingController name;
  final TextEditingController command;
  final TextEditingController args;
  final TextEditingController env;

  AgentServerConfig toConfig() => AgentServerConfig(
    command: command.text.trim(),
    displayName: name.text.trim().isEmpty ? null : name.text.trim(),
    args: args.text
        .split(',')
        .map((a) => a.trim())
        .where((a) => a.isNotEmpty)
        .toList(),
    env: {
      for (final line in env.text.split('\n'))
        if (line.contains('='))
          line.substring(0, line.indexOf('=')).trim(): line
              .substring(line.indexOf('=') + 1).trim(),
    },
  );
}
