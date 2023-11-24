part of '../widgets.dart';

class ButtonPopup extends StatelessWidget {
  const ButtonPopup({
    this.children = const [],
    this.child,
    this.height = 320,
    this.hideBorder = false,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.min,
    this.mainAxisAlignment = MainAxisAlignment.start,
    super.key,
  }) : assert(
          children != const [] || child != null,
          'Please provide children or child',
        );
  final List<Widget> children;
  final Widget? child;
  final double height;
  final bool hideBorder;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  @override
  Widget build(final BuildContext context) => SizedBox(
        height: height,
        width: !PlatformInfo.isNativeDesktop && !kIsWeb
            ? MediaQuery.of(context).size.width - 50
            : 250,
        child: Stack(
          children: [
            if (child != null)
              child!
            else
              Column(
                mainAxisSize: mainAxisSize,
                crossAxisAlignment: crossAxisAlignment,
                mainAxisAlignment: mainAxisAlignment,
                children: children,
              ),
          ],
        ),
      );
}
