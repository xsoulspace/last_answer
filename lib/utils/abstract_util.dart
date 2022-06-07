abstract class AbstractUtil<TValue> {
  AbstractUtil._();
  Future<TValue> load();
  Future<void> save(final TValue value);
}
