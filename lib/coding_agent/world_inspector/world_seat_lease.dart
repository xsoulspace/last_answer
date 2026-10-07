/// One granted seat: the credential (never persisted here — the
/// authority owns its lifecycle) and the tool allowlist it carries.
final class WorldSeatLease {
  const WorldSeatLease({required this.credential, required this.tools});

  final String credential;
  final Set<String> tools;
}
