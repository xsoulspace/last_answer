part of home;

const _leftPadding = 2.0;
const _leftColumnWidth = 42.0;
const _rightColumnX = 42.0;

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    final Key? key,
  }) : super(key: key);
  @override
  Widget build(final BuildContext context) {
    // TODO(arenukvern): make the welcome dependant from platform day time
    const welcome = 'Good evening';
    final widgetSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text(welcome),
        elevation: 0,
        backgroundColor: Colors.transparent,
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
      body: Stack(
        children: [
          Positioned.fromRect(
            rect: Rect.fromPoints(
              const Offset(_leftPadding, 0),
              Offset(
                _leftColumnWidth + _leftPadding,
                widgetSize.height,
              ),
            ),
            child: const VerticalProjectBar(),
          ),
          Positioned.fromRect(
            rect: Rect.fromPoints(
              const Offset(_rightColumnX, 0),
              Offset(
                widgetSize.width,
                widgetSize.height,
              ),
            ),
            child: ListView.separated(
              // TODO(arenukvern): add project tile
              itemBuilder: (_, __) => Container(),
              separatorBuilder: (_, __) => const SizedBox(height: 3),
              // TODO(arenukvern): get projects count
              itemCount: 1,
              key: const Key(HomeScreenKeys.projectsList),
            ),
          ),
        ],
      ),
    );
  }
}

class VerticalProjectBar extends StatelessWidget {
  const VerticalProjectBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        // TODO(arenukvern): add gradient
        decoration: BoxDecoration(),
        child: Column(
          children: [
            SvgIconButton(
              onPressed: () {
                // TODO(arenukvern): add push for settings widget
                throw UnimplementedError();
              },
              svg: Assets.icons.idea.svg(),
              key: const Key(HomeScreenKeys.iconButtonIdea),
            ),
            IconButton(
              onPressed: () {
                // TODO(arenukvern): add push for settings widget
                throw UnimplementedError();
              },
              icon: const Icon(Icons.book),
              key: const Key(HomeScreenKeys.iconButtonNote),
            ),
          ],
        ),
      );
}
