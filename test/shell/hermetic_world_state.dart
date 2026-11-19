import 'package:lastanswer/data_journal/world_state_service.dart';

/// The shell tests' hermetic world read model: the doctor probe is a
/// fixed map, the world home AND the device home point at directories
/// that do not exist (the global-config law's chain — override, then
/// the device global — finds nothing of the operator's machine), and
/// no store is attached — so a refresh touches no real machine state
/// and no timer is ever started (the shell polls only the service it
/// OWNS).
WorldStateService hermeticWorldState({
  final String worldHome = '/nonexistent-world-home',
  final bool daemonLive = false,
  final bool exePresent = false,
}) => WorldStateService(
  debugDoctor: (_) => <String, Object?>{
    'daemon': <String, Object?>{'live': daemonLive, 'worldHome': worldHome},
    'artifacts': {
      'daemon': {
        'present': exePresent,
        'path': '/nonexistent/ecsai_daemon.exe',
      },
    },
  },
  debugWorldHome: worldHome,
  debugDeviceHome: '/nonexistent-device-home',
);
