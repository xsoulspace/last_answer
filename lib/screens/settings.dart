import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:last_answer/abstract/HiveBoxes.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

const double AppBarHeight = 48;

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    var box = Hive.box<bool>(HiveBoxes.darkMode);
    var isDark = box.get(BoxDarkMode.isDark, defaultValue: false) ?? false;
    var size = MediaQuery.of(context).size;
    return Material(
        child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'appBarMenuButton',
              child: Material(
                shape: CircleBorder(),
                color: Colors.transparent,
                child: SizedBox(
                  height: AppBarHeight,
                  width: 56,
                  child: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            )
          ],
        ),
        SafeArea(
            child: Stack(
          children: [
            Hero(
                tag: 'appBarBackground',
                child: Material(
                  child: Container(
                    height: size.height - AppBarHeight,
                    color: Theme.of(context).canvasColor,
                    child: GridView.count(
                      crossAxisCount: 3,
                      childAspectRatio: 1,
                      padding: EdgeInsets.all(20.0),
                      children: [
                        Center(
                          child: Column(children: [
                            Container(
                              height: 60,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Theme.of(context).accentColor,
                                    width: 1),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                onPressed: () async {
                                  await box.put(BoxDarkMode.isDark, !isDark);
                                },
                                icon: AnimatedSwitcher(
                                  duration: Duration(milliseconds: 400),
                                  child: isDark
                                      ? Icon(Icons.wb_sunny_outlined)
                                      : Icon(Icons.wb_sunny),
                                ),
                              ),
                            ),
                            Text(
                              'Dark mode',
                              textAlign: TextAlign.center,
                            ),
                          ]),
                        )
                      ],
                    ),
                  ),
                ))
          ],
        )),
      ],
    ));
  }
}
