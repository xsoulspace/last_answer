// import 'dart:async';

// import 'package:flutter/widgets.dart';
// import 'package:lastanswer/screens/MenuScreen.dart';
// import 'package:lastanswer/widgets/CircularProgress.dart';

// class MenuDrawer extends StatefulWidget {
//   final Widget child;
//   const MenuDrawer({required Key key, required this.child}) : super(key: key);

//   static MenuDrawerState? of(BuildContext context) =>
//       context.findAncestorStateOfType<MenuDrawerState>();

//   @override
//   MenuDrawerState createState() => MenuDrawerState();
// }

// class MenuDrawerState extends State<MenuDrawer> with TickerProviderStateMixin {
//   static const Duration toogleDuration = Duration(milliseconds: 300);
//   late AnimationController _controller;
//   late AnimationController _opacityController;
//   late Animation<double> _opacity;

//   @override
//   void initState() {
//     _controller = AnimationController(
//         vsync: this, duration: MenuDrawerState.toogleDuration);

//     _opacityController =
//         AnimationController(vsync: this, duration: Duration(milliseconds: 280));
//     _opacity = CurveTween(curve: Curves.easeInOut).animate(_opacityController);

//     super.initState();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     _opacityController.dispose();
//     super.dispose();
//   }

//   void close() {
//     setState(() {
//       _isMenuScreenActive = false;
//     });
//     _opacityController.reverse();
//     _controller.reverse();
//   }

//   bool _isMenuScreenActive = false;
//   void open() {
//     setState(() {
//       _isMenuScreenActive = true;
//     });
//     _controller.forward();
//     Timer(Duration(milliseconds: 60), () => _opacityController.forward());

//     // _controller.addStatusListener((status) {
//     //   if (status == AnimationStatus.completed) {
//     //   }
//     // });
//   }

//   void toggleDrawer() => _controller.isCompleted ? close() : open();
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final ySliding = ((size.height / 10) * _controller.value);

//     return WillPopScope(
//         onWillPop: () async {
//           if (_controller.isCompleted) {
//             close();
//             return false;
//           }
//           return true;
//         },
//         child: AnimatedBuilder(
//           animation: _controller,
//           child: widget.child,
//           builder: (context, child) {
//             // print({
//             //   'ySliding': ySliding,
//             //   'height': size.height,
//             //   'conv': _controller.value,
//             //   '_opacity': _opacity.value
//             // });
//             if (child == null) {
//               print('MenuDrawer AnimatedBuilder child == null!');
//               return Container();
//             }
//             return Stack(
//               children: [
//                 child,
//                 CircularProgress(
//                   controller: _controller,
//                   key: Key('MenuDrawer-AnimatedBuilder-CircularReveal'),
//                 ),
//                 _isMenuScreenActive
//                     ? ModalBarrier(
//                         dismissible: false,
//                       )
//                     : Container(),
//                 _isMenuScreenActive
//                     ? Transform(
//                         transform: Matrix4.identity()..translate(0.0, ySliding),
//                         alignment: Alignment.center,
//                         child: FadeTransition(
//                           opacity: _opacity,
//                           child: Stack(children: [
//                             Positioned.fill(
//                                 // child: _controller.isCompleted
//                                 //     ?
//                                 //     : Container(),
//                                 child: MenuScreen())
//                           ]),
//                         ))
//                     : Container()
//               ],
//             );
//           },
//         ));
//   }
// }
