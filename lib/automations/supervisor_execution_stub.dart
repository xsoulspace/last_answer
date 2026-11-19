import 'package:flutter/foundation.dart';

final class SupervisorExecution extends ChangeNotifier {
  bool get enabled => false;
  bool get running => false;
  String? get lastError => null;
  String? get lastReport => null;
  Map<String, List<String>> get logLines => const {};
  void enable() => throw UnsupportedError('execution needs a desktop host');
  void pause() {}
  void cancel() {}
  Future<void> stop() async {}
  Future<void> run() =>
      Future.error(UnsupportedError('execution needs a desktop host'));
}
