import '../datasources/interfaces/interfaces.dart';

class DictionariesRepository {
  DictionariesRepository({
    required this.localDataSource,
  });
  final DictionariesLocalDataSource localDataSource;
}
