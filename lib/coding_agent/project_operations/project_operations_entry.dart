import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lastanswer/coding_agent/project_operations/project_operations_session.dart';
import 'package:lastanswer/coding_agent/project_operations/project_operations_widget.dart';
import 'package:oka_core/oka_core.dart' show ProcessLeaseRegistry;
import 'package:path_provider/path_provider.dart';

/// Opens declared project commands without creating a task-board workspace or
/// granting source authority. Process leases belong to the application.
Future<void> openDeclaredProjectOperations(
  BuildContext context, {
  required Directory workspace,
}) async {
  final support = await getApplicationSupportDirectory();
  if (!context.mounted) return;
  final session = ProjectOperationsSession(
    workspace: workspace,
    leaseRegistry: ProcessLeaseRegistry(
      Directory('${support.path}/project_operations/processes'),
    ),
  );
  try {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ProjectOperationsDialog(session: session),
    );
  } finally {
    await session.shutdown();
    session.dispose();
  }
}

/// Ordinary close waits for verified cleanup and keeps failures actionable.
class ProjectOperationsDialog extends StatefulWidget {
  const ProjectOperationsDialog({required this.session, super.key});
  final ProjectOperationsSession session;

  @override
  State<ProjectOperationsDialog> createState() =>
      _ProjectOperationsDialogState();
}

class _ProjectOperationsDialogState extends State<ProjectOperationsDialog> {
  bool _closing = false;
  bool _canPop = false;
  String? _cleanupError;

  Future<void> _close() async {
    if (_closing) return;
    setState(() {
      _closing = true;
      _cleanupError = null;
    });
    try {
      await widget.session.shutdown();
      if (!mounted) return;
      setState(() => _canPop = true);
      Navigator.of(context).pop();
    } on Object catch (error) {
      if (mounted) {
        setState(() {
          _closing = false;
          _cleanupError = '$error';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return PopScope(
      canPop: _canPop,
      child: Dialog(
        key: const Key('project_operations.dialog'),
        insetPadding: const EdgeInsets.all(16),
        child: SizedBox(
          width: (size.width - 32).clamp(0, 850),
          height: (size.height - 32).clamp(0, 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  key: const Key('project_operations.close'),
                  onPressed: _closing ? null : _close,
                  child: Text(_closing ? 'Stopping owned work…' : 'Close'),
                ),
              ),
              if (_cleanupError != null)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    _cleanupError!,
                    key: const Key('project_operations.cleanup_error'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: ProjectOperationsWidget(session: widget.session),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
