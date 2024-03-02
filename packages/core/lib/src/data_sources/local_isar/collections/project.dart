part of 'collections.dart';

@collection
class ProjectIsarCollection with IsarEquatableMixin {
  DateTime? updatedAt;
  List<String> tags = [];
  String type = ProjectTypes.note.name;

  @Index()
  List<String> get contentWords => jsonContent.split(' ');
}
