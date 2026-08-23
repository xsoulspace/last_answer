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
    final toasts = Toasts.of(context);
    final payload = jsonEncode(await _buildDbSaveJson());
    if (!mounted) return;
    await _notifier.backupNow(context, jsonPayload: payload);
    if (_notifier.selection != null && mounted) {
      await toasts.showBottomToast(message: l10n.githubBackupDone);
    }
  }

  Future<void> _restore() async {
    final l10n = context.l10n;
    final modals = Modals.of(context);
    final shouldContinue = await modals.showWarningDialog(
      title: l10n.confirmProjectsOwerwrite,
      noActionText: l10n.cancel,
      yesActionText: l10n.confirm,
      description: l10n.beCarefulItsInreversableAction,
    );
    if (!shouldContinue || !mounted) return;

    final payload = await _notifier.restoreNow(context);
    if (!mounted || payload == null) return;
    final dbSave = DbSaveModel.fromJson(jsonDecode(payload));
    if (dbSave.isEmpty) return;
    final appNotifier = context.read<AppNotifier>();
    final toasts = Toasts.of(context);
    await appNotifier.restoreFromDbSave(dbSave: dbSave, context: context);
    if (mounted) {
      await toasts.showBottomToast(message: l10n.githubRestoreDone);
    }
  }

  Future<void> _showTokenDialog(final BuildContext context) async {
    final l10n = context.l10n;
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (final dialogContext) => AlertDialog(
        title: Text(l10n.tokenGuideTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.tokenStep1, style: dialogContext.textTheme.bodySmall),
              const SizedBox(height: 4),
              Text(l10n.tokenStep2, style: dialogContext.textTheme.bodySmall),
              TextButton.icon(
                icon: const Icon(Icons.open_in_new, size: 16),
                label: Text(
                  l10n.openGithubTokens,
                  style: dialogContext.textTheme.bodySmall,
                ),
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
              Text(l10n.tokenStep3, style: dialogContext.textTheme.bodySmall),
              const SizedBox(height: 4),
              Text(l10n.tokenStep4, style: dialogContext.textTheme.bodySmall),
              const SizedBox(height: 4),
              Text(l10n.tokenStep5, style: dialogContext.textTheme.bodySmall),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.tokenFieldLabel,
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              Text(l10n.tokenSafety, style: dialogContext.textTheme.bodySmall),
              TextButton.icon(
                icon: const Icon(Icons.manage_accounts, size: 16),
                label: Text(
                  l10n.manageTokens,
                  style: dialogContext.textTheme.bodySmall,
                ),
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
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.connectWithToken),
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
      return Text(
        context.l10n.githubSync,
        style: context.textTheme.bodySmall,
      );
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
        children: [
          SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      );
    }
    if (!_notifier.connected) {
      return SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        title: Text(l10n.githubSync),
        subtitle: Text(l10n.connectGithub),
        value: false,
        onChanged: (final _) => unawaited(_notifier.connect(context)),
        secondary: TextButton(
          onPressed: () => unawaited(_showTokenDialog(context)),
          child: Text(l10n.pasteTokenInstead),
        ),
      );
    }

    final selection = _notifier.selection;
    final needsRepo = selection == null || selection.repo.isEmpty;
    _subdirController.text = selection?.subdirectory ?? 'notes';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.githubSync),
          value: true,
          onChanged: (final _) => unawaited(_notifier.disconnect(context)),
        ),
        if (needsRepo)
          ..._repoPicker(l10n)
        else ...[
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.folder_open),
            title: Text('${selection.owner}/${selection.repo}'),
            subtitle: Text(l10n.chooseRepository),
            onTap: () => unawaited(
              _notifier.selectRepository(owner: selection.owner, repo: ''),
            ),
          ),
          TextField(
            controller: _subdirController,
            decoration: InputDecoration(
              labelText: l10n.subdirectory,
              isDense: true,
            ),
            onSubmitted: _notifier.setSubdirectory,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.backup_outlined),
                label: Text(l10n.backupToGithub),
                onPressed: () => unawaited(_backup()),
              ),
              TextButton.icon(
                icon: const Icon(Icons.restore),
                label: Text(l10n.restoreFromGithub),
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
    }) =>
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            (isPrivate ?? true) ? Icons.lock_outline : Icons.lock_open_outlined,
            size: 18,
          ),
          title: Text('$owner/$name'),
          onTap: () => unawaited(
            _notifier
                .selectRepository(owner: owner, repo: name)
                .then((_) => _syncSubdirField()),
          ),
          trailing: current?.owner == owner && current?.repo == name
              ? const Icon(Icons.check)
              : null,
        );

    return [
      Text(l10n.chooseRepository, style: context.textTheme.bodyMedium),
      const SizedBox(height: 8),
      ...repos.take(20).map(
            (final repo) => tile(
              owner: repo.fullName.contains('/')
                  ? repo.fullName.split('/').first
                  : '',
              name: repo.name,
              isPrivate: repo.isPrivate,
            ),
          ),
      const Divider(),
      Text(l10n.createNewRepository, style: context.textTheme.bodyMedium),
      const SizedBox(height: 4),
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: _newRepoController,
              decoration: InputDecoration(
                hintText: l10n.repoNameHint,
                isDense: true,
              ),
            ),
          ),
          IconButton(
            tooltip: l10n.createNewRepository,
            icon: const Icon(Icons.add_circle_outline),
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
