part of abstract;

abstract class BasicProjectFields {
  BasicProjectFields({
    required final this.folder,
    required final this.type,
  });
  ProjectFolder? folder;
  final ProjectType type;
}
