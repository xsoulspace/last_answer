import 'package:lastanswer/agent_config/agent_config.dart';
import 'package:lastanswer/agent_config/chatgpt_subscription_pane.dart';
import 'package:lastanswer/coding_agent/provider_configuration.dart';
import 'package:lastanswer/common_imports.dart';

/// The user-friendly wrapper over the one agent config document
/// (Zed-parity): register ACP agent servers, set provider keys/env vars,
/// list models, pick chat defaults. Edits accumulate in a draft and land in
/// the file on SAVE — file and UI edit the same document, never diverge.
///
/// DESIGN.md discipline: a pane, not a page; label gutter + mono fields;
/// hairlines separate regions; no cards/chips; every actionable element
/// carries an `agent_config.*` key.
class AgentConfigSettingsPane extends StatefulWidget {
  const AgentConfigSettingsPane({this.closeOnSave = true, super.key});

  /// True when shown modally (save closes the sheet); false when embedded
  /// as a settings-screen tab (save stays put).
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
  ProviderConfigurationStore get _providerKeys =>
      context.read<ProviderConfigurationStore>();

  late AgentPlatformConfig _draft;
  final _serverControllers = <String, _ServerFields>{};
  final _providerControllers = <String, _ProviderFields>{};
  late _ChatFields _chat;
  final Map<String, bool> _storedKeys = {};
  String? _saveError;

  @override
  void initState() {
    super.initState();
    _resetFromStore();
    unawaited(_refreshStoredKeys());
  }

  void _resetFromStore() {
    _draft = _store.config;
    _serverControllers
      ..clear()
      ..addAll({
        for (final entry in _draft.agentServers.entries)
          entry.key: _ServerFields(entry.value),
      });
    _providerControllers
      ..clear()
      ..addAll({
        for (final entry in _draft.providers.entries)
          entry.key: _ProviderFields(entry.value),
      });
    _chat = _ChatFields(_draft.chat);
  }

  Future<void> _refreshStoredKeys() async {
    for (final id in _draft.providers.keys) {
      final stored = await _providerKeys.hasProviderKey(id);
      if (!mounted) return;
      setState(() => _storedKeys[id] = stored);
    }
  }

