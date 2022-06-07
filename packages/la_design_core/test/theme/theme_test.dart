import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:la_design_core/la_design_core.dart';
import 'package:la_design_core/src/theme/data/form_factor.dart';
import 'package:la_design_core/src/theme/responsive_theme.dart';
import 'package:la_test_utils/la_test_utils.dart';

import 'library/library.dart';

void main() {
  _renderLibrary(
    AppFormFactor.medium,
  );
  _renderLibrary(
    AppFormFactor.medium,
  );
  _renderLibrary(
    AppFormFactor.medium,
  );
  _renderLibrary(
    AppFormFactor.small,
  );
  _renderLibrary(
    AppFormFactor.small,
  );
}

Future<void> _renderLibrary(final AppFormFactor formFactor) async {
  testWidgets('${formFactor.name} theme rendering', (final tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await loadTestFonts();

    final key = UniqueKey();

    tester.binding.window.physicalSizeTestValue =
        Size(AppThemeColorMode.values.length * 700.0, 1500);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    await tester.pumpWidget(
      Row(
        key: key,
        textDirection: TextDirection.ltr,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...AppThemeColorMode.values.map(
            (final colorMode) => Expanded(
              child: AppThemeLibrary(
                colorMode: colorMode,
                formFactor: formFactor,
              ),
            ),
          )
        ],
      ),
    );

    await expectLater(
      find.byKey(key),
      matchesGoldenFile('renders/${formFactor.name}.png'),
    );
  });
}
