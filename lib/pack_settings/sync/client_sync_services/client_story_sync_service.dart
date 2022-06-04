part of pack_settings;

class ClientStorySyncService extends HiveClientSyncServiceImpl {
  ClientStorySyncService({required final super.context});

  factory ClientStorySyncService.of(final BuildContext context) =>
      ClientStorySyncService(context: context);
}
