import 'dart:async';

import 'package:serverpod_auth_shared_flutter/serverpod_auth_shared_flutter.dart';

import '../../core.dart';

class RemoteUserInitializer {
  RemoteUserInitializer({required this.dto}) {
    _sessionManager.addListener(_onSessionChanged);
  }
  final GlobalStatesInitializerDto dto;
  SessionManager get _sessionManager =>
      RemoteClient.ofContextAsServerpodImpl(dto.context).sessionManager;
  Future<void> onUserLoad() async {
    /// add any methods to load remote data
  }

  void _onSessionChanged() {
    if (_sessionManager.isSignedIn) {
      unawaited(dto.userNotifier.loadRemoteUser(isAfterLogin: true));
    } else {
      dto.userNotifier.resetRemoteUser();
    }
  }

  void dispose() {
    _sessionManager.removeListener(_onSessionChanged);
  }
}
