import 'dart:async';
import 'dart:io';

import 'package:universal_storage_mesh_transport/'
    'universal_storage_mesh_transport.dart';

/// Locally hosted WebSocket fan-out relay ("main device" mode).
///
/// Thin owner around [AddressedRelayServer] with an ephemeral-port
/// default so users never think about ports.
final class LocalRelayHost {
  AddressedRelayServer? _server;

  bool get isRunning => _server != null;

  int? get boundPort => _server?.port;

  /// Binds the relay to all interfaces; returns the loopback endpoint
  /// this device itself should connect through.
  Future<Uri> start({final int port = 0}) async {
    await stop();
    final server = AddressedRelayServer(port: port);
    final boundPort = await server.start();
    _server = server;
    return Uri.parse('ws://127.0.0.1:$boundPort');
  }

  Future<void> stop() async {
    final server = _server;
    _server = null;
    await server?.dispose();
  }
}

/// Whether this platform can host a mesh relay (dart:io available).
bool get canHostRelay => true;

/// Best-effort LAN IPv4 address advertised to peers inside pairing
/// codes (site-local ranges first, link-local filtered out).
Future<String> detectAdvertiseAddress() async {
  final interfaces = await NetworkInterface.list(
    type: InternetAddressType.IPv4,
  );
  final addresses = <InternetAddress>[
    for (final interface in interfaces) ...interface.addresses,
  ];
  int rank(final InternetAddress address) {
    if (address.isLoopback) return 3;
    if (address.isLinkLocal) return 2;
    return _isSiteLocal(address.address) ? 0 : 1;
  }

  addresses.sort((final a, final b) => rank(a).compareTo(rank(b)));
  return addresses.isEmpty
      ? InternetAddress.loopbackIPv4.address
      : addresses.first.address;
}

bool _isSiteLocal(final String address) {
  final parts = address.split('.');
  if (parts.length != 4) return false;
  final octets = [for (final part in parts) int.tryParse(part) ?? -1];
  if (octets.any((final octet) => octet < 0 || octet > 255)) return false;
  return octets[0] == 10 ||
      (octets[0] == 192 && octets[1] == 168) ||
      (octets[0] == 172 && octets[1] >= 16 && octets[1] <= 31);
}
