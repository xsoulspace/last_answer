// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaginatedPageRequestModel<TData> _$PaginatedPageRequestModelFromJson<TData>(
  Map<String, dynamic> json,
  TData Function(Object? json) fromJsonTData,
) =>
    PaginatedPageRequestModel<TData>(
      page: json['page'] as int? ?? 0,
      limit: json['limit'] as int? ?? 5,
      data: _$nullableGenericFromJson(json['data'], fromJsonTData),
    );

Map<String, dynamic> _$PaginatedPageRequestModelToJson<TData>(
  PaginatedPageRequestModel<TData> instance,
  Object? Function(TData value) toJsonTData,
) =>
    <String, dynamic>{
      'page': instance.page,
      'limit': instance.limit,
      'data': _$nullableGenericToJson(instance.data, toJsonTData),
    };

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) =>
    input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) =>
    input == null ? null : toJson(input);

PaginatedPageResponseModel<TValues>
    _$PaginatedPageResponseModelFromJson<TValues>(
  Map<String, dynamic> json,
  TValues Function(Object? json) fromJsonTValues,
) =>
        PaginatedPageResponseModel<TValues>(
          values:
              (json['values'] as List<dynamic>).map(fromJsonTValues).toList(),
          currentPage: json['currentPage'] as int,
          pagesCount: json['pagesCount'] as int,
        );

Map<String, dynamic> _$PaginatedPageResponseModelToJson<TValues>(
  PaginatedPageResponseModel<TValues> instance,
  Object? Function(TValues value) toJsonTValues,
) =>
    <String, dynamic>{
      'values': instance.values.map(toJsonTValues).toList(),
      'pagesCount': instance.pagesCount,
      'currentPage': instance.currentPage,
    };
