import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:last_answer/abstract/Project.dart';
import 'package:last_answer/utils/share_str_project.dart';
import 'package:universal_io/io.dart';

class ShareButton extends StatefulWidget {
  final Project project;
  ShareButton({required this.project});
  @override
  _ShareButtonState createState() => _ShareButtonState();
}

class _ShareButtonState extends State<ShareButton> {
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
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(right: 16),
        child: IconButton(
            icon: AnimatedSwitcher(
              duration: Duration(milliseconds: 700),
              child: currentIcon,
            ),
            onPressed: () async {
              await copyOrShareProjectAnswers(
                  context: context, project: widget.project);

              await setDone();
            }));
  }
}
