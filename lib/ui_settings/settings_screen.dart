import 'package:lastanswer/ui_models/agent_config/agent_config.dart';
import 'package:lastanswer/data_journal/actor_roster.dart';
import 'package:lastanswer/ui_chat/actor_avatar.dart';
import 'package:lastanswer/data_journal/realm_chat_service.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/entitlement/pro_entitlement.dart';
import 'package:lastanswer/ui_settings/widgets/widgets.dart';
import 'package:lastanswer/ui_root/app_info.dart';
import 'package:lastanswer/ui_root/feedback.dart';
import 'package:lastanswer/ui_settings/ui_settings.dart';
import 'package:lastanswer/ui_settings/settings_sections.dart';
import 'package:lastanswer/ui_settings/views/supporter_view/supporter_view.dart';
import 'package:lastanswer/ui_shell/shell_scope.dart';
import 'package:lastanswer/ui_shell/shell_theme.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// ADR 0032 — settings reads as ONE document: a single endless scroll of
/// registered sections (You, Appearance, Notes, Data & sync, Agents,
/// Account, About) over the shell's label-gutter row grammar. The
/// General/Agent/Account PageView retired: swipe-paging hid whole
/// sections (the automations burial was the lesson) and stacked a
/// second navigation over the pane.
///
/// Navigation aids ride the document, not around it:
/// - a type-to-jump field filters entries by title/keywords (Zed's
///   move; the entries' stable keys are the index);
/// - a scroll-spy anchor column at ≥ 640px width (hidden below the
///   models compact law; a table of contents over THIS document — it
///   duplicates no workspace navigation).
///
/// Instant-apply controls only — the one draft+save pane left (the ACP
/// agent servers) keeps its SAVE because it edits a document, and the
/// models' propose/apply stayed in the Models surface for the same
/// authority reason.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({this.onClose, this.embedded = false, super.key});

  /// Phase 1e — the embedding seam (settings-as-view): hosted in a
  /// shell view tab, the close affordance calls THIS instead of
  /// popping the enclosing route (a pop from inside a view would take
  /// the whole shell down). Null keeps the route behaviour.
  final VoidCallback? onClose;

  /// Hosted inside a shell view: no Scaffold of its own — the tab is
  /// the frame (the shell grammar has no exceptions, redesign §2.2.5).
  final bool embedded;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _tocMinWidth = 640.0;

  final _scroll = ScrollController();
  final _jump = TextEditingController();
  final _sectionKeys = <String, GlobalKey>{};

  /// The ids of the sections currently rendered (set during build —
  /// plain data, no context reads). The scroll listener reads THIS, not
  /// [_sections]: a listener runs outside the widget tree, where
  /// `context.watch` is illegal.
  List<String> _visibleIds = const [];
  var _query = '';
  var _activeSection = 0;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_syncActive);
  }

  @override
  void dispose() {
    _scroll.removeListener(_syncActive);
    _scroll.dispose();
    _jump.dispose();
    super.dispose();
  }

  /// The scroll-spy: the LAST section whose head is above the viewport's
  /// reading line is the active one. Render objects come from the
  /// section keys; a missing one (filtered out, disposed) is skipped —
  /// the spy degrades to the previous answer, never throws.
  void _syncActive() {
    var active = 0;
    var index = 0;
    for (final id in _visibleIds) {
      final keyContext = _sectionKeys[id]?.currentContext;
      index++;
      if (keyContext == null) continue;
      final box = keyContext.findRenderObject();
      if (box is! RenderBox) continue;
      final y = box.localToGlobal(Offset.zero).dy;
      if (y <= 120) active = index - 1;
    }
    if (active != _activeSection && mounted) {
      setState(() => _activeSection = active);
    }
  }

  void _jumpTo(final String id) {
    final keyContext = _sectionKeys[id]?.currentContext;
    if (keyContext == null) return;
    unawaited(
      Scrollable.ensureVisible(
        keyContext,
        duration: context.laUi.motionSettle,
        curve: context.laUi.motionCurve,
      ),
    );
  }

  /// The registry (ADR 0032): one entry per row or block; adding a
  /// setting = adding an entry here, no layout surgery. Built inside
  /// build — the watch() calls (projects, purchases, remote user) are
  /// the screen's subscriptions.
  List<SettingsSection> get _sections {
    final l10n = context.l10n;
    final projectsNotifier = context.watch<ProjectsNotifier>();
    final isAccountViewVisible =
        context.read<PurchasesNotifier>().isProEntryVisible ||
        context.watch<ProEntitlement?>()?.devOverride == true;
    final isRemote = context.watch<AppFeaturesNotifier>().value
        .isRemoteServicesEnabled;
    return [
      SettingsSection(
        id: 'you',
        title: l10n.settingsSectionYou,
        entries: [
          SettingsEntry(
            keyName: 'profile',
            title: l10n.actorsYourProfile,
            keywords: const ['profile', 'avatar', 'actor', 'human'],
            child: const _YourProfileButton(),
          ),
        ],
      ),
      SettingsSection(
        id: 'appearance',
        title: l10n.settingsSectionAppearance,
        entries: [
          SettingsEntry(
            keyName: 'theme',
            title: l10n.theme,
            keywords: const ['dark', 'light', 'theme', 'appearance'],
            child: ThemeSwitcherButton(settings: projectsNotifier),
          ),
          SettingsEntry(
            keyName: 'language',
            title: l10n.language,
            keywords: const ['locale', 'language', 'en', 'it', 'ru'],
            child: const LocaleSwitcherButton(),
          ),
          SettingsEntry(
            keyName: 'projectsDirection',
            title: l10n.projectsDirection,
            keywords: const ['direction', 'projects', 'rtl', 'reading'],
            child: const ProjectsDirectionSwitch(),
          ),
        ],
      ),
      SettingsSection(
        id: 'notes',
        title: l10n.settingsSectionNotes,
        entries: [
          SettingsEntry(
            keyName: 'charactersLimit',
            title: l10n.charactersLimit,
            description: l10n.charactersLimitForNewNotesDesription,
            keywords: const ['limit', 'characters', 'length', 'twitter'],
            // The bloc owns the limit's controller lifecycle (kept from
            // the old General tab verbatim). The provider's OWN context
            // reads the bloc — the screen's context sits above it.
            child: GeneralSettingsProvider(
              builder: (final blocContext) => CharactersLimitSetting(
                controller: blocContext
                    .watch<GeneralSettingsBloc>()
                    .characterLimitController,
              ),
            ),
          ),
        ],
      ),
      SettingsSection(
        id: 'data',
        title: l10n.settingsSectionData,
        entries: [
          SettingsEntry.block(
            keyName: 'storage',
            title: l10n.storage,
            keywords: const ['backup', 'restore', 'mesh', 'filesystem', 'git'],
            child: const StorageBackendsButton(),
          ),
          SettingsEntry.block(
            keyName: 'github',
            title: l10n.githubSync,
            keywords: const ['github', 'sync', 'repository', 'token'],
            child: const GithubSyncButton(),
          ),
          SettingsEntry.block(
            keyName: 'exportImport',
            title: l10n.exportImportData,
            keywords: const ['export', 'import', 'file', 'clipboard'],
            child: const ProjectsExportImportButtons(),
          ),
        ],
      ),
      SettingsSection(
        id: 'agents',
        title: l10n.settingsSectionAgents,
        entries: [
          SettingsEntry.block(
            keyName: 'agentServers',
            title: l10n.agentSettingsTitle,
            keywords: const ['acp', 'server', 'agent', 'codex', 'pi', 'gemini'],
            child: const _AgentServersBlock(),
          ),
        ],
      ),
      if (isAccountViewVisible)
        SettingsSection(
          id: 'account',
          title: l10n.myAccount,
          entries: isRemote
              ? (context.watch<RemoteUserNotifier>().isAuthorized
                    ? [
                        SettingsEntry.block(
                          keyName: 'becomePro',
                          title: l10n.youCanSupportAppDevelopment,
                          keywords: const ['pro', 'support', 'purchase'],
                          child: const SupportAppView(),
                        ),
                        SettingsEntry.block(
                          keyName: 'profile',
                          title: l10n.myAccount,
                          keywords: const ['sign out', 'delete', 'account'],
                          child: const _ProfileBlock(),
                        ),
                      ]
                    : [
                        SettingsEntry.block(
                          keyName: 'logIn',
                          title: l10n.myAccount,
                          keywords: const ['log in', 'google', 'sign in'],
                          child: const _LogInBlock(),
                        ),
                      ])
              : [
                  SettingsEntry.block(
                    keyName: 'becomePro',
                    title: l10n.youCanSupportAppDevelopment,
                    keywords: const ['pro', 'support', 'purchase'],
                    child: const SupportAppView(),
                  ),
                ],
        ),
      SettingsSection(
        id: 'about',
        title: l10n.settingsSectionAbout,
        entries: [
          SettingsEntry.block(
            keyName: 'version',
            title: l10n.settingsSectionAbout,
            keywords: const ['version', 'build', 'about'],
            child: const _AboutBlock(),
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(final BuildContext context) {
    final onBack = widget.onClose ?? () => Navigator.pop(context);
    final theme = context.laUi;
    final sections = _sections;
    final query = _query.trim().toLowerCase();
    final visible = query.isEmpty
        ? sections
        : [
            for (final section in sections)
              if (section.where(query) case final filtered
                  when filtered.isNotEmpty)
                SettingsSection(
                  id: section.id,
                  title: section.title,
                  entries: filtered,
                ),
          ];
    final screenLayout = ScreenLayout.of(context);
    final leftColumnWidth = screenLayout.small ? 90.0 : 150.0;

    final jumpField = Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: LaField(
        key: const ValueKey('settings.jump'),
        controller: _jump,
        placeholder: context.l10n.settingsJumpHint,
        prefix: Icon(Icons.search_outlined, size: 15, color: theme.inkQuiet),
        onChanged: (final value) => setState(() => _query = value),
      ),
    );

    final list = SingleChildScrollView(
      key: const ValueKey('settings.scroll'),
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (index, section) in visible.indexed)
            _SectionBlock(
              section: section,
              leftColumnWidth: leftColumnWidth,
              sectionKey: _sectionKeys.putIfAbsent(
                section.id,
                GlobalKey.new,
              ),
              first: index == 0,
            ),
        ],
      ),
    );

    // The TOC decision reads the LOCAL width, not the window's: a
    // settings tab in a narrow split pane must collapse like the rows
    // do (the tile's own 380px local law; the 640 floor is the models
    // compact law).
    final body = LayoutBuilder(
      builder: (final context, final constraints) {
        // The spy's plain-data view of what is on screen (_visibleIds).
        _visibleIds = [for (final section in visible) section.id];
        final showToc =
            query.isEmpty && constraints.maxWidth >= _tocMinWidth;
        return showToc
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TocColumn(
                    sections: sections,
                    activeIndex: _activeSection,
                    onTap: _jumpTo,
                  ),
                  Expanded(child: list),
                ],
              )
            : list;
      },
    );

    final topBar = LaTopBar(
      leading: LaButton.icon(
        key: const ValueKey('settings.close'),
        icon: const Icon(Icons.close, size: 20),
        onPressed: onBack,
      ),
      title: Text(
        context.l10n.settings,
        textAlign: TextAlign.center,
        style: theme.emphasis,
      ),
      trailing: const FeedbackButton(),
    );

    Widget child;
    if (widget.embedded) {
      child = Column(
        children: [
          topBar,
          jumpField,
          Expanded(child: body),
        ],
      );
    } else if (screenLayout.small) {
      child = LaScaffold(topBar: topBar, body: Column(children: [jumpField, Expanded(child: body)]));
    } else {
      child = LaScaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: ScreenLayout.maxSmallWidth,
              maxWidth: ScreenLayout.maxSmallWidth + 150,
            ),
            child: Column(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: ScreenLayout.maxSmallWidth,
                  ),
                  child: topBar,
                ),
                jumpField,
                Expanded(child: body),
              ],
            ),
          ),
        ),
      );
    }
    return child;
  }
}

