import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void testWidget({required final String keyValue}) {
  final Finder widgetFinder = find.byKey(Key(keyValue));
  expect(widgetFinder, findsOneWidget);
}
