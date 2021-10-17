part of widgets;

class IconShareButton extends StatelessWidget {
  const IconShareButton({
    required final this.onTap,
    final Key? key,
  }) : super(key: key);
  final VoidCallback? onTap;
  @override
  Widget build(final BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: const Icon(Icons.share),
    );
  }
}
