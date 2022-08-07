import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:path_to_regexp/path_to_regexp.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';

part 'delegate.dart';
part 'models/parsed_route.dart';
part 'parser.dart';
part 'route_state.dart';
part 'router.freezed.dart';
part 'router.g.dart';

/// Original example
/// https://github.com/flutter/samples/tree/main/navigation_and_routing
part 'router_layout_builder.dart';
part 'router_page_builder.dart';
part 'widgets/navigator_page.dart';
part 'widgets/pop_scope.dart';
