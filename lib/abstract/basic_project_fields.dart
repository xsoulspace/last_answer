import 'package:lastanswer/abstract/project_folder.dart';
import 'package:lastanswer/pack_core/pack_core.dart';

abstract class BasicProjectFields {
  BasicProjectFields({
    required final this.folder,
    required final this.type,
  });
  ProjectFolder? folder;
  final ProjectType type;
}
