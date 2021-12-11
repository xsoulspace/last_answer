library pack_idea;

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/generated/l10n.dart';
import 'package:lastanswer/library/hooks/hooks.dart';
import 'package:lastanswer/library/theme/theme.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/state/state.dart';
import 'package:lastanswer/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

part 'screens/create_idea_screen.dart';
part 'screens/idea_answer_screen.dart';
part 'screens/idea_screen.dart';
part 'state/idea_questions_initializer.dart';
part 'widgets/answer_creator.dart';
part 'widgets/answer_field.dart';
part 'widgets/answer_field_bubble.dart';
part 'widgets/answer_tile.dart';
part 'widgets/question_dropdown.dart';
part 'widgets/questions_chips.dart';