  Future<void> _save() async {
    try {
      await _store.save(
        _draft.copyWith(
          agentServers: {
            for (final entry in _serverControllers.entries)
              if (entry.key.trim().isNotEmpty)
                entry.key: entry.value.toConfig(),
          },
          providers: {
            for (final entry in _providerControllers.entries)
              if (entry.key.trim().isNotEmpty)
                entry.key: entry.value.toConfig(),
          },
          chat: _chat.toConfig(),
        ),
      );
      if (!mounted) return;
      setState(() => _saveError = null);
      await _refreshStoredKeys();
      if (mounted && widget.closeOnSave) Navigator.of(context).maybePop();
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _saveError = error.toString());
    }
  }

  @override
  Widget build(final BuildContext context) {
    final theme = context.laUi;
    // Self-scrolling: the pane must not overflow any host (sheet, tab,
    // narrow window) as rows are added.
    return SingleChildScrollView(
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const ChatGptSubscriptionPane(),
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
        const _PaneDivider(),
        _providersSection(theme),
        const _PaneDivider(),
        _chatSection(theme),
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
  // PROVIDERS
  // ------------------------------------------------------------------

  Widget _providersSection(final LaUiTheme theme) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(
          context.l10n.agentProvidersSection.toUpperCase(),
          style: _sectionLabel(theme),
        ),
        for (final entry in _providerControllers.entries)
          _providerRow(theme, entry.key, entry.value),
      ],
    ),
  );

  Widget _providerRow(
    final LaUiTheme theme,
    final String id,
    final _ProviderFields fields,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 6,
    children: [
      Row(
        children: [
          SizedBox(
            width: 92,
            child: Text(id, style: _mono(theme)),
          ),
          const Spacer(),
          if (_storedKeys[id] ?? false)
            Text(
              context.l10n.agentProviderKeyStored,
              key: Key('agent_config.provider.$id.stored'),
              style: theme.compact,
            ),
        ],
      ),
      Row(
        spacing: 8,
        children: [
          Expanded(
            child: LaField(
              key: Key('agent_config.provider.$id.key'),
              controller: fields.key,
              obscureText: true,
              style: _mono(theme),
              placeholder: context.l10n.agentProviderKeyHint,
              placeholderStyle: _mono(theme, color: theme.inkQuiet),
              onSubmitted: (final value) async {
                if (value.trim().isEmpty) return;
                await _providerKeys.writeProviderKey(id, value.trim());
                fields.key.clear();
                await _refreshStoredKeys();
              },
            ),
          ),
          if (_storedKeys[id] ?? false)
            LaButton.icon(
              key: Key('agent_config.provider.$id.key.clear'),
              size: LaButtonSize.sm,
              tooltip: context.l10n.agentProviderKeyRemove,
              onPressed: () async {
                await _providerKeys.removeProviderKey(id);
                await _refreshStoredKeys();
              },
              icon: const Icon(Icons.close, size: 16),
            ),
        ],
      ),
      Row(
        spacing: 8,
        children: [
          Expanded(
            child: _field(
              theme,
              key: Key('agent_config.provider.$id.env_name'),
              controller: fields.apiKeyEnv,
              hint: context.l10n.agentProviderEnvHint,
                ),
          ),
          Expanded(
            child: _field(
              theme,
              key: Key('agent_config.provider.$id.base_url'),
              controller: fields.baseUrl,
              hint: context.l10n.agentProviderBaseUrlHint,
                ),
          ),
        ],
      ),
      _field(
        theme,
        key: Key('agent_config.provider.$id.models'),
        controller: fields.models,
        hint: context.l10n.agentProviderModelsHint,
        maxLines: 3,
      ),
      _field(
        theme,
        key: Key('agent_config.provider.$id.default_model'),
        controller: fields.defaultModel,
        hint: context.l10n.agentProviderDefaultModelHint,
      ),
    ],
  );

  // ------------------------------------------------------------------
  // CHAT DEFAULTS
  // ------------------------------------------------------------------

  Widget _chatSection(final LaUiTheme theme) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(
          context.l10n.agentChatDefaultsSection.toUpperCase(),
          style: _sectionLabel(theme),
        ),
        Row(
          spacing: 8,
          children: [
            Expanded(
              child: LaSelect<String>(
                key: const Key('agent_config.chat.provider'),
                // A fresh config has no default; the value must be null
                // (not '') when it is not among the items, or the dropdown
                // asserts — found live on web.
                value: _providerControllers.containsKey(_chat.defaultProvider)
                    ? _chat.defaultProvider
                    : null,
                expand: true,
                placeholder: context.l10n.agentChatProviderHint,
                items: [
                  for (final id in _providerControllers.keys)
                    LaSelectItem(value: id, label: id),
                ],
                onChanged: (final value) =>
                    setState(() => _chat.defaultProvider = value ?? ''),
              ),
            ),
            Expanded(
              child: LaSelect<String>(
                key: const Key('agent_config.chat.model'),
                value: _modelsOf(
                  _chat.defaultProvider,
                ).contains(_chat.defaultModel)
                    ? _chat.defaultModel
                    : null,
                expand: true,
                placeholder: context.l10n.agentChatModelHint,
                items: [
                  for (final model in _modelsOf(_chat.defaultProvider))
                    LaSelectItem(value: model, label: model),
                ],
                onChanged: (final value) =>
                    setState(() => _chat.defaultModel = value ?? ''),
              ),
            ),
          ],
        ),
        LaField(
          key: const Key('agent_config.chat.system_prompt'),
          controller: _chat.systemPrompt,
          minLines: 2,
          maxLines: 5,
          style: _mono(theme),
          placeholder: context.l10n.agentChatSystemPromptHint,
          placeholderStyle: _mono(theme, color: theme.inkQuiet),
        ),
      ],
    ),
  );

  List<String> _modelsOf(final String providerId) {
    final fields = _providerControllers[providerId];
    if (fields == null) return const [];
    return fields
        .toConfig()
        .models
        .where((model) => model.isNotEmpty)
        .toList();
  }

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
              .substring(line.indexOf('=') + 1)
              .trim(),
    },
  );
}

final class _ProviderFields {
  _ProviderFields(ProviderConfig config)
    : apiKeyEnv = TextEditingController(text: config.apiKeyEnv),
      baseUrl = TextEditingController(text: config.baseUrl),
      models = TextEditingController(text: config.models.join('\n')),
      defaultModel = TextEditingController(text: config.defaultModel);

  final TextEditingController key = TextEditingController();
  final TextEditingController apiKeyEnv;
  final TextEditingController baseUrl;
  final TextEditingController models;
  final TextEditingController defaultModel;

  ProviderConfig toConfig() => ProviderConfig(
    apiKeyEnv: apiKeyEnv.text.trim(),
    baseUrl: baseUrl.text.trim(),
    models: models.text
        .split('\n')
        .map((m) => m.trim())
        .where((m) => m.isNotEmpty)
        .toList(),
    defaultModel: defaultModel.text.trim(),
  );
}

final class _ChatFields {
  _ChatFields(ChatConfig config)
    : defaultProvider = config.defaultProvider,
      defaultModel = config.defaultModel,
      systemPrompt = TextEditingController(text: config.systemPrompt);

  String defaultProvider;
  String defaultModel;
  final TextEditingController systemPrompt;

  ChatConfig toConfig() => ChatConfig(
    defaultProvider: defaultProvider,
    defaultModel: defaultModel,
    systemPrompt: systemPrompt.text,
  );
}
