import 'dart:async';

import 'package:lastanswer/pack_core/pack_core.dart';
import 'package:lastanswer/pack_settings/sync/_models/model_updater_diff.dart';

// ignore: one_member_abstracts
abstract class RemotelyUpdatable<
    TMutable extends RemoteHiveObjectWithId<TImmutableOther>,
    TImmutableOther extends HasId> {
  Future<void> saveChanges({
    required final InstanceUpdaterDto<TMutable, TImmutableOther> dto,
  });
}
