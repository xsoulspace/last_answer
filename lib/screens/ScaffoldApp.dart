import 'package:flutter/material.dart';
import 'package:lastanswer/components/AppBarComponent.dart';
import 'package:lastanswer/screens/AppPages.dart';
import 'package:lastanswer/screens/MenuDrawer.dart';

class ScaffoldApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget _appBar = AppBarComponent();
    Widget _body = AppPages();
    return MenuDrawer(
        child: Scaffold(
      appBar: _appBar,
      body: _body,
    ));
  }
}
