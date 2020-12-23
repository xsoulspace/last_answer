import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lastanswer/screens/MenuDrawer.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  CustomAppBar({required double appBarHeight})
      : preferredSize = Size.fromHeight(kToolbarHeight + appBarHeight);

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  final Size preferredSize;
}

class _CustomAppBarState extends State<CustomAppBar>
    with TickerProviderStateMixin {
  @override
  initState() {
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      leading: Builder(
        builder: (context) => IconButton(
          onPressed: () {
            MenuDrawer.of(context)?.open();
          },
          icon: Icon(Icons.playlist_add_check),
        ),
      ),
      title: Text(''),
      elevation: 4,
      centerTitle: true,
      actions: [],
    );
  }
}
