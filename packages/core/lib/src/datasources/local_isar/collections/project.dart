part of 'collections.dart';

// https://isar.dev/recipes/string_ids.html#fast-hash-function
@collection
class ProjectIsarCollection with IsarEquatableMixin {
  DateTime? updatedAt;
  String type = ProjectTypes.note.name;
}
