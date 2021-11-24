part of widgets;

class SafeAreaBottom extends StatelessWidget {
  const SafeAreaBottom({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context) {
    return const SafeArea(top: false, child: SizedBox(height: 1));
  }
}

class TopSafeArea extends StatelessWidget {
  const TopSafeArea({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context) {
    return const SafeArea(bottom: false, child: SizedBox(height: 1));
  }
}
