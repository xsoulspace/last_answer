import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lastanswer/pack_core/abstract/primitives/loadable.dart';

ConnectivityNotifier createConnectivityNotifier(
  final BuildContext context,
) =>
    ConnectivityNotifier();

class ConnectivityNotifier extends ChangeNotifier implements Loadable {
  StreamSubscription<ConnectivityResult>? connectionSubscription;
  final _connectivity = Connectivity();

  ConnectivityResult _connectivityResult = ConnectivityResult.none;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  set isConnected(final bool isConnected) {
    _isConnected = isConnected;
    notifyListeners();
  }

  bool get isNotConnected => !isConnected;

  @override
  Future<void> onLoad({required final BuildContext context}) async {
    await checkConnectivity();
    connectionSubscription = _listenConnectivityChanges(_onConnectivityChange);
  }

  void _onConnectivityChange(final ConnectivityResult result) {
    _connectivityResult = result;
    isConnected = _connectivityResult != ConnectivityResult.none;
  }

  StreamSubscription<ConnectivityResult> _listenConnectivityChanges(
    final ValueChanged<ConnectivityResult> listener,
  ) {
    return _connectivity.onConnectivityChanged.listen(listener);
  }

  Future<ConnectivityResult> checkConnectivity() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      _onConnectivityChange(await _connectivity.checkConnectivity());
    } on PlatformException {
      _onConnectivityChange(ConnectivityResult.none);
    }

    return _connectivityResult;
  }

  @override
  void dispose() {
    connectionSubscription?.cancel();
    super.dispose();
  }
}
