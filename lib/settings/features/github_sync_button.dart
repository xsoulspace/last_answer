import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

// ignore: directives_ordering
import 'package:lastanswer/common_imports.dart';
// ignore: directives_ordering
import 'package:lastanswer/settings/features/features.dart';

/// Settings section for GitHub sync: connection toggle, repository
/// selection (with optional subdirectory), and manual backup/restore.
class GithubSyncButton extends StatefulWidget {
  const GithubSyncButton({super.key});

  @override
  State<GithubSyncButton> createState() => _GithubSyncButtonState();
}

class _GithubSyncButtonState extends State<GithubSyncButton> {
  final GithubSyncNotifier _notifier = GithubSyncNotifier();
  final _subdirController = TextEditingController();
  final _newRepoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((final _) {
      if (!mounted) return;
      unawaited(_notifier.checkConnection(context));
    });
  }

  @override
  void dispose() {
    _subdirController.dispose();
    _newRepoController.dispose();
    _notifier.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _buildDbSaveJson() async {
    // ignore: use_build_context_synchronously -- guarded by caller's
    // mounted check before invocation.
    final projectsRepository = context.read<ProjectsRepository>();
    final tagsRepository = context.read<TagsRepository>();
    final allProjects = await projectsRepository.getAll();
    final allTags = await tagsRepository.getAll();
    return DbSaveModel(
      projects: allProjects,
      tags: allTags.values.toList(),
    ).toJson();
  }

  Future<void> _backup() async {
    final l10n = context.l10n;
    final payload = jsonEncode(await _buildDbSaveJson());
    if (!mounted) return;
    await _notifier.backupNow(context, jsonPayload: payload);
    if (_notifier.selection != null && mounted) {
      LaToast.show(context, message: l10n.githubBackupDone);
    }
  }

  Future<void> _restore() async {
    final l10n = context.l10n;
    final shouldContinue = await showLaConfirm(
      context,
      title: l10n.confirmProjectsOwerwrite,
      cancelLabel: l10n.cancel,
      confirmLabel: l10n.confirm,
      message: l10n.beCarefulItsInreversableAction,
    );
    if (!shouldContinue || !mounted) return;

    final payload = await _notifier.restoreNow(context);
    if (!mounted || payload == null) return;
    final dbSave = DbSaveModel.fromJson(jsonDecode(payload));
    if (dbSave.isEmpty) return;
    final appNotifier = context.read<AppNotifier>();
    await appNotifier.restoreFromDbSave(dbSave: dbSave, context: context);
    if (mounted) {
      LaToast.show(context, message: l10n.githubRestoreDone);
    }
  }

  Future<void> _showTokenDialog(final BuildContext context) async {
    final l10n = context.l10n;
    final controller = TextEditingController();
    final confirmed = await showLaDialog<bool>(
      context: context,
      builder: (final dialogContext) => LaDialog(
        titleText: l10n.tokenGuideTitle,
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.tokenStep1, style: dialogContext.laUi.compact),
              const SizedBox(height: 4),
              Text(l10n.tokenStep2, style: dialogContext.laUi.compact),
              LaButton(
                variant: LaButtonVariant.link,
                icon: const Icon(Icons.open_in_new, size: 16),
                label: l10n.openGithubTokens,
                onPressed: () => unawaited(
                  launchUrl(
                    Uri.parse(
                      'https://github.com/settings/personal-access-tokens/new',
                    ),
                    mode: LaunchMode.externalApplication,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(l10n.tokenStep3, style: dialogContext.laUi.compact),
              const SizedBox(height: 4),
              Text(l10n.tokenStep4, style: dialogContext.laUi.compact),
              const SizedBox(height: 4),
              Text(l10n.tokenStep5, style: dialogContext.laUi.compact),
              const SizedBox(height: 12),
              LaField(
                controller: controller,
                obscureText: true,
                placeholder: l10n.tokenFieldLabel,
              ),
              const SizedBox(height: 12),
              Text(l10n.tokenSafety, style: dialogContext.laUi.compact),
              LaButton(
                variant: LaButtonVariant.link,
                icon: const Icon(Icons.manage_accounts, size: 16),
                label: l10n.manageTokens,
                onPressed: () => unawaited(
                  launchUrl(
                    Uri.parse('https://github.com/settings/tokens'),
                    mode: LaunchMode.externalApplication,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          LaButton(
            variant: LaButtonVariant.ghost,
            onPressed: () => Navigator.of(dialogContext).pop(false),
            label: l10n.cancel,
          ),
          LaButton(
            variant: LaButtonVariant.primary,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            label: l10n.connectWithToken,
          ),
        ],
      ),
    );
    final token = controller.text;
    controller.dispose();
    if (confirmed != true || !mounted) return;
    await _notifier.connectWithToken(this.context, token: token);
  }

  @override
  Widget build(final BuildContext context) {
    if (!GithubSyncNotifier.isSupported) {
      return Text(context.l10n.githubSync, style: context.laUi.compact);
    }
    return ListenableBuilder(
      listenable: _notifier,
      builder: (final context, final _) => _buildBody(context),
    );
  }

  Widget _buildBody(final BuildContext context) {
    final l10n = context.l10n;
    if (_notifier.connecting || _notifier.busy) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [LaSpinner(size: 20)],
      );
    }
    if (!_notifier.connected) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LaRow(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            titleText: l10n.githubSync,
            metaText: l10n.connectGithub,
            onTap: () => unawaited(_notifier.connect(context)),
            trailing: LaSwitch(
              value: false,
              onChanged: (final _) => unawaited(_notifier.connect(context)),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: LaButton(
              variant: LaButtonVariant.link,
              onPressed: () => unawaited(_showTokenDialog(context)),
              label: l10n.pasteTokenInstead,
            ),
          ),
        ],
      );
    }

    final selection = _notifier.selection;
    final needsRepo = selection == null || selection.repo.isEmpty;
    _subdirController.text = selection?.subdirectory ?? 'notes';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        LaRow(
          margin: EdgeInsets.zero,
          padding: EdgeInsets.zero,
          titleText: l10n.githubSync,
          onTap: () => unawaited(_notifier.disconnect(context)),
          trailing: LaSwitch(
            value: true,
            onChanged: (final _) => unawaited(_notifier.disconnect(context)),
          ),
        ),
        if (needsRepo)
          ..._repoPicker(l10n)
        else ...[
          LaRow(
            margin: EdgeInsets.zero,
            leading: const Icon(Icons.folder_open, size: 18),
            titleText: '${selection.owner}/${selection.repo}',
            metaText: l10n.chooseRepository,
            onTap: () => unawaited(
              _notifier.selectRepository(owner: selection.owner, repo: ''),
            ),
          ),
          LaField(
            controller: _subdirController,
            placeholder: l10n.subdirectory,
            onSubmitted: _notifier.setSubdirectory,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              LaButton(
                variant: LaButtonVariant.ghost,
                icon: const Icon(Icons.backup_outlined, size: 16),
                label: l10n.backupToGithub,
                onPressed: () => unawaited(_backup()),
              ),
              LaButton(
                variant: LaButtonVariant.ghost,
                icon: const Icon(Icons.restore, size: 16),
                label: l10n.restoreFromGithub,
                onPressed: () => unawaited(_restore()),
              ),
            ],
          ),
        ],
      ],
    );
  }

  List<Widget> _repoPicker(final S l10n) {
    final repos = _notifier.repos;
    final current = _notifier.selection;
    Widget tile({
      required final String owner,
      required final String name,
      final bool? isPrivate,
    }) => LaRow(
      margin: EdgeInsets.zero,
      leading: Icon(
        (isPrivate ?? true) ? Icons.lock_outline : Icons.lock_open_outlined,
        size: 18,
      ),
      titleText: '$owner/$name',
      onTap: () => unawaited(
        _notifier
            .selectRepository(owner: owner, repo: name)
            .then((_) => _syncSubdirField()),
      ),
      trailing: current?.owner == owner && current?.repo == name
          ? const Icon(Icons.check, size: 16)
          : null,
    );

    return [
      Text(l10n.chooseRepository, style: context.laUi.body),
      const SizedBox(height: 8),
      ...repos
          .take(20)
          .map(
            (final repo) => tile(
              owner: repo.fullName.contains('/')
                  ? repo.fullName.split('/').first
                  : '',
              name: repo.name,
              isPrivate: repo.isPrivate,
            ),
          ),
      const LaHairline(),
      Text(l10n.createNewRepository, style: context.laUi.body),
      const SizedBox(height: 4),
      Row(
        children: [
          Expanded(
            child: LaField(
              controller: _newRepoController,
              placeholder: l10n.repoNameHint,
            ),
          ),
          LaButton.icon(
            tooltip: l10n.createNewRepository,
            icon: const Icon(Icons.add_circle_outline, size: 18),
            onPressed: () => unawaited(
              _notifier.createRepository(
                context: context,
                name: _newRepoController.text,
              ),
            ),
          ),
        ],
      ),
    ];
  }

  void _syncSubdirField() {
    _subdirController.text = _notifier.selection?.subdirectory ?? 'notes';
  }
}
