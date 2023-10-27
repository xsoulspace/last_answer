part of '../widgets.dart';

class HovarableListTile extends StatelessWidget {
  const HovarableListTile({
    required this.onTap,
    this.titleBuilder,
    this.leadingBuilder,
    super.key,
  });
  final HoverableWidgetBuilder? leadingBuilder;
  final HoverableWidgetBuilder? titleBuilder;
  final VoidCallback onTap;
  @override
  Widget build(final BuildContext context) => HoverableArea(
        builder: (final context, final hovered) => ListTile(
          onTap: onTap,
          leading: leadingBuilder?.call(context, hovered),
          title: titleBuilder?.call(context, hovered),
        ),
      );
}
