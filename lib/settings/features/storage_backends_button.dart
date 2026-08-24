import 'dart:convert';

import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/settings/features/features.dart';
import 'package:url_launcher/url_launcher.dart';

/// Settings section for pluggable storage backends.
///
/// Backends behave like checkboxes: the local DB is the always-on live
/// store, and any number of other backends can be enabled at once as
/// replication targets — each enabled backend adds a synced copy
/// ("Back up now" updates all of them). One enabled backend can be
/// marked as primary (star); restores default to it.
class StorageBackendsButton extends StatefulWidget {
  const StorageBackendsButton({super.key});

  @override
  State<StorageBackendsButton> createState() => _StorageBackendsButtonState();
}

class _StorageBackendsButtonState extends State<StorageBackendsButton> {
  final StorageBackendsNotifier _notifier = StorageBackendsNotifier.instance;
  final _pathControllers = <StorageBackendId, TextEditingController>{};

  @override
  void dispose() {
    for (final controller in _pathControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _pathController(final StorageBackendId id) =>
      _pathControllers.putIfAbsent(id, TextEditingController.new);

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

  /// Replicates the payload to every enabled target at once.
  Future<void> _backup() async {
    final l10n = context.l10n;
    final toasts = Toasts.of(context);
    final payload = jsonEncode(await _buildDbSaveJson());
    await _notifier.replicateToAll(jsonPayload: payload);
    if (!mounted) return;
    final report = _notifier.lastReport;
    await toasts.showBottomToast(
      message:
          (report?.ok ?? false) ? l10n.storageBackupDone : (
            report?.message ?? l10n.storageOperationFailed
          ),
    );
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

    final report = await _notifier.restore(_notifier.primary);
    if (!mounted) return;
    if (report.ok && _notifier.lastPayload.isNotEmpty) {
      final dbSave = DbSaveModel.fromJson(
        jsonDecode(_notifier.lastPayload) as Map<String, dynamic>,
      );
      if (!dbSave.isEmpty) {
        final appNotifier = context.read<AppNotifier>();
        final toasts = Toasts.of(context);
        await appNotifier.restoreFromDbSave(dbSave: dbSave, context: context);
        if (mounted) {
          await toasts.showBottomToast(message: l10n.storageRestoreDone);
        }
        return;
      }
    }
    if (mounted) {
      await Toasts.of(context).showBottomToast(
        message: report.ok ? l10n.storageNoBackupFound : report.message,
      );
    }
  }

  @override
  Widget build(final BuildContext context) => ListenableBuilder(
    listenable: _notifier,
    builder: (final context, final _) => _buildBody(context),
  );

  Widget _buildBody(final BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            l10n.storageSectionHint,
            style: context.textTheme.bodySmall,
          ),
        ),
        for (final id in StorageBackendId.values) ...[
          if (id == StorageBackendId.github)
            _githubTile(id)
          else
            _tile(id),
          ..._configSection(id),
        ],
        if (_canBackup) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              TextButton.icon(
                key: const ValueKey('storage-backup-now'),
                icon: const Icon(Icons.backup_outlined),
                label: Text(l10n.storageBackupNow),
                onPressed: () => unawaited(_backup()),
              ),
              TextButton.icon(
                icon: const Icon(Icons.restore),
                label: Text(l10n.storageRestoreNow),
                onPressed: () => unawaited(_restore()),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// Configuration UI shown directly below an *enabled* backend row.
  Iterable<Widget> _configSection(final StorageBackendId id) sync* {
    if (!_notifier.isEnabled(id)) return;
    final l10n = context.l10n;
    switch (id) {
      case StorageBackendId.mesh:
        yield _meshSection();
      case StorageBackendId.filesystem ||
      StorageBackendId.gitOffline when _needsPath(id):
        yield const SizedBox(height: 8);
        yield TextField(
          controller: _pathController(id),
          decoration: InputDecoration(
            labelText: id == StorageBackendId.filesystem
                ? l10n.storageFolderPathLabel
                : l10n.storageGitPathLabel,
            hintText: _notifier.defaultPath.isEmpty
                ? null
                : '${_notifier.defaultPath}/last-answer',
            isDense: true,
          ),
          onSubmitted: (final value) => unawaited(_submitPath(id, value)),
        );
        yield const SizedBox(height: 4);
        yield Text(l10n.storagePathHint, style: context.textTheme.bodySmall);
      case StorageBackendId.localDb ||
      StorageBackendId.filesystem ||
      StorageBackendId.gitOffline ||
      StorageBackendId.github:
        break;
    }
  }

  Widget _meshSection() => const MeshSyncPanel();

  bool _needsPath(final StorageBackendId id) => switch (id) {
    StorageBackendId.filesystem => _notifier.filesystemPath.isEmpty,
    StorageBackendId.gitOffline => _notifier.gitPath.isEmpty,
    _ => false,
  };

  bool get _canBackup => _notifier.replicationTargets.isNotEmpty;

  Future<void> _submitPath(final StorageBackendId id, final String value) =>
      switch (id) {
        StorageBackendId.filesystem => _notifier.setFilesystemPath(value),
        StorageBackendId.gitOffline => _notifier.setGitPath(value),
        _ => Future<void>.value(),
      };

  (String, String) _labels(final StorageBackendId id) {
    final l10n = context.l10n;
    return switch (id) {
      StorageBackendId.localDb => (
        l10n.storageLocalDb,
        l10n.storageLocalDbHint,
      ),
      StorageBackendId.mesh => (
        l10n.storageMeshTitle,
        l10n.storageMeshHint,
      ),
      StorageBackendId.filesystem => (
        l10n.storageFilesystem,
        l10n.storageFilesystemHint,
      ),
      StorageBackendId.gitOffline => (
        l10n.storageGitOffline,
        l10n.storageGitOfflineHint,
      ),
      StorageBackendId.github => (
        l10n.storageGithubOption,
        l10n.storageGithubOptionHint,
      ),
    };
  }

  /// Checkbox tile for a checkable backend ([id] != github).
  Widget _tile(final StorageBackendId id) {
    final l10n = context.l10n;
    final (title, hint) = _labels(id);
    final supported = id.isSupportedOnPlatform;
    final isEnabled = _notifier.isEnabled(id);
    final isPrimary = _notifier.primary == id;
    return CheckboxListTile.adaptive(
      key: ValueKey('storage-backend-${id.name}'),
      contentPadding: EdgeInsets.zero,
      dense: true,
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(supported ? title : '$title (${l10n.storageNotAvailable})'),
      subtitle: Text(hint, style: context.textTheme.bodySmall),
      value: id == StorageBackendId.localDb || isEnabled,
      onChanged: supported && id != StorageBackendId.localDb
          ? (final value) => unawaited(
              _notifier.setEnabled(id, value: value ?? false),
            )
          : null,
      secondary: _primaryStar(id, enabled: isEnabled),
    );
  }

  /// GitHub is not a checkbox here: its credentials and repo are managed
  /// by the dedicated "GitHub Sync" section, so the row just links there.
  Widget _githubTile(final StorageBackendId id) {
    final l10n = context.l10n;
    final (title, hint) = _labels(id);
    return ListTile(
      key: ValueKey('storage-backend-${id.name}'),
      contentPadding: EdgeInsets.zero,
      dense: true,
      enabled: false,
      title: Text(title),
      subtitle: Text(hint, style: context.textTheme.bodySmall),
      trailing: IconButton(
        tooltip: l10n.storageOpenGithubSetup,
        icon: const Icon(Icons.open_in_new, size: 18),
        onPressed: () => unawaited(
          launchUrl(
            Uri.parse('https://github.com/settings/repositories'),
            mode: LaunchMode.externalApplication,
          ),
        ),
      ),
    );
  }

  /// Star affordance marking the primary backend among enabled ones.
  Widget? _primaryStar(final StorageBackendId id, {required bool enabled}) {
    final l10n = context.l10n;
    final isPrimary = _notifier.primary == id;
    if (!enabled || !id.isSupportedOnPlatform) return null;
    return IconButton(
      key: ValueKey('storage-primary-${id.name}'),
      tooltip: isPrimary ? l10n.storagePrimary : l10n.storageSetAsPrimary,
      icon: Icon(isPrimary ? Icons.star : Icons.star_outline, size: 20),
      onPressed: isPrimary ? null : () => unawaited(_notifier.setPrimary(id)),
    );
  }
}
