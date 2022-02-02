part of widgets;

class BottomSafeArea extends StatelessWidget {
  const BottomSafeArea({final Key? key}) : super(key: key);
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
