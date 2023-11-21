import 'package:lastanswer/_library/widgets/widgets.dart';
import 'package:lastanswer/common_imports.dart';

class IdeaViewBlocDto {
  IdeaViewBlocDto({
    required this.initialIdea,
    required this.context,
  }) : openedProjectNotifier = context.read();
  final ProjectModelIdea initialIdea;
  final BuildContext context;
  final OpenedProjectNotifier openedProjectNotifier;
}

class IdeaViewBloc extends ValueNotifier<ProjectModelIdea> {
  IdeaViewBloc({required this.dto}) : super(dto.initialIdea);

  final IdeaViewBlocDto dto;
  late final titleController =
      TextEditingController(text: dto.initialIdea.title)
        ..addListener(_onChanged);
  ProjectModelIdea get idea => value;
  void _onChanged() {
    final updatedNote = value.copyWith(
      title: titleController.text,
      updatedAt: DateTime.now(),
    );
    setValue(updatedNote);
    dto.openedProjectNotifier.updateProject(updatedNote);
  }

  Future<void> onRemove(final BuildContext context) async {
    final remove = await showRemoveTitleDialog(
      title: idea.title,
      context: context,
    );
    if (!remove) return;
    dto.openedProjectNotifier.deleteProject();
  }

  void onSubmit() {
    unawaited(SoftKeyboard.close());
  }

  @override
  void dispose() {
    titleController
      ..removeListener(_onChanged)
      ..dispose();

    super.dispose();
  }
}
