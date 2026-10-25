/// Address-entry parsing for the embedded browser window.
///
/// Pure Dart on purpose: no platform imports, no plugin imports, so the
/// rules are testable on the Dart VM and identical on every target.
///
/// The policy is deliberately narrow. A browser that can type `javascript:`
/// or `file:` in its address bar becomes a capability leak (script
/// execution and local file access) dressed as a convenience. The address
/// entry therefore accepts `http`/`https` only, plus bare hosts that are
/// completed to `http` for loopback and `https` for everything else.
/// Localhost is a first-class case: the app's own local servers are
/// reached by the human during development.
library;

/// Why an address was refused.
enum BrowserAddressRejection {
  /// Nothing was typed.
  empty,

  /// The text is not a usable host or URL.
  malformed,

  /// The scheme is known but not allowed for address navigation.
  unsupportedScheme,
}

/// The outcome of parsing an address-entry string.
final class BrowserAddress {
  const BrowserAddress._({this.url, this.rejection, this.scheme});

  /// Builds an accepted address.
  const BrowserAddress.accepted(Uri url) : this._(url: url);

  /// Builds a refused address.
  const BrowserAddress.rejected(
    BrowserAddressRejection rejection, {
    String? scheme,
  }) : this._(rejection: rejection, scheme: scheme);

  /// The parsed URL, when [rejection] is null.
  final Uri? url;

  /// Why the address was refused, when it was.
  final BrowserAddressRejection? rejection;

  /// The scheme that was refused, when the refusal was scheme-based.
  final String? scheme;

  /// Whether the address is navigable.
  bool get isAccepted => rejection == null && url != null;
}

/// Hosts that are reached over plain HTTP when the human types them bare.
const Set<String> kLoopbackHosts = <String>{
  'localhost',
  '127.0.0.1',
  '0.0.0.0',
  '[::1]',
  '::1',
};

/// Schemes the address entry may navigate to.
const Set<String> kAllowedAddressSchemes = <String>{'http', 'https'};

/// Schemes that are refused even when the text could be read as a host.
const Set<String> kRefusedSchemes = <String>{
  'javascript',
  'data',
  'file',
  'about',
  'blob',
  'vbscript',
  'mailto',
  'tel',
  'chrome',
  'intent',
  'content',
  'jar',
};

final RegExp _hostWithOptionalPort = RegExp(
  r'^[A-Za-z0-9._~%\-\[\]:]+(:\d{1,5})?(/[^\s]*)?$',
);

final RegExp _schemePart = RegExp(r'^([A-Za-z][A-Za-z0-9+.\-]*):');

/// `host:port` — ambiguous with a scheme, so it is resolved as a host.
final RegExp _hostWithPort = RegExp(
  r'^[A-Za-z0-9._~%\-]+(:\d{1,5})?(/[^\s]*)?$',
);

/// Parses an address-entry string into a navigable [Uri] or a refusal.
///
/// Rules:
/// * `http://` and `https://` are accepted for any host, including
///   `localhost` and loopback addresses.
/// * A bare host (`example.com`, `localhost:8080`, `127.0.0.1:3000/x`) is
///   completed: `http` for loopback hosts, `https` otherwise.
/// * Any other scheme (`javascript:`, `data:`, `file:`, `blob:`, `about:`)
///   is refused by scheme, and never navigated to.
/// * Whitespace inside the text, or text that is not host-shaped, is
///   refused as malformed.
BrowserAddress parseBrowserAddress(String raw) {
  final text = raw.trim();
  if (text.isEmpty) {
    return const BrowserAddress.rejected(BrowserAddressRejection.empty);
  }
  if (text.contains(RegExp(r'\s'))) {
    return const BrowserAddress.rejected(BrowserAddressRejection.malformed);
  }

  final schemeMatch = _schemePart.firstMatch(text);
  if (schemeMatch != null) {
    final scheme = schemeMatch.group(1)!.toLowerCase();
    if (kRefusedSchemes.contains(scheme)) {
      return BrowserAddress.rejected(
        BrowserAddressRejection.unsupportedScheme,
        scheme: scheme,
      );
    }
    if (kAllowedAddressSchemes.contains(scheme)) {
      final Uri parsed;
      try {
        parsed = Uri.parse(text);
      } on FormatException {
        return const BrowserAddress.rejected(BrowserAddressRejection.malformed);
      }
      if (parsed.host.isEmpty) {
        return const BrowserAddress.rejected(BrowserAddressRejection.malformed);
      }
      return BrowserAddress.accepted(parsed);
    }
    // An unknown scheme is only read as a host when it is host-shaped
    // (`host:port`); otherwise it stays a refusal.
    if (!_hostWithPort.hasMatch(text)) {
      return BrowserAddress.rejected(
        BrowserAddressRejection.unsupportedScheme,
        scheme: scheme,
      );
    }
  }

  if (!_hostWithOptionalPort.hasMatch(text)) {
    return const BrowserAddress.rejected(BrowserAddressRejection.malformed);
  }
  final Uri asHttps;
  try {
    asHttps = Uri.parse('https://$text');
  } on FormatException {
    return const BrowserAddress.rejected(BrowserAddressRejection.malformed);
  }
  if (asHttps.host.isEmpty) {
    return const BrowserAddress.rejected(BrowserAddressRejection.malformed);
  }
  final host = asHttps.host.toLowerCase();
  if (!kLoopbackHosts.contains(host)) {
    return BrowserAddress.accepted(asHttps);
  }
  final Uri asHttp;
  try {
    asHttp = Uri.parse('http://$text');
  } on FormatException {
    return const BrowserAddress.rejected(BrowserAddressRejection.malformed);
  }
  return BrowserAddress.accepted(asHttp);
}

/// Whether a [Uri] may be used for address navigation.
bool isNavigableAddress(Uri? url) {
  if (url == null) return false;
  final scheme = url.scheme.toLowerCase();
  if (!kAllowedAddressSchemes.contains(scheme)) return false;
  return url.host.isNotEmpty;
}
