library utils;

import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/gen/assets.gen.dart';
import 'package:lastanswer/library/theme/theme.dart';
import 'package:path_to_regexp/path_to_regexp.dart';
import 'package:quiver/core.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_io/io.dart';
import 'package:uuid/uuid.dart';

part 'abstract_util.dart';
part 'close_keyboard.dart';
part 'color_extension.dart';
part 'emoji_util.dart';
part 'enum.dart';
part 'is_desktop.dart';
part 'iterable.dart';
part 'project_sharer.dart';
part 'routing/delegate.dart';
part 'routing/parsed_route.dart';
part 'routing/parser.dart';
part 'routing/route_state.dart';
part 'shared_preferences_keys.dart';
part 'shared_preferences_util.dart';
part 'theme_definder.dart';
part 'uuid.dart';
