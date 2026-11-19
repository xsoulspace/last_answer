import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:la_ui/la_ui.dart';
import 'package:lastanswer/data_agents/project_operations/project_operations_session.dart';
import 'package:lastanswer/data_agents/project_operations/project_operations_widget.dart';
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
    await showLaDialog<void>(
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
    final laUi = context.laUi;
    // Center the box (the Material Dialog's own grammar, restored with the
    // kit move): the route hands the dialog builder the FULL window's tight
    // constraints, and the Center loosens them for the box — the content
    // column never inherits window-sized constraints (the Ahem-font
    // overflow paid for 2026-11-16).
    return PopScope(
      canPop: _canPop,
      child: Center(
        child: LaBox(
          key: const Key('project_operations.dialog'),
          floating: true,
          color: laUi.surfaceOverlay,
          border: BorderSide(color: laUi.rule),
          radius: BorderRadius.circular(14),
          width: (size.width - 32).clamp(0, 850).toDouble(),
          height: (size.height - 32).clamp(0, 720).toDouble(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: LaButton(
                  key: const Key('project_operations.close'),
                  variant: LaButtonVariant.ghost,
                  onPressed: _closing ? null : _close,
                  label: _closing ? 'Stopping owned work…' : 'Close',
                ),
              ),
              // The scrollable body owns EVERYTHING the evidence can grow:
              // the cleanup error rides above the ops widget INSIDE the
              // scroll (the verbatim typed result can wrap tall — a
              // non-flex sibling taller than the box overflows it; paid
              // for 2026-11-16).
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_cleanupError != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            _cleanupError!,
                            key: const Key(
                              'project_operations.cleanup_error',
                            ),
                            style: TextStyle(color: laUi.danger),
                          ),
                        ),
                      ProjectOperationsWidget(session: widget.session),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
