import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../remote/remote.dart';

abstract class RemoteClient {
  const RemoteClient._();
  Future<void> onLoad();

  static RemoteClientServerpodImpl ofContextAsServerpodImpl(
    final BuildContext context,
  ) =>
      context.read<RemoteClient>() as RemoteClientServerpodImpl;
}
