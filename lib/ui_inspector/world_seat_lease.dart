/// One granted seat: the credential (never persisted here — the
/// authority owns its lifecycle) and the tool allowlist it carries.
final class WorldSeatLease {
  const WorldSeatLease({
    required this.credential,
    required this.tools,
    this.invoke,
    this.disconnect,
    this.actor = '',
  });

  final String credential;
  final Set<String> tools;
  final String actor;
  final Future<Map<String, Object?>> Function(
    String name,
    Map<String, Object?> arguments,
  )?
  invoke;
  final Future<void> Function()? disconnect;
}
