part of 'create_idea_screen.dart';

_CreateIdeaScreenState _useCreateIdeaScreenState() => use(
      ContextfulLifeHook(
        debugLabel: 'CreateIdeaScreenState',
        state: _CreateIdeaScreenState(),
      ),
    );

class _CreateIdeaScreenState extends ContextfulLifeState {
  _CreateIdeaScreenState();
  final _textFieldFocusNode = FocusNode();
  final textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((final _) {
      FocusScope.of(context).requestFocus(_textFieldFocusNode);
    });
  }

  @override
  void dispose() {
    textController.dispose();
    _textFieldFocusNode.dispose();
    super.dispose();
  }

  void onCreate() {
    context.read<AppRouterController>().onCreateIdea(
          title: textController.text,
          context: context,
        );
  }

  void onBack() {
    context.read<AppRouterController>().toHome();
  }
}
