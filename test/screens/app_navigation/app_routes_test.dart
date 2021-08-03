import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/screens/app_navigator/app_navigator.dart';

void main() {
  group('[app route config]', () {
    test('has no empty routes', () {
      for (final routeName in AppRoutesName.values) {
        expect(routeName, isNotEmpty);
        expect(routeName, isNotNull);
      }
    });
  });
}
