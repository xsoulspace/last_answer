import 'package:lastanswer/coding_agent/meaning_experiment_preparation.dart';
import 'package:lastanswer/common_imports.dart';

String meaningExperimentEntryLabel(String language) => switch (language) {
  'it' => 'Prova una modifica reversibile',
  'ru' => 'Попробовать обратимое изменение',
  _ => 'Try a reversible change',
};

/// Plain primary refusal; the create intent retains the original receipt.
String meaningExperimentRefusalLabel(String language, Object? error) {
  final kind = switch (error) {
    'meaning_experiment_platform_unavailable' ||
    'meaning_runtime_platform_unsupported' => 'platform',
    'meaning_runtime_bundle_missing' ||
    'meaning_runtime_manifest_invalid' ||
    'meaning_runtime_sdk_mismatch' ||
    'meaning_runtime_fixture_lock_mismatch' ||
    'meaning_runtime_fixture_lock_changed' ||
    'meaning_runtime_cache_mismatch' => 'build',
    _ => 'preparation',
  };
  return switch ((language, kind)) {
    ('it', 'platform') =>
      'Questo esperimento non è disponibile su questo dispositivo.',
    ('ru', 'platform') => 'Этот эксперимент недоступен на этом устройстве.',
    (_, 'platform') => 'This experiment is unavailable on this device.',
    ('it', 'build') =>
      'Questo esperimento non è disponibile in questa versione dell’app.',
    ('ru', 'build') => 'Этот эксперимент недоступен в этой версии приложения.',
    (_, 'build') => 'This experiment is unavailable in this app build.',
    ('it', _) => 'Impossibile preparare l’esperimento. Riprova.',
    ('ru', _) => 'Не удалось подготовить эксперимент. Попробуйте ещё раз.',
    _ => 'Could not prepare the experiment. Try again.',
  };
}

/// UI and the published create intent use the existing document/open path.
Future<Map<String, Object?>> openMeaningExperiment(BuildContext context) async {
  final receipt = await MeaningExperimentPreparation.instance.prepare();
  if (receipt['ok'] != true) return receipt;
  if (!context.mounted) {
    return {'ok': false, 'error': 'meaning_experiment_entry_unmounted'};
  }
  final workspace = receipt['workspace']! as String;
  final doc = (ProjectModel.emptyAgent() as ProjectModelDoc).copyWith(
    title: meaningExperimentEntryLabel(
      Localizations.localeOf(context).languageCode,
    ),
    agent: AgentDocModel(
      workspaces: [workspace],
      checkCommand: const ['dart', 'test'],
    ),
  );
  context.read<ProjectsNotifier>().updateEditingProject(doc);
  context.read<OpenedProjectNotifier>().loadProject(
    project: doc,
    context: context,
  );
  return {
    'ok': true,
    'docId': doc.id.value,
    'workspace': workspace,
    'preparation': receipt,
  };
}

final class MeaningExperimentEntry extends StatefulWidget {
  const MeaningExperimentEntry({super.key});
  @override
  State<MeaningExperimentEntry> createState() => _MeaningExperimentEntryState();
}

class _MeaningExperimentEntryState extends State<MeaningExperimentEntry> {
  bool preparing = false;

  @override
  Widget build(BuildContext context) => TextButton(
    key: const Key('home.meaning_experiment'),
    onPressed: preparing
        ? null
        : () async {
            setState(() => preparing = true);
            final result = await openMeaningExperiment(context);
            if (!mounted || !context.mounted) return;
            setState(() => preparing = false);
            if (result['ok'] != true) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    meaningExperimentRefusalLabel(
                      Localizations.localeOf(context).languageCode,
                      result['error'],
                    ),
                    key: const Key('home.meaning_experiment.refusal'),
                  ),
                ),
              );
            }
          },
    child: Text(
      preparing
          ? switch (Localizations.localeOf(context).languageCode) {
              'it' => 'Preparazione…',
              'ru' => 'Подготовка…',
              _ => 'Preparing…',
            }
          : meaningExperimentEntryLabel(
              Localizations.localeOf(context).languageCode,
            ),
    ),
  );
}
