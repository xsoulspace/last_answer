/// ACP as one provider. A model under it is an agent this device can
/// launch: a detected catalog install, or a saved server command.
/// A saved server whose id matches a catalog id replaces that command.
library;

import 'dart:io';

import 'package:headless_core/headless_core.dart';

/// One model of provider `acp`.
final class AcpModelChoice {
  const AcpModelChoice({
    required this.id,
    required this.label,
    required this.command,
    this.arguments = const [],
    this.environment = const {},
  });

  final String id;
  final String label;
  final String command;
  final List<String> arguments;
  final Map<String, String> environment;
}

/// A saved ACP command, already lifted off the settings document.
typedef AcpServerFact = ({
  String id,
  String label,
  String command,
  List<String> arguments,
  Map<String, String> environment,
});

/// Detected installs first, then saved servers. A saved id replaces the
/// catalog command with the same id.
List<AcpModelChoice> acpModelCatalog({
  final List<AcpAgentInstallation>? detected,
  final List<AcpServerFact> servers = const [],
}) {
  final byId = <String, AcpModelChoice>{};
  for (final installation in detected ?? const <AcpAgentInstallation>[]) {
    final id = installation.entry.id.trim();
    final command = installation.path.trim();
    if (id.isEmpty || command.isEmpty) continue;
    byId[id] = AcpModelChoice(
      id: id,
      label: installation.entry.displayName,
      command: command,
      arguments: installation.entry.arguments,
    );
  }
  for (final server in servers) {
    final id = server.id.trim();
    final command = server.command.trim();
    if (id.isEmpty || command.isEmpty) continue;
    final label = server.label.trim();
    byId[id] = AcpModelChoice(
      id: id,
      label: label.isEmpty ? id : label,
      command: command,
      arguments: server.arguments,
      environment: server.environment,
    );
  }
  final models = byId.values.toList()
    ..sort(
      (final a, final b) =>
          a.label.toLowerCase().compareTo(b.label.toLowerCase()),
    );
  return models;
}

/// A per-actor scratch directory for an ACP session that the beat did
/// not name a workspace for. Never the device's first project folder.
String acpActorWorkspace(final String actorId) {
  final safe = actorId.replaceAll(RegExp('[^A-Za-z0-9._-]'), '_');
  final dir = Directory('${Directory.systemTemp.path}/last_answer_acp/$safe');
  if (!dir.existsSync()) dir.createSync(recursive: true);
  return dir.path;
}
