part of pack_idea;

IdeaAnswerScreenState useIdeaAnswerScreenState({
  required final BuildContext context,
}) =>
    use(
      LifeHook(
        debugLabel: 'useIdeaAnswerScreenState',
        state: IdeaAnswerScreenState(
          context: context,
        ),
      ),
    );

class IdeaAnswerScreenState implements LifeState {
  IdeaAnswerScreenState({required final this.context});
  final BuildContext context;

  @override
  late ValueChanged<VoidCallback> setState;

  @override
  void dispose() {
    // TODO: implement dispose
  }

  @override
  void initState() {
    // TODO: implement initState
  }
}
