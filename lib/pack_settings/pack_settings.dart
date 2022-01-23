library pack_settings;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart' as intl;
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/generated/assets.gen.dart';
import 'package:lastanswer/generated/l10n.dart';
import 'package:lastanswer/library/hooks/hooks.dart';
import 'package:lastanswer/library/theme/theme.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_app/pack_app.dart';
import 'package:lastanswer/pack_note/pack_note.dart';
import 'package:lastanswer/utils/utils.dart';
import 'package:provider/provider.dart';

part 'abstract/general_settings_controller.dart';
part 'abstract/general_settings_service.dart';
part 'features_widgets/characters_limit.dart';
part 'features_widgets/characters_limit_state.dart';
part 'features_widgets/locale_switcher_button.dart';
part 'features_widgets/theme_switcher_button.dart';
part 'screens/general_settings.dart';
part 'screens/general_settings_screen.dart';
part 'screens/settings_screen.dart';
part 'screens/small_settings_screen.dart';
part 'widgets/settings_button.dart';
