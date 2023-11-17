import '../data_sources/interfaces/interfaces.dart';

class DictionariesRepository {
  DictionariesRepository({
    required this.localDataSource,
  });
  final DictionariesLocalDataSource localDataSource;
}