/// One section: the uppercase micro label + hairline, then its entries
/// on the shell's row grammar (rows through the label gutter, blocks
/// full-width — they carry their own row labels).
class _SectionBlock extends StatelessWidget {
  const _SectionBlock({
    required this.section,
    required this.leftColumnWidth,
    required this.sectionKey,
    required this.first,
  });

  final SettingsSection section;
  final double leftColumnWidth;
  final GlobalKey sectionKey;
  final bool first;

  @override
  Widget build(final BuildContext context) => Column(
      key: sectionKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: first ? 8 : 24, bottom: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                section.title.toUpperCase(),
                style: shellSectionLabel(context),
              ),
              const SizedBox(height: 6),
              const LaHairline(),
            ],
          ),
        ),
        for (final entry in section.entries)
          Padding(
            key: ValueKey('settings.entry.${entry.keyName}'),
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: entry.isBlock
                ? entry.child
                : SettingsListTile(
                    titleText: entry.title,
                    description: entry.description,
                    leftColumnWidth: leftColumnWidth,
                    child: entry.child,
                  ),
          ),
        const SizedBox(height: 4),
      ],
    );
  }

/// The scroll-spy anchor column (ADR 0032): a table of contents over
/// THIS document — one quiet label per section, the active one in ink
/// with the accent pip. Never renders on a filtered view.
class _TocColumn extends StatelessWidget {
  const _TocColumn({
    required this.sections,
    required this.activeIndex,
    required this.onTap,
  });

