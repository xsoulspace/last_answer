import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lastanswer/models/AnswersModel.dart';
import 'package:lastanswer/models/LocaleModel.dart';
import 'package:lastanswer/screens/MenuDrawer.dart';
import 'package:lastanswer/screens/MenuScreen.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  CustomAppBar({required double appBarHeight})
      : preferredSize = Size.fromHeight(kToolbarHeight + appBarHeight);

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  final Size preferredSize;
}

class _CustomAppBarState extends State<CustomAppBar> {
  final defaultIcon =
      kIsWeb || Platform.isLinux || Platform.isWindows || Platform.isMacOS
          ? Icon(Icons.copy)
          : Icon(Icons.share);
  final doneIcon = Icon(Icons.done);
  late Icon currentIcon;
  @override
  initState() {
    super.initState();
    setState(() {
      currentIcon = defaultIcon;
    });
  }

  Future setDone() async {
    setState(() {
      currentIcon = doneIcon;
    });
    await Future.delayed(Duration(milliseconds: 1450), () {
      setState(() {
        currentIcon = defaultIcon;
      });
    });
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var localeModel = Provider.of<LocaleModel>(context);
    var answersModel = Provider.of<AnswersModel>(context);

    return AppBar(
      shape: CustomShapeBorder(),
      shadowColor: Theme.of(context).shadowColor,
      backgroundColor: Theme.of(context).accentColor,
      leading: Container(
          margin: EdgeInsets.only(left: 15),
          child: Builder(
            builder: (context) => IconButton(
              onPressed: () {
                MenuDrawer.of(context)?.open();
              },
              icon: Icon(Icons.menu),
            ),
          )),
      elevation: 4,
      actions: [
        Container(
            margin: EdgeInsets.only(right: 16),
            child: IconButton(
                icon: AnimatedSwitcher(
                  duration: Duration(milliseconds: 700),
                  child: currentIcon,
                ),
                onPressed: () async {
                  if (kIsWeb ||
                      Platform.isLinux ||
                      Platform.isWindows ||
                      Platform.isMacOS) {
                    var str = getAnswersAsString(
                        localeModel: localeModel,
                        answersList: answersModel.answersList);
                    var data = ClipboardData(text: str);
                    Clipboard.setData(data);
                  } else {
                    await share(context: context);
                  }

                  await setDone();
                }))
      ],
    );
  }
}

class CustomShapeBorder extends ContinuousRectangleBorder {
  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path path = Path();
    path.lineTo(0, rect.height - 20);
    path.cubicTo(35, rect.height + 10, 90, 20, 180, 20);
    path.cubicTo(rect.width / 2, rect.height / 3, rect.width / 1.3,
        rect.height / 1.1, rect.width - 40, rect.height);
    path.lineTo(rect.width, rect.height);
    path.lineTo(rect.width, 0.0);
    path.close();

    return path;
  }
}
