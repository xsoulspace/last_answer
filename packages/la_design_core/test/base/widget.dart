import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:la_design_core/la_design_core.dart';
import 'package:la_test_utils/la_test_utils.dart';

typedef TestConfigurationBuilder = Widget Function(
  Widget child,
);

void testAppWidgets(
  final String name,
  final Map<String, Widget> widgets, {
  final Size baseSize = const Size(1024.0, 800.0),
}) {
  final configurations = <TestConfigurationBuilder>[
    (final child) => Expanded(
          child: Center(
            child: child,
          ),
        ),
    (final child) => Expanded(
          child: ConstrainedBox(
            constraints: const BoxConstraints.expand(),
            child: child,
          ),
        ),
  ];

  appTestWidgets(
    name,
    widgets.map(
      (final key, final value) => MapEntry(
        key,
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: AppTheme(
            data: AppThemeData.regular(
              appLogo: StringPicture(
                SvgPicture.svgStringDecoderBuilder,
                '<svg></svg>',
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...configurations.map((final builder) => builder(value))
              ],
            ),
          ),
        ),
      ),
    ),
    size: Size(
      800,
      1024.0 * configurations.length,
    ),
  );
}
