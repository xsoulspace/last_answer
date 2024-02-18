abstract interface class FileServiceI {
  Future<List> openFile();
  Future<void> saveFile(final List<Map<String, dynamic>> data);
}
