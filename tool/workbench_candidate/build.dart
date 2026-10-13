import 'dart:convert';
import 'dart:io';

// Build an isolated acceptance shell without replacing build/macos or reading
// ordinary project storage. The root workspace must already have pub resolved.
Future<void> main(List<String> arguments) async {
  final root = File.fromUri(Platform.script).parent.parent.parent;
  final candidate = Directory('${root.path}/.dart_tool/workbench_candidate');
  Future<void> flutter(List<String> args, Directory cwd) async {
    final process = await Process.start(
      'fvm',
      ['flutter', ...args],
      workingDirectory: cwd.path,
      mode: ProcessStartMode.inheritStdio,
    );
    final code = await process.exitCode;
    if (code != 0) throw ProcessException('fvm flutter', args, '', code);
  }

  if (!Directory('${candidate.path}/macos').existsSync()) {
    await flutter([
      'create',
      '--platforms',
      'macos',
      '--project-name',
      'workbench_candidate',
      '--no-pub',
      candidate.path,
    ], root);
  }
  await flutter(['pub', 'get', '--offline'], candidate);
  final sourceConfig = File('${root.path}/.dart_tool/package_config.json');
  final config = jsonDecode(await sourceConfig.readAsString()) as Map;
  for (final package
      in (config['packages'] as List).cast<Map<String, Object?>>()) {
    package['rootUri'] = sourceConfig.uri
        .resolve(package['rootUri'] as String)
        .toString();
  }
  (config['packages'] as List).add({
    'name': 'workbench_candidate',
    'rootUri': candidate.uri.toString(),
    'packageUri': 'lib/',
    'languageVersion': '3.12',
  });
  await File(
    '${candidate.path}/.dart_tool/package_config.json',
  ).writeAsString(jsonEncode(config));
  final graph =
      jsonDecode(
            await File(
              '${root.path}/.dart_tool/package_graph.json',
            ).readAsString(),
          )
          as Map;
  graph['roots'] = ['workbench_candidate'];
  (graph['packages'] as List).add({
    'name': 'workbench_candidate',
    'version': '1.0.0',
    'dependencies': ['lastanswer', 'flutter'],
    'devDependencies': [],
  });
  await File(
    '${candidate.path}/.dart_tool/package_graph.json',
  ).writeAsString(jsonEncode(graph));
  await File('${candidate.path}/lib/main.dart').writeAsString(
    "import 'package:lastanswer/workbench/workbench_candidate_main.dart' as candidate;\n"
    'Future<void> main() => candidate.main();\n',
  );
  for (final name in ['MainFlutterWindow.swift', 'AppDelegate.swift']) {
    await File(
      '${root.path}/tool/workbench_candidate/macos/$name',
    ).copy('${candidate.path}/macos/Runner/$name');
  }
  await File(
    '${candidate.path}/macos/Runner/Configs/AppInfo.xcconfig',
  ).writeAsString(
    'PRODUCT_NAME = LastAnswerWorkbenchCandidate\n'
    'PRODUCT_BUNDLE_IDENTIFIER = dev.xsoulspace.workbenchCandidate\n'
    'PRODUCT_COPYRIGHT = Last Answer acceptance shell\n',
  );
  final plist = File('${candidate.path}/macos/Runner/Info.plist');
  var content = await plist.readAsString();
  if (!content.contains('<key>LSUIElement</key>')) {
    content = content.replaceFirst(
      '<dict>',
      '<dict>\n<key>LSUIElement</key><true/>',
    );
    await plist.writeAsString(content);
  }
  await flutter(['build', 'macos', '--debug', '--no-pub'], candidate);
  stdout.writeln(
    '${candidate.path}/build/macos/Build/Products/Debug/LastAnswerWorkbenchCandidate.app',
  );
}
