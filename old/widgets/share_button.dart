import 'package:flutter/material.dart';
import 'package:lastanswer/abstract/project.dart';
import 'package:lastanswer/utils/is_desktop.dart';
import 'package:lastanswer/utils/share_str_project.dart';

class ShareButton extends StatefulWidget {
  final Project project;
  const ShareButton({
    required this.project,
  });
  @override
  _ShareButtonState createState() => _ShareButtonState();
}

class _ShareButtonState extends State<ShareButton> {
  final defaultIcon =
      isDesktop ? const Icon(Icons.copy) : const Icon(Icons.share);
  final doneIcon = const Icon(Icons.done);
  late Icon currentIcon;
  @override
  void initState() {
    super.initState();
    setState(() {
      currentIcon = defaultIcon;
    });
  }

  Future setDone() async {
    setState(() {
      currentIcon = doneIcon;
    });
    await Future.delayed(const Duration(milliseconds: 1450), () {
      setState(() {
        currentIcon = defaultIcon;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 700),
        child: currentIcon,
      ),
      onPressed: () async {
        await copyOrShareProjectAnswers(
            context: context, project: widget.project);

        await setDone();
      },
    );
  }
}
