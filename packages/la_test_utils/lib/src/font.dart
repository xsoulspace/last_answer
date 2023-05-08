import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// This loads fonts for the test runner.
Future<void> loadTestFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await _loadFamily(
    'ui_kit',
    'last_answer_icons',
    [
      'fonts/last_answer_icons.ttf',
      // TODO(arenukvern): investigate idea?
    ],
  );
  await _loadFamily(
    'ui_kit',
    'IBMPlexSans',
    [
      'google_fonts/IBMPlexSans-Bold.ttf',
      // TODO(arenukvern): add other ttf
    ],
  );
}

Future<void> _loadFamily(
  final String package,
  final String name,
  final List<String> assets,
) async {
  final prefix = 'packages/$package/';
  final fontLoader = FontLoader('$prefix$name');

  for (final asset in assets) {
    final bytes = rootBundle.load('$prefix$asset');
    fontLoader.addFont(bytes);
  }
  await fontLoader.load();
}
