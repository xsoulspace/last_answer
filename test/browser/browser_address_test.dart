import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/browser/browser_address.dart';

void main() {
  group('parseBrowserAddress', () {
    test('accepts http and https addresses', () {
      final http = parseBrowserAddress('http://example.com/a');
      expect(http.isAccepted, isTrue);
      expect(http.url!.scheme, 'http');
      expect(http.url!.host, 'example.com');

      final https = parseBrowserAddress('https://example.com/a?b=c');
      expect(https.isAccepted, isTrue);
      expect(https.url!.scheme, 'https');
    });

    test('accepts localhost and loopback addresses', () {
      final local = parseBrowserAddress('http://localhost:8080/x');
      expect(local.isAccepted, isTrue);
      expect(local.url!.host, 'localhost');
      expect(local.url!.port, 8080);

      final bare = parseBrowserAddress('127.0.0.1:3000');
      expect(bare.isAccepted, isTrue);
      expect(bare.url!.scheme, 'http');
      expect(bare.url!.host, '127.0.0.1');
      expect(bare.url!.port, 3000);
    });

    test('completes a bare public host to https', () {
      final parsed = parseBrowserAddress('example.com');
      expect(parsed.isAccepted, isTrue);
      expect(parsed.url!.scheme, 'https');
      expect(parsed.url!.host, 'example.com');
    });

    test('refuses javascript, data and file schemes', () {
      for (final text in const [
        'javascript:alert(1)',
        'data:text/html,<b>x</b>',
        'file:///etc/passwd',
        'about:blank',
      ]) {
        final parsed = parseBrowserAddress(text);
        expect(parsed.isAccepted, isFalse, reason: text);
        expect(
          parsed.rejection,
          BrowserAddressRejection.unsupportedScheme,
          reason: text,
        );
      }
    });

    test('refuses empty and malformed input', () {
      expect(
        parseBrowserAddress('   ').rejection,
        BrowserAddressRejection.empty,
      );
      expect(
        parseBrowserAddress('http://exa mple.com').rejection,
        BrowserAddressRejection.malformed,
      );
      expect(
        parseBrowserAddress('http://').rejection,
        BrowserAddressRejection.malformed,
      );
    });
  });

  group('isNavigableAddress', () {
    test('accepts only http and https with a host', () {
      expect(isNavigableAddress(Uri.parse('https://example.com')), isTrue);
      expect(isNavigableAddress(Uri.parse('http://localhost:1/')), isTrue);
      expect(isNavigableAddress(Uri.parse('javascript:alert(1)')), isFalse);
      expect(isNavigableAddress(Uri.parse('file:///tmp/x')), isFalse);
      expect(isNavigableAddress(null), isFalse);
    });
  });
}
