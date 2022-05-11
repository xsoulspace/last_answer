part of api;

abstract class AbstractApiProps<TModel> {
  String get tableName;
  SupabaseClient get client;
  TModel Function(Map<String, dynamic> json) get fromJson;
  Map<String, dynamic> Function(TModel model) get modelToJson;
  RealtimeSubscription subscribeToNew(final ValueChanged<TModel> onNew);
  RealtimeSubscription subscribeToUpdates(final ValueChanged<TModel> onUpdate);
  RealtimeSubscription subscribeToDeletes(final ValueChanged<TModel> onDelete);
  Future<TModel?> getById(final String id);
  Future<Iterable<TModel>> getAll();
}

abstract class AbstractApi<TModel> extends AbstractApiProps<TModel> {}

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

  @override
  Future<Iterable<TModel>> getAll() async {
    final response = await _getBuilder().select().execute();
    final data = response.data;

    if (response.hasError) throw Exception(data);

    return List.castFrom<dynamic, Map<String, dynamic>>(data).map(
      fromJson,
    );
  }

  @override
  Future<TModel?> getById(final String id) async {
    final response = await _getBuilder().select().eq('id', id).execute();
    final data = response.data;
    if (response.hasError) throw Exception(data);

    return List.castFrom<dynamic, Map<String, dynamic>>(data)
        .map(fromJson)
        .firstOrNull;
  }

  Future<TModel> create(final TModel model) async {
    final response = await _getBuilder()
        .insert(
          modelToJson(model),
        )
        .execute();
    final data = response.data;
    if (response.hasError) throw Exception(data);

    return List.castFrom<dynamic, Map<String, dynamic>>(data)
        .map(fromJson)
        .first;
  }

  Future<TModel> update(final TModel model) async {
    final response = await _getBuilder()
        .update(
          modelToJson(model),
          returning: ReturningOption.minimal,
        )
        .execute();
    final data = response.data;
    if (response.hasError) throw Exception(data);

    return List.castFrom<dynamic, Map<String, dynamic>>(data)
        .map(fromJson)
        .first;
  }
}
