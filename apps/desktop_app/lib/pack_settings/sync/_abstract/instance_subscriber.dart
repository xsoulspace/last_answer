import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lastanswer/api/api.dart';
import 'package:lastanswer/pack_core/pack_core.dart';
import 'package:lastanswer/pack_settings/sync/_abstract/instance_updater.dart';
import 'package:lastanswer/state/state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class InstanceSubscriberI<TImmutable extends HasId>
    extends ChangeNotifier {
  InstanceSubscriberI({
    required this.api,
  });
  final AbstractApi<TImmutable> api;
  final subscriptions = <RealtimeSubscription>[];

  void subscribe() {
    subscriptions
      ..add(api.subscribeToNew(_onNew))
      ..add(api.subscribeToUpdates(_onUpdate))
      ..add(api.subscribeToDeletes(_onDelete));
  }

  Future<void> _onNew(final TImmutable value);

  Future<void> _onUpdate(final TImmutable value);

  Future<void> _onDelete(final TImmutable value);

  void unsubscribe() {
    for (final subscription in subscriptions) {
      subscription.unsubscribe();
    }
  }

  @override
  void dispose() {
    unsubscribe();
    super.dispose();
  }
}

class SingleInstanceSubscriber<
        TMutable extends RemoteHiveObjectWithId<TImmutable>,
        TImmutable extends HasId,
        TMapState extends MapState<TMutable>>
    extends InstanceSubscriberI<TImmutable> {
  SingleInstanceSubscriber({
    required this.updater,
    required super.api,
  });
  final InstanceUpdater<TMutable, TImmutable, TMapState> updater;

  @override
  Future<void> _onNew(final TImmutable value) async {
    await updater.getAndUpdateByOther([value]);
  }

  @override
  Future<void> _onUpdate(final TImmutable value) async {
    await updater.getAndUpdateByOther([value]);
  }

  @override
  Future<void> _onDelete(final TImmutable value) async {
    await updater.getAndUpdateByOther([value]);
  }
}
