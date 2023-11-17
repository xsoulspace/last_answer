import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:blur/blur.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart' as intl;
import 'package:json_annotation/json_annotation.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_idea/pack_idea.dart';
import 'package:lastanswer/pack_note/note_screen.dart';
import 'package:lastanswer/pack_note/note_view.dart';
import 'package:lastanswer/pack_purchases/pack_purchases.dart';
import 'package:lastanswer/pack_settings/pack_settings.dart';
import 'package:lastanswer/utils/utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:recase/recase.dart';
import 'package:universal_io/io.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class LargeHomeScreen extends StatelessWidget {
  const LargeHomeScreen({
    required this.onProjectTap,
    required this.onSettingsTap,
    required this.onInfoTap,
    required this.onCreateIdeaTap,
    required this.onCreateNoteTap,
    required this.mainScreenNavigator,
    required this.onGoHome,
    required this.checkIsProjectActive,
    super.key,
  });
  final ValueChanged<BasicProject> onProjectTap;
  final BoolValueChanged<BasicProject> checkIsProjectActive;
  final VoidCallback onSettingsTap;
  final VoidCallback onInfoTap;
  final VoidCallback onCreateIdeaTap;
  final VoidCallback onCreateNoteTap;
  final Widget mainScreenNavigator;
  final VoidCallback onGoHome;

  @override
  Widget build(final BuildContext context) {
    final size = MediaQuery.of(context).size;
    final leftColumn = (size.width / 4).clamp(300, 400).toDouble();
    const centerRightBorder = 0.6;
    final rightColumn = ScreenLayout.of(context).large ? leftColumn : 0.0;
    final centerPart =
        size.width - leftColumn - rightColumn - centerRightBorder;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: leftColumn,
          child: SmallHomeScreen(
            verticalMenuAlignment: Alignment.bottomRight,
            onGoHome: onGoHome,
            checkIsProjectActive: checkIsProjectActive,
            onCreateIdeaTap: onCreateIdeaTap,
            onCreateNoteTap: onCreateNoteTap,
            onInfoTap: onInfoTap,
            onProjectTap: onProjectTap,
            onSettingsTap: onSettingsTap,
          ),
        ),
        Container(
          margin: EdgeInsets.zero,
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.cleanBlack
                    : AppColors.grey4,
                width: centerRightBorder,
              ),
            ),
            color: Theme.of(context).canvasColor,
          ),
          child: SizedBox(
            width: centerPart,
            child: mainScreenNavigator,
          ),
        ),
        if (rightColumn > 0)
          Container(
            color: isNativeDesktop
                ? Theme.of(context).canvasColor.withOpacity(0.9)
                : Theme.of(context).canvasColor,
            width: rightColumn,
          ),
      ],
    );
  }
}
