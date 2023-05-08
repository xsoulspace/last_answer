import 'dart:async';
import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lastanswer/generated/assets.gen.dart';
import 'package:lastanswer/pack_app/notifications/notification_message.dart';
import 'package:lastanswer/utils/utils.dart';

class NotificationService with SharedPreferencesUtil {
  Future<DateTime?> get notificationUpdatesReadDateTime async {
    final datetimeStr = await getString(
      SharedPreferencesKeys.notificationUpdatesReadDateTime.name,
    );
    final miliseconds = int.tryParse(datetimeStr);
    if (miliseconds == null) return null;

    return DateTime.fromMillisecondsSinceEpoch(miliseconds);
  }

  Future<void> readUpdates() async {
    await setString(
      SharedPreferencesKeys.notificationUpdatesReadDateTime.name,
      dateTimeNowUtc().millisecondsSinceEpoch.toString(),
    );
  }

  Future<List<NotificationMessage>> getUpdatesNotifications({
    required final BuildContext context,
  }) async {
    final jsonStr = await DefaultAssetBundle.of(context)
        .loadString(Assets.json.updatesNotifications);
    if (jsonStr.isEmpty) return [];
    final jsonList =
        List.castFrom<dynamic, Map<String, dynamic>>(jsonDecode(jsonStr));

    return jsonList.map(NotificationMessage.fromJson).toList();
  }
}
