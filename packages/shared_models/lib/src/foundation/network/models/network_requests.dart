part of 'models.dart';

@JsonSerializable(
  explicitToJson: true,
  genericArgumentFactories: true,
)
class PaginatedPageRequestModel<TData> {
  PaginatedPageRequestModel({
    this.page = 0,
    this.limit = 10,
    this.data,
  });
  Map<String, dynamic> toJson(
    final Map<String, dynamic> Function(TData) toJsonT,
  ) =>
      _$PaginatedPageRequestModelToJson(this, toJsonT);
  final int page;
  final int limit;
  final TData? data;
}
