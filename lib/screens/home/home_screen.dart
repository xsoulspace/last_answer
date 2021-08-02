part of home;

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    final Key? key,
  }) : super(key: key);
  @override
  Widget build(final BuildContext context) {
    // TODO(arenukvern): make the welcome dependant from platform day time
    const welcome = 'Good evening';
    return Scaffold(
      appBar: AppBar(
        title: const Text(welcome),
        actions: [
          IconButton(
            onPressed: () {
              // TODO(arenukvern): add push for info widget
              throw UnimplementedError();
            },
            icon: const Icon(Icons.info),
            key: const Key(HomeScreenKeys.iconButtonInfo),
          ),
          IconButton(
            onPressed: () {
              // TODO(arenukvern): add push for settings widget
              throw UnimplementedError();
            },
            icon: const Icon(Icons.settings),
            key: const Key(HomeScreenKeys.iconButtonSettings),
          ),
        ],
      ),
    );
  }
}
