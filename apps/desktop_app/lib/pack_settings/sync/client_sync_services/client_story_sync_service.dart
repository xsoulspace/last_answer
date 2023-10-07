import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lastanswer/pack_settings/sync/_abstract/client_sync_service.dart';

class ClientStorySyncService extends HiveClientSyncServiceImpl {
  ClientStorySyncService({required final super.context});

  factory ClientStorySyncService.of(final BuildContext context) =>
      ClientStorySyncService(context: context);
}
