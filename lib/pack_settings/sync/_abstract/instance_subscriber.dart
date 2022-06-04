part of pack_settings;

class InstanceSubscriber<TMutable extends HiveObjectWithId,
    TImmutable extends HasId, TMapState extends MapState<TMutable>> {
  InstanceSubscriber({
    required this.updater,
    required this.api,
  });
  final InstanceUpdater<TMutable, TImmutable, TMapState> updater;
  final AbstractApi<TImmutable> api;
  final subscriptions = <RealtimeSubscription>[];

  void subscribe() {
    api
      ..subscribeToNew(_onNew)
      ..subscribeToUpdates(_onUpdate)
      ..subscribeToDeletes(_onDelete);
  }

  Future<void> _onNew(final TImmutable value) async {
    await updater.getAndUpdateByOther([value]);
  }

  Future<void> _onUpdate(final TImmutable value) async {
    await updater.getAndUpdateByOther([value]);
  }

  Future<void> _onDelete(final TImmutable value) async {
    await updater.getAndUpdateByOther([value]);
  }

  void unsubscribe() {
    for (final subscription in subscriptions) {
      subscription.unsubscribe();
    }
  }
}
