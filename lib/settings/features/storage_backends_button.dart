import 'dart:convert';

import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/settings/features/features.dart';
import 'package:url_launcher/url_launcher.dart';

/// Settings section for pluggable storage backends.
///
/// Shows all backends in a fixed order (local DB first, GitHub last),
/// each with a short explanation of when it is useful. Selecting a
/// backend makes it the replication target; "Back up now" / "Restore"
/// copy the full data payload to/from it.
class StorageBackendsButton extends StatefulWidget {
  const StorageBackendsButton({super.key});

  @override
  State<StorageBackendsButton> createState() => _StorageBackendsButtonState();
}

class _StorageBackendsButtonState extends State<StorageBackendsButton> {
  final StorageBackendsNotifier _notifier = StorageBackendsNotifier.instance;
  final _pathController = TextEditingController();
  final _meshPathController = TextEditingController();
  final _peerIdController = TextEditingController();
  final _hostController = TextEditingController();
  final _portController = TextEditingController();
  final _relayController = TextEditingController();

  @override
  void dispose() {
    for (final controller in [
      _pathController,
      _meshPathController,
      _peerIdController,
      _hostController,
      _portController,
      _relayController,
    ]) {
      controller.dispose();
    }
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
    await _notifier.replicate(backend: _notifier.active, jsonPayload: payload);
    if (!mounted) return;
    await toasts.showBottomToast(
      message: _notifier.lastReport?.ok ?? false
          ? l10n.storageBackupDone
          : (_notifier.lastReport?.message ?? l10n.storageOperationFailed),
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

    final report = await _notifier.restore(_notifier.active);
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
        ...StorageBackendId.values.map(_tile),
        if (_active == StorageBackendId.mesh) ...[
          TextField(
            controller: _meshPathController,
            decoration: InputDecoration(
              labelText: 'Mesh store path',
              isDense: true,
            ),
            onSubmitted: (value) => unawaited(
              _notifier.setMeshConfig(
                storePath: value,
                relayEndpoint: _notifier.meshRelayEndpoint,
                port: _notifier.meshPort,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _peerIdController,
                  decoration: const InputDecoration(
                    labelText: 'Peer ID',
                    isDense: true,
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _hostController,
                  decoration: const InputDecoration(
                    labelText: 'Host',
                    isDense: true,
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _portController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Port',
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _relayController,
            decoration: const InputDecoration(
              labelText: 'Relay URL',
              hintText: 'ws://192.168.1.20:8080',
              isDense: true,
            ),
            onSubmitted: (value) => unawaited(
              _notifier.setMeshConfig(
                storePath: _notifier.meshStorePath.isEmpty
                    ? 'memory'
                    : _notifier.meshStorePath,
                relayEndpoint: value,
                port: _notifier.meshPort,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.sync),
                label: Text('Sync now'),
                onPressed: () => unawaited(_meshSync()),
              ),
            ],
          ),
        ] else if (_needsPath) ...[
          const SizedBox(height: 8),
          TextField(
            controller: _pathController,
            decoration: InputDecoration(
              labelText: _active == StorageBackendId.filesystem
                  ? l10n.storageFolderPathLabel
                  : l10n.storageGitPathLabel,
              hintText: _notifier.defaultPath.isEmpty
                  ? null
                  : '$_notifier.defaultPath/last-answer',
              isDense: true,
            ),
            onSubmitted: _submitPath,
          ),
          const SizedBox(height: 4),
          Text(l10n.storagePathHint, style: context.textTheme.bodySmall),
        ],
        if (_canReplicate) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              TextButton.icon(
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
        if (_active == StorageBackendId.github)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              icon: const Icon(Icons.cloud_outlined, size: 18),
              label: Text(l10n.storageOpenGithubSetup),
              onPressed: () => unawaited(
                launchUrl(
                  Uri.parse('https://github.com/settings/repositories'),
                  mode: LaunchMode.externalApplication,
                ),
              ),
            ),
          ),
      ],
    );
  }

  StorageBackendId get _active => _notifier.active;

  bool get _needsPath =>
      (_active == StorageBackendId.filesystem &&
          _notifier.filesystemPath.isEmpty) ||
      (_active == StorageBackendId.gitOffline && _notifier.gitPath.isEmpty);

  Future<void> _meshSync() async {
    try {
      final service = await _notifier.ensureMeshService();
      final payload = jsonEncode(await _buildDbSaveJson());
      await service.backup(payload);
      await service.addPeer(peerId: _peerIdController.text.trim());
      await service.sync();
      if (!mounted) return;
      await Toasts.of(context).showBottomToast(message: 'Mesh sync complete');
    } on Object catch (error) {
      if (!mounted) return;
      await Toasts.of(context).showBottomToast(message: '$error');
    }
  }

  bool get _canReplicate =>
      _active != StorageBackendId.localDb &&
      _active != StorageBackendId.github &&
      _active.isSupportedOnPlatform &&
      _notifier.isConfigured;

  void _submitPath(final String value) {
    if (_active == StorageBackendId.filesystem) {
      unawaited(_notifier.setFilesystemPath(value));
    } else if (_active == StorageBackendId.gitOffline) {
      unawaited(_notifier.setGitPath(value));
    }
  }

  Widget _tile(final StorageBackendId id) {
    final l10n = context.l10n;
    final (title, hint) = switch (id) {
      StorageBackendId.localDb => (
        l10n.storageLocalDb,
        l10n.storageLocalDbHint,
      ),
      StorageBackendId.mesh => ('P2P mesh', 'Sync directly between devices'),
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
    final supported = id.isSupportedOnPlatform;
    return RadioListTile.adaptive(
      key: ValueKey('storage-backend-${id.name}'),
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(supported ? title : '$title (${l10n.storageNotAvailable})'),
      subtitle: Text(hint, style: context.textTheme.bodySmall),
      value: id,
      groupValue: _active,
      onChanged: supported
          ? (final _) => unawaited(_notifier.selectBackend(id))
          : null,
    );
  }
}
