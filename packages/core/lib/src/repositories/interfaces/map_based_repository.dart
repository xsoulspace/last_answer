abstract base class MapBasedRepository<TKey, TValue> {
  void putAll(final Map<TKey, TValue> map);
  Map<TKey, TValue> getAll();
}
