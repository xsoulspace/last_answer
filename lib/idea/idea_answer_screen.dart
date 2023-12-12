import 'package:lastanswer/_library/widgets/widgets.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/home/home.dart';
import 'package:lastanswer/idea/idea_answer_screen_bloc.dart';
import 'package:lastanswer/idea/widgets/question_dropdown.dart';

class IdeaAnswerScreen extends StatelessWidget {
  const IdeaAnswerScreen._({required this.answer});
  static Future<IdeaProjectAnswerModel?> open({
    required final BuildContext context,
    required final IdeaProjectAnswerModel answer,
    required final ProjectModelIdea idea,
    required final int index,
  }) =>
      Navigator.push<IdeaProjectAnswerModel>(
        context,
        MaterialPageRoute(
          builder: (final context) => ChangeNotifierProvider(
            create: (final _) => IdeaAnswerScreenBloc(
              dto: IdeaAnswerScreenStateDto(
                context: context,
                answer: answer,
                idea: idea,
                index: index,
              ),
            ),
            builder: (final context, final child) => PopScope(
              canPop: false,
              child: IdeaAnswerScreen._(answer: answer),
            ),
          ),
        ),
      );
  final IdeaProjectAnswerModel answer;
  @override
  Widget build(final BuildContext context) => const IdeaAnswerBody();
}

class IdeaAnswerBody extends HookWidget {
  const IdeaAnswerBody({super.key});

  @override
  Widget build(final BuildContext context) {
    final bloc = context.watch<IdeaAnswerScreenBloc>();

    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      appBar: BackTextUniversalAppBar(
        useBackButton: true,
        title: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 252),
          child: HeroId(
            id: '${bloc.value.id}-question',
            type: HeroIdTypes.projectIdeaQuestionTitle,
            child: QuestionDropdown(
              answer: bloc.value,
              onChanged: bloc.setValue,
              alignment: Alignment.center,
            ),
          ),
        ),
        onBack: () => bloc.onBack(context),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          constraints: const BoxConstraints(
            maxWidth: ScreenLayout.minFullscreenPageWidth,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: HeroId(
                  id: bloc.value.id.value,
                  type: HeroIdTypes.projectIdeaAnswerText,
                  child: ProjectTextField(
                    value: bloc.value.text,
                    onChanged: bloc.onTextUpdate,
                    hintText: context.l10n.answer,
                    filled: false,
                    endlessLines: true,
                    focusOnInit: bloc.value.text.isEmpty,
                    onSubmit: () => bloc.onBack(context),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const BottomSafeArea(),
            ],
          ),
        ),
      ),
    );
  }
}
