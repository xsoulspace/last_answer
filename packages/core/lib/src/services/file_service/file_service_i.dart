import 'package:shared_models/shared_models.dart';

abstract interface class FileServiceI {
  static String get filename => 'last_answer_${todayDateTime.yyyyMMDD}.json';
  Future<List> openFile();
  Future<void> saveFile(final List<Map<String, dynamic>> data);
}
