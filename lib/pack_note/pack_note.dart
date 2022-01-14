library pack_note;

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/generated/l10n.dart';
import 'package:lastanswer/library/hooks/hooks.dart';
import 'package:lastanswer/library/theme/theme.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_app/pack_app.dart';
import 'package:lastanswer/pack_settings/pack_settings.dart';
import 'package:lastanswer/state/state.dart';
import 'package:lastanswer/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:recase/recase.dart';
import 'package:rxdart/rxdart.dart';
import 'package:universal_io/io.dart';

part 'screens/note_project_screen.dart';
part 'screens/note_project_screen_state.dart';
part 'states/use_note_project_updater.dart';
part 'widgets/desktop_note_settings.dart';
part 'widgets/mobile_note_settings.dart';
part 'widgets/note_settings_button.dart';
