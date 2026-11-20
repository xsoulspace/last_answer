import 'dart:async';
import 'dart:convert' show JsonDecoder, Utf8Decoder;
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:go_router/go_router.dart';
import 'package:la_ui_kit/la_ui_kit.dart';
import 'package:provider/provider.dart';
import 'package:shared_models/shared_models.dart';
import 'package:xsoulspace_foundation/xsoulspace_foundation.dart';
import 'package:xsoulspace_state_utils/xsoulspace_state_utils.dart';
import 'package:xsoulspace_ui_foundation/xsoulspace_ui_foundation.dart';
import 'global_states_initializer.dart';
import 'run_mutations.dart';


class LocalUserInitializer {
  LocalUserInitializer(final BuildContext context)
    : dto = GlobalStatesInitializerDto(context: context);
  final GlobalStatesInitializerDto dto;
  Future<void> onUserLoad() async {
    await runMutations(dto);

    /// not wait for this since every data has its own loader
    unawaited(_onLoadData());
  }

  Future<void> _onLoadData() async {
    dto.projectsNotifier.onReset();
    // unawaited(dto.purchasesAdsService.onLoad());

    /// refreshing data, just to make sure all is loaded correctly
    await Future.delayed(const Duration(seconds: 1));
    await dto.projectsNotifier.onLocalUserLoad();
    await dto.tagsNotifier.onLocalUserLoad();
    await dto.purchasesNotifier.onLocalUserLoad();
  }

  void onUserReset() {
    dto.projectsNotifier.onReset();
  }
}
