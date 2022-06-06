library pack_auth;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:lastanswer/api/api.dart';
import 'package:lastanswer/library/hooks/hooks.dart';
import 'package:lastanswer/library/theme/theme.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_app/pack_app.dart';
import 'package:lastanswer/pack_core/pack_core.dart';
import 'package:lastanswer/pack_purchases/pack_purchases.dart';
import 'package:life_hooks/life_hooks.dart';
import 'package:provider/provider.dart' as provider_lib;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_hooks/supabase_hooks.dart';
import 'package:universal_io/io.dart';
import 'package:url_launcher/url_launcher.dart';

part '_hooks/auth_state.dart';
part '_notifiers/users_notifier.dart';
part '_screens/email_sign_in_screen.dart';
part '_screens/email_sign_in_screen_state.dart';
part '_screens/email_sign_up_screen.dart';
part '_screens/email_sign_up_screen_state.dart';
part '_screens/global_sign_in_screen.dart';
part '_screens/global_sign_in_screen_state.dart';
part '_screens/magic_link_sign_in_screen.dart';
part '_screens/magic_link_sign_in_screen_state.dart';
part '_utils/lifecycle_observer.dart';
