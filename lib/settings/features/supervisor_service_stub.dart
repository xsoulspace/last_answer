import 'package:lastanswer/settings/features/supervisor_view.dart';

/// Non-IO stand-in for the supervisor read surface: hosting records and
/// plan stores needs dart:io, so web reports unsupported instead of
/// crashing.
final class SupervisorService {
  SupervisorService({required this.storeRoot, required this.appRoot});

  final Object storeRoot;
  final Object appRoot;

  static Future<SupervisorService> forDevice() =>
      Future<SupervisorService>.value(
        SupervisorService(storeRoot: Object(), appRoot: Object()),
      );

  Future<SupervisorView> load() =>
      Future<SupervisorView>.value(SupervisorView(supported: false));
}