  final List<SettingsSection> sections;
  final int activeIndex;
  final void Function(String id) onTap;

  @override
  Widget build(final BuildContext context) {
    final theme = context.laUi;
    return SizedBox(
      key: const ValueKey('settings.toc'),
      width: 148,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(4, 16, 8, 24),
        children: [
          for (final (index, section) in sections.indexed)
            LaPressable(
              key: ValueKey('settings.toc.${section.id}'),
              onTap: () => onTap(section.id),
              radius: theme.smallRadius,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 2,
                      height: 14,
                      decoration: BoxDecoration(
                        color: index == activeIndex
                            ? theme.accent
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        section.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.compact.copyWith(
                          color: index == activeIndex
                              ? theme.ink
                              : theme.inkMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Wave N3 — the human's own profile entry: avatar + name, one tap
/// into their `actor:<id>` surface through the shell's ONE tab router
/// (ViewScope layout showView — the same lane every surface opens by).
class _YourProfileButton extends StatelessWidget {
  const _YourProfileButton();

  @override
  Widget build(final BuildContext context) {
    final service = context.read<RealmChatService?>();
    final human = service?.roster?.all
        .firstWhereOrNull((final actor) => actor.kind == ActorKind.human);
    return LaButton(
      key: const ValueKey('settings.yourProfile'),
      variant: LaButtonVariant.ghost,
      onPressed: () {
        final scope = ViewScope.of(context);
        if (scope == null || human == null) return;
        scope.onChanged(scope.layout.showView('actor:${human.actorId}'));
      },
      icon: human == null
          ? const Icon(Icons.person_outline, size: 18)
          : ActorAvatar(profile: human, size: 20),
      label: human?.displayName ?? context.l10n.actorsNoneYet,
    );
  }
}

/// The ACP agent-servers block: the store's ensure-load side effect,
/// then the pane over a listenable (kept from the old Agent tab
/// verbatim — the pane owns its draft + SAVE discipline).
class _AgentServersBlock extends StatelessWidget {
  const _AgentServersBlock();

  @override
  Widget build(final BuildContext context) {
    if (!context.read<AgentConfigStore>().isLoaded) {
      unawaited(context.read<AgentConfigStore>().load());
    }
    return ListenableBuilder(
      listenable: context.read<AgentConfigStore>(),
      builder: (final context, _) => const AgentConfigSettingsPane(
        closeOnSave: false,
      ),
    );
  }
}

/// The signed-in account block (kept from the retired remote account
/// view verbatim: sign out + the danger zone).
class _ProfileBlock extends StatelessWidget {
  const _ProfileBlock();

  @override
  Widget build(final BuildContext context) {
    final userNotifier = context.watch<UserNotifier>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LaButton(
          onPressed: userNotifier.logout,
          variant: LaButtonVariant.ghost,
          label: 'Sign out',
        ),
        const Gap(24),
        HookBuilder(
          builder: (final context) {
            final isLoading = useState(false);
            return LaBox(
              border: BorderSide(color: context.laUi.danger),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Text(
                    context.l10n.danger,
                    style: context.laUi.body.copyWith(
                      color: context.laUi.danger,
                    ),
                  ),
                  const Spacer(),
                  if (isLoading.value)
                    const LaSpinner()
                  else
                    LaButton(
                      variant: LaButtonVariant.destructiveGhost,
                      label: context.l10n.deleteMyAccount,
                      onPressed: () async {
                        isLoading.value = true;
                        final shouldProceed = await showLaConfirm(
                          context,
                          title: context.l10n.areYouSure,
                          cancelLabel: context.l10n.cancel,
                          confirmLabel: context.l10n.delete,
                          destructive: true,
                          // TODO(arenukvern): add l10n,
                          message:
                              // ignore: lines_longer_than_80_chars
                              'Your account will be deleted. \n\n- All projects will be not deleted since it is stored only your device. \n- Any payment history will be deleted and cannot be restored.',
                        );
                        if (shouldProceed) {
                          await userNotifier.deleteRemoteUser();
                        }

                        isLoading.value = false;
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

/// The unauthorized remote block (kept verbatim from the retired view —
/// the two hardcoded English sentences are pre-existing debt, carried
/// not introduced).
class _LogInBlock extends StatelessWidget {
  const _LogInBlock();

  @override
  Widget build(final BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text('Log In', style: context.laUi.display),
      const Gap(12),
      const Text(
        'Any projects you created will still be saved on your device.',
      ),
      const Gap(12),
      const GoogleSignInButton(),
    ],
  );
}

/// The About block: version + the two platform links (the retired
/// AppInfoScreen's facts, on the row grammar).
class _AboutBlock extends StatelessWidget {
  const _AboutBlock();

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        FutureBuilder<PackageInfo>(
          future: PackageInfo.fromPlatform(),
          builder: (final context, final snapshot) => LaSelectableText(
            l10n.appVersion(
              snapshot.data?.buildNumber ?? '',
              snapshot.data?.version ?? '',
            ),
            style: context.laUi.compact.copyWith(
              color: context.laUi.inkMuted,
            ),
          ),
        ),
        const Gap(8),
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: [
            LaButton(
              variant: LaButtonVariant.link,
              onPressed: () => unawaited(
                _open(AppInfoScreen.privacyPolicyLink),
              ),
              label: l10n.privacyPolicy,
            ),
            LaButton(
              variant: LaButtonVariant.link,
              onPressed: () => unawaited(
                _open(AppInfoScreen.termsAndConditions),
              ),
              label: l10n.termsAndConditions,
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _open(final String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
