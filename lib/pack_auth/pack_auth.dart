library pack_auth;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lastanswer/library/extensions/extensions.dart';
import 'package:life_hooks/life_hooks.dart';
import 'package:provider/provider.dart' as provider_lib;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_hooks/supabase_hooks.dart';
import 'package:uni_links/uni_links.dart';
import 'package:universal_io/io.dart';
import 'package:url_launcher/url_launcher.dart';

part '_hooks/auth_state.dart';
part '_screens/sign_in_screen.dart';
part '_screens/sign_in_screen_state.dart';
part '_screens/sign_up_screen.dart';
part '_screens/sign_up_screen_state.dart';
part '_utils/lifecycle_observer.dart';
