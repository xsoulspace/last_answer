import 'package:flutter/material.dart';
import 'package:lastanswer/screens/AppPages.dart';
import 'package:lastanswer/screens/MenuDrawer.dart';
import 'package:lastanswer/widgets/CustomAppBar.dart';

class ScaffoldApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var _appBar = CustomAppBar(
      appBarHeight: Size.fromHeight(0.0).height,
    );
    var _body = AppPages();
    return MenuDrawer(
        key: Key('MenuDrawer'),
        child: Scaffold(
          appBar: _appBar,
          body: _body,
        ));
  }
}
