import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'font.dart';
import 'image_mock.dart';

void appTestWidgets(
  final String name,
  final Map<String, Widget> widgets, {
  final Size size = const Size(1024.0, 800.0),
}) =>
    testWidgets(
      'Rendering $name',
      (final tester) async {
        await mockNetworkImagesFor(() async {
          await ensureImagesPreloaded(tester);
          await loadTestFonts();

          for (final child in widgets.entries) {
            final key = UniqueKey();

            tester.binding.window.devicePixelRatioTestValue = 2.0;
            tester.binding.window.physicalSizeTestValue = Size(
              size.width * 2,
              size.height * 2,
            );

            await tester.pumpWidget(
              KeyedSubtree(
                key: key,
                child: child.value,
              ),
            );

            await tester.pumpAndSettle(
              const Duration(milliseconds: 100),
              EnginePhase.paint,
            );

            await expectLater(
              find.byKey(key),
              matchesGoldenFile('renders/$name/${child.key}.png'),
            );
          }
        });
      },
    );
