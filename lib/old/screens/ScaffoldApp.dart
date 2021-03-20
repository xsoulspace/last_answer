import 'package:flutter/material.dart';
import 'package:lastanswer/screens/AskScreen.dart';
import 'package:lastanswer/screens/MenuDrawer.dart';
import 'package:lastanswer/widgets/CustomAppBar.dart';

class ScaffoldApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var _appBar = CustomAppBar(
      appBarHeight: 65,
    );
    return MenuDrawer(
        key: Key('MenuDrawer'),
        child: Material(
          child: Stack(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                    minHeight: double.infinity, minWidth: double.infinity),
                child: AskScreen(),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                    minHeight: 65, maxHeight: 65, minWidth: double.infinity),
                child: _appBar,
              ),
            ],
          ),
        ));
  }
}
