import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:lastanswer/pack_core/pack_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AbstractApiProps<TModel extends HasId> {
  String get tableName;
  SupabaseClient get client;
  TModel Function(Map<String, dynamic> json) get fromJson;
  Map<String, dynamic> Function(TModel model) get modelToJson;
  RealtimeSubscription subscribeToNew(final ValueChanged<TModel> onNew);
  RealtimeSubscription subscribeToUpdates(final ValueChanged<TModel> onUpdate);
  RealtimeSubscription subscribeToDeletes(final ValueChanged<TModel> onDelete);
  Future<TModel?> getById(final String id);
  Future<Iterable<TModel>> getAll();
  Future<TModel> upsert(final TModel model);
  Future<Iterable<TModel>> upsertElements(final Iterable<TModel> models);
  Future<TModel?> delete(final TModel model);
}

abstract class AbstractApi<TModel extends HasId>
    extends AbstractApiProps<TModel> {}

mixin AbstractApiMixin<TModel extends HasId> on AbstractApiProps<TModel> {
  SupabaseQueryBuilder _getBuilder() => client.from(tableName);

  /// ********************************************
  /// *      SUBSCRIPTION START
  /// ********************************************
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
    return _getBuilder().on(SupabaseEventTypes.update, (final payload) {
      final newRecord = payload.newRecord;
      if (newRecord == null) return;
      onUpdate(fromJson(newRecord));
    }).subscribe();
  }

  @override
  RealtimeSubscription subscribeToDeletes(final ValueChanged<TModel> onDelete) {
    return _getBuilder().on(SupabaseEventTypes.delete, (final payload) {
      final newRecord = payload.newRecord;
      if (newRecord == null) return;
      onDelete(fromJson(newRecord));
    }).subscribe();
  }

  /// ********************************************
  /// *      SUBSCRIPTION END
  /// ********************************************

  /// ********************************************
  /// *      METHODS START
  /// ********************************************
  late final _jsonConverter = _jsonConverterBuilder(fromJson);
  @override
  Future<Iterable<TModel>> getAll() async {
    final response =
        await _getBuilder().select().withConverter(_jsonConverter).execute();

    if (response.hasError) throw Exception(response.error);

    return response.data ?? [];
  }

  @override
  Future<TModel?> getById(final String id) async {
    final response = await _getBuilder()
        .select()
        .eq('id', id)
        .withConverter<Iterable<TModel>>(_jsonConverter)
        .execute();
    if (response.hasError) throw Exception(response.error);

    return response.data?.firstOrNull;
  }

  @override
  Future<TModel> upsert(final TModel model) async {
    final response = await _getBuilder()
        .upsert(modelToJson(model))
        .withConverter<Iterable<TModel>>(_jsonConverter)
        .execute();
    if (response.hasError) throw Exception(response.error);
    final data = response.data?.firstOrNull;

    return data!;
  }

  @override
  Future<Iterable<TModel>> upsertElements(final Iterable<TModel> model) async {
    final response = await _getBuilder()
        .upsert(model.map(modelToJson).toList())
        .withConverter<Iterable<TModel>>(_jsonConverter)
        .execute();
    if (response.hasError) throw Exception(response.error);

    return response.data!;
  }

  @override
  Future<TModel?> delete(final TModel model) async {
    final response = await _getBuilder()
        .delete()
        .eq('id', model.id)
        .withConverter<Iterable<TModel>>(_jsonConverter)
        .execute();
    if (response.hasError) throw Exception(response.error);
    final data = response.data?.firstOrNull;

    return data;
  }
}

typedef FromJsonCallback<TModel> = TModel Function(Map<String, dynamic> json);
typedef IterableModelCallback<TModel> = Iterable<TModel> Function(dynamic json);

IterableModelCallback<TModel> _jsonConverterBuilder<TModel>(
  final FromJsonCallback<TModel> fromJson,
) =>
    (final dynamic json) =>
        List.castFrom<dynamic, Map<String, dynamic>>(json ?? []).map(fromJson);
