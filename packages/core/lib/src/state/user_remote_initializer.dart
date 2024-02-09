import 'dart:async';

import 'package:flutter/material.dart';
import 'package:serverpod_auth_shared_flutter/serverpod_auth_shared_flutter.dart';

import '../../core.dart';

class RemoteUserInitializer {
  RemoteUserInitializer(final BuildContext context)
      : dto = GlobalStatesInitializerDto(context: context) {
    _sessionManager.addListener(_onSessionChanged);
  }
  final GlobalStatesInitializerDto dto;
  SessionManager get _sessionManager =>
      RemoteClient.ofContextAsServerpodImpl(dto.context).sessionManager;
  Future<void> onUserLoad() async {
    await dto.purchasesNotifier.onRemoteUserLoad();
  }

  Future<void> _onSessionChanged() async {
    if (_sessionManager.isSignedIn) {
      await dto.userNotifier.loadRemoteUser(isAfterLogin: true);
    } else {
      dto.userNotifier.resetRemoteUser();
    }
  }

  void dispose() {
    _sessionManager.removeListener(_onSessionChanged);
  }
}
