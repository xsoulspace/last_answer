import 'dart:io';

import 'package:lastanswer/agent_config/agent_config_persistence.dart';
import 'package:path_provider/path_provider.dart';

/// IO-platform persistence: the single JSON document lives in the
/// app-support directory so a person can edit it by hand (the Zed model).
final class FileAgentConfigPersistence implements AgentConfigPersistence {
  FileAgentConfigPersistence({final String? filePath})
    : _filePathOverride = filePath;

  static const fileName = 'agent_config.json';

  final String? _filePathOverride;
  Future<String>? _resolvedPath;

  Future<String> _resolvePath() {
    final override = _filePathOverride;
    if (override != null) return Future.value(override);
    return _resolvedPath ??= () async {
      final support = await getApplicationSupportDirectory();
      return '${support.path}${Platform.pathSeparator}$fileName';
    }();
  }

  @override
  Future<String?> read() async {
    final file = File(await _resolvePath());
    if (!file.existsSync()) return null;
    return file.readAsString();
  }

  @override
  Future<void> write(final String contents) async {
    final file = File(await _resolvePath());
    await file.parent.create(recursive: true);
    await file.writeAsString(contents, flush: true);
  }
}

AgentConfigPersistence createPlatformAgentConfigPersistence() =>
    FileAgentConfigPersistence();
