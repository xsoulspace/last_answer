part of api;

abstract class AbstractApiProps<TModel> {
  String get tableName;
  SupabaseClient get client;
  TModel Function(Map<String, dynamic> json) get fromJson;
  RealtimeSubscription subscribeToNew(final ValueChanged<TModel> onNew);
  RealtimeSubscription subscribeToUpdates(final ValueChanged<TModel> onUpdate);
  RealtimeSubscription subscribeToDeletes(final ValueChanged<TModel> onDelete);
}

abstract class AbstractApi<TModel> extends AbstractApiProps<TModel> {
  Future<TModel?> getById(final String id);
  Future<Iterable<TModel>> getAll();
}

mixin AbstractApiMixin<TModel> on AbstractApiProps<TModel> {
  SupabaseQueryBuilder _getBuilder() => client.from(tableName);

  @override
  RealtimeSubscription subscribeToNew(final ValueChanged<TModel> onNew) {
    return _getBuilder().on(SupabaseEventTypes.insert, (final payload) {
      final newRecord = payload.newRecord;
      if (newRecord == null) return;
      onNew(fromJson(newRecord));
    }).subscribe();
  }

  @override
  RealtimeSubscription subscribeToUpdates(final ValueChanged<TModel> onUpdate) {
    return _getBuilder().on(SupabaseEventTypes.insert, (final payload) {
      final newRecord = payload.newRecord;
      if (newRecord == null) return;
      onUpdate(fromJson(newRecord));
    }).subscribe();
  }

  @override
  RealtimeSubscription subscribeToDeletes(final ValueChanged<TModel> onDelete) {
    return _getBuilder().on(SupabaseEventTypes.insert, (final payload) {
      final newRecord = payload.newRecord;
      if (newRecord == null) return;
      onDelete(fromJson(newRecord));
    }).subscribe();
  }
}
