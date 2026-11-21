import 'package:flutter_test/flutter_test.dart';
import 'package:headless_core/headless_core.dart';
import 'package:lastanswer/data_agents/acp/acp_provider.dart';

void main() {
  test('a saved server replaces the catalog command with the same id', () {
    final grok = AcpAgentCatalog.defaultEntries.firstWhere(
      (final entry) => entry.id == 'grok',
    );
    final models = acpModelCatalog(
      detected: [
        AcpAgentInstallation(entry: grok, path: '/usr/local/bin/grok'),
      ],
      servers: const [
        (
          id: 'grok',
          label: 'My Grok',
          command: '/custom/grok',
          arguments: ['agent', 'stdio'],
          environment: {'XAI_API_KEY': 'present'},
        ),
        (
          id: 'pi',
          label: 'Pi',
          command: '/usr/local/bin/pi',
          arguments: <String>[],
          environment: <String, String>{},
        ),
      ],
    );
    final byId = {for (final model in models) model.id: model};
    expect(byId['grok']!.command, '/custom/grok');
    expect(byId['grok']!.label, 'My Grok');
    expect(byId['grok']!.environment['XAI_API_KEY'], 'present');
    expect(byId['pi']!.command, '/usr/local/bin/pi');
    expect(models.map((final model) => model.label), ['My Grok', 'Pi']);
  });

  test('empty commands are not models', () {
    final models = acpModelCatalog(
      servers: const [
        (
          id: 'blank',
          label: 'Blank',
          command: '  ',
          arguments: <String>[],
          environment: <String, String>{},
        ),
      ],
    );
    expect(models, isEmpty);
  });
}
