/// Non-IO stand-in for [LocalRelayHost]: hosting is impossible without
/// dart:io (web), so every call reports unsupported instead.
final class LocalRelayHost {
  bool get isRunning => false;
  int? get boundPort => null;

  Future<Uri> start({final int port = 0}) async =>
      throw UnsupportedError(
        'Hosting a mesh relay is not supported on this platform',
      );

  Future<void> stop() async {}
}

/// Whether this platform can host a mesh relay (dart:io available).
bool get canHostRelay => false;

Future<String> detectAdvertiseAddress() async => '';
