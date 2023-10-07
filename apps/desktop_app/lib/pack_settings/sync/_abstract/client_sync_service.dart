import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lastanswer/pack_core/pack_core.dart';
import 'package:lastanswer/pack_settings/sync/_abstract/instances_sync_service.dart';
import 'package:lastanswer/pack_settings/sync/_models/model_updater_diff.dart';
import 'package:lastanswer/state/state.dart';
import 'package:provider/provider.dart';

class ClientInstancesSyncServiceI<
        T extends RemoteHiveObjectWithId<TOther>,
        TOther extends HasId,
        TNotifier extends MapState<T>> extends InstancesSyncServiceI<T, TOther>
    with InstancesSyncServiceApplier<T, TOther> {
  Future<Iterable<T>> getAll() async => throw UnimplementedError();
}

class HiveClientSyncServiceImpl<T extends RemoteHiveObjectWithId<TOther>,
        TOther extends HasId, TNotifier extends MapState<T>>
    extends ClientInstancesSyncServiceI<T, TOther, TNotifier> {
  HiveClientSyncServiceImpl({
    required this.context,
  });
  final BuildContext context;

  @override
  Future<Iterable<T>> getAll() async => context.read<TNotifier>().values;

  @override
  Future<void> onUpdate(
    final Iterable<T> elements,
  ) async {
    await Future.wait(
      elements.map(
        (final el) => el.save(),
      ),
    );
  }

  @override
  Future<void> onDelete(
    final Iterable<T> elements,
  ) async {
    await Future.wait(
      elements.map(
        (final el) => el.deleteWithRelatives(context: context),
      ),
    );
  }

  @override
  Future<void> applyUpdaterDto({
    required final InstanceUpdaterDto<T, TOther> dto,
  }) async {
    await onCreateFromOther(dto.originalUpdates.toCreateFromOther);
    await onUpdate(dto.originalUpdates.toUpdate);
    await onDelete(dto.originalUpdates.toDelete);
  }
}
