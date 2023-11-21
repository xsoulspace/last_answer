import 'package:lastanswer/_library/widgets/widgets.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/idea/idea_view_bloc.dart';
import 'package:lastanswer/pack_app/widgets/project_title_field.dart';

class IdeaView extends StatelessWidget {
  const IdeaView({
    required this.idea,
    super.key,
  });
  final ProjectModelIdea idea;

  @override
  Widget build(final BuildContext context) => ChangeNotifierProvider(
        create: (final _) => IdeaViewBloc(
          dto: IdeaViewBlocDto(
            initialIdea: idea,
            context: context,
          ),
        ),
        builder: (final context, final child) => const IdeaViewBody(),
      );
}

class IdeaViewBody extends StatelessWidget {
  const IdeaViewBody({super.key});
  @override
  Widget build(final BuildContext context) {
    final bloc = context.read<IdeaViewBloc>();
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: BackTextUniversalAppBar(
            useBackButton: true,
            screenLayout: ScreenLayout.of(context),
            title: ProjectTitleField(
              // onFocus: state.closeQuestions,
              controller: bloc.titleController,
              heroId: bloc.dto.initialIdea.id.value,
              onChanged: (final _) {},
            ),
            onBack: context.pop,
          ),
        ),
      ],
    );
  }
}
