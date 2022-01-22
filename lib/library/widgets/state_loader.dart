part of widgets;

abstract class StateInitializer extends Loadable {}

class StateLoader extends HookWidget {
  const StateLoader({
    required final this.child,
    required final this.initializer,
    required final this.loader,
    final Key? key,
  }) : super(key: key);
  final Widget child;
  final StateInitializer initializer;
  final Widget loader;
  static const _transitionDurationInMiliseconds = 350;
  @override
  Widget build(final BuildContext context) {
    final loaded = useIsBool();
    final loading = useIsBool();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: _transitionDurationInMiliseconds),
      transitionBuilder: (final child, final animation) {
        const begin = 0.99;
        const end = 1.0;
        const curve = Curves.easeInOutBack;

        final tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return ScaleTransition(
          scale: animation.drive(tween),
          child: child,
        );
      },
      child: loaded.value & !loading.value
          ? child
          : FutureBuilder<bool>(
              future: () async {
                if (loading.value) return false;
                loading.value = true;
                loaded.value = true;
                await initializer.onLoad(context: context);
                loading.value = false;

                return true;
              }(),
              builder: (final context, final snapshot) {
                if (snapshot.connectionState != ConnectionState.done ||
                    snapshot.data == false) {
                  return loader;
                }

                return child;
              },
            ),
    );
  }
}
