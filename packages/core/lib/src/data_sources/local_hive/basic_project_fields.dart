part of 'hive_models.dart';

abstract class BasicProjectFields {
  BasicProjectFields({
    required this.folder,
    required this.type,
  });
  ProjectFolder? folder;
  final ProjectTypes type;
}
