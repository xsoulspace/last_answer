part of 'models.dart';

@JsonSerializable(
  explicitToJson: true,
  genericArgumentFactories: true,
)
class PaginatedPageResponseModel<TValues> {
  PaginatedPageResponseModel({
    required this.values,
    required this.currentPage,
    required this.pagesCount,
  });
  factory PaginatedPageResponseModel.fromJson(
    final Map<String, dynamic> json,
    final TValues Function(Object?) fromJsonT,
  ) =>
      _$PaginatedPageResponseModelFromJson(json, fromJsonT);
  Map<String, dynamic> toJson(
    final Map<String, dynamic> Function(TValues) toJsonT,
  ) =>
      _$PaginatedPageResponseModelToJson(this, toJsonT);

  final List<TValues> values;
  final int pagesCount;
  final int currentPage;

  PaginatedPageResponseModel<TValues> copyWith({
    final List<TValues>? values,
    final int? pagesCount,
    final int? currentPage,
  }) =>
      PaginatedPageResponseModel<TValues>(
        values: values ?? this.values,
        pagesCount: pagesCount ?? this.pagesCount,
        currentPage: currentPage ?? this.currentPage,
      );
}
