import 'file_service_i.dart';

class FileService implements FileServiceI {
  @override
  Future<List> openFile() {
    // final el = document.createElement('input');
    throw UnimplementedError();
  }

  @override
  Future<void> saveFile(final List<Map<String, dynamic>> data) {
    throw UnimplementedError();
  }
}
