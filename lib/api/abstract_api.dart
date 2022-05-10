part of api;

abstract class AbstractApi<TModel> {
  SupabaseClient get client;
  TModel getById(final String id);
  Iterable<TModel> getAll();
  void subscribeToNew();
  void subscribeToUpdates();
  void subscribeToDeletes();
}
