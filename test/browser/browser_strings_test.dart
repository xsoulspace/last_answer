import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/browser/browser_strings.dart';

void main() {
  test('strings follow the locale', () {
    expect(const BrowserStrings('en').go, 'Go');
    expect(const BrowserStrings('it').go, 'Vai');
    expect(const BrowserStrings('ru').go, 'Открыть');
    expect(const BrowserStrings('fr').go, 'Go');
  });

  test('every locale carries the same keys', () {
    for (final locale in const ['en', 'it', 'ru']) {
      final strings = BrowserStrings(locale);
      expect(strings.addressHint, isNotEmpty, reason: locale);
      expect(strings.windowTitle, isNotEmpty, reason: locale);
      expect(strings.back, isNotEmpty, reason: locale);
      expect(strings.forward, isNotEmpty, reason: locale);
      expect(strings.reload, isNotEmpty, reason: locale);
      expect(strings.go, isNotEmpty, reason: locale);
      expect(strings.close, isNotEmpty, reason: locale);
      expect(strings.unsupportedAddress, isNotEmpty, reason: locale);
      expect(strings.malformedAddress, isNotEmpty, reason: locale);
      expect(strings.loadFailed, isNotEmpty, reason: locale);
    }
  });
}
