import 'package:shared_models/shared_models.dart';
import 'package:xsoulspace_ui_foundation/xsoulspace_ui_foundation.dart';

import '../../data_models/data_models.dart';
import '../../state/state.dart';

abstract interface class ProjectsLocalDataSource {
  Future<void> putAll({required final List<ProjectModel> projects});
  Future<void> put({required final ProjectModel project});
  Future<void> remove({required final ProjectModelId id});
  Future<List<ProjectModel>> getAll({final RequestProjectsDto? dto});
  Future<PagingControllerPageModel<ProjectModel>> getPaginated({
    required final PaginatedPageRequestModel<RequestProjectsDto> dto,
  });
  Future<ProjectModel?> getById({required final ProjectModelId id});
  Future<List<ProjectModel>> getByIds({
    required final Iterable<ProjectModelId> ids,
  });

  /// Returns document nodes anchored to [parentDocId], oldest first.
  /// Discussion children are excluded from listings; they are resolved
  /// lazily via this method (ADR 0001).
  Future<List<ProjectModel>> getChildren({
    required final ProjectModelId parentDocId,
  });
}
