import '../datasources/interfaces/interfaces.dart';

class ProjectsRepository {
  ProjectsRepository({
    required this.localDataSource,
  });
  final ProjectsLocalDataSource localDataSource;
}
