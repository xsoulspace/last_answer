/// The paged-projects request envelope (moved from
/// packages/shared_models network models, ADR 0038 — an app-domain
/// model).
library;

/// A single page request against the paged projects source. [toJsonT]
/// serializes the payload with the caller's own DTO codec — the envelope
/// itself carries no codegen.
class PaginatedPageRequestModel<TData> {
  PaginatedPageRequestModel({
    this.page = 0,
    this.limit = 10,
    this.data,
  });
  final int page;
  final int limit;
  final TData? data;
}
