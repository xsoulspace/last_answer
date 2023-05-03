import 'dart:async';

import 'package:lastanswer/pack_core/pack_core.dart';
import 'package:lastanswer/pack_settings/sync/_models/model_updater_diff.dart';

abstract mixin class InstancesSyncServiceApplier<T extends HasId,
    TOther extends HasId> {
  Future<void> applyUpdaterDto({
    required final InstanceUpdaterDto<T, TOther> dto,
  }) async {
    assert(
      true,
      'You are running applyUpdaterDto with abstract implementation. '
      'If it is not on purpose, please override this method.',
    );
  }
}

class InstancesSyncServiceI<T extends HasId, TOther extends HasId> {
  Future<void> onCreateFromOther(final Iterable<TOther> elements) async {}
  Future<void> onUpdate(final Iterable<T> elements) async {}
  Future<void> onDelete(final Iterable<T> elements) async {}
}
