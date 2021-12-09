import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/pack_app/pack_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final notificationService = NotificationService();
  final notificationController = NotificationController(
    notificationService: notificationService,
  );
  final notificationMessage = NotificationMessage(
    id: '1',
    message: 'Hola!',
    created: DateTime.now(),
  );
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
  });
  test(
      'NotificationMessage.fromJson - '
      'it is okay to write date as human:)', () {
    const messageJson = {
      'id': '1',
      'message': 'Hola!',
      'created': '2021-12-10'
    };
    final result = NotificationMessage.fromJson(messageJson);
    final expectedMessage = NotificationMessage(
      created: DateTime(2021, 12, 10),
      id: '1',
      message: 'Hola!',
    );
    expect(result, equals(expectedMessage));
  });
  group('NotificationController', () {
    test('.determineUnreadUpdates - should be all unread', () async {
      notificationController.updates.add(notificationMessage);

      await notificationController.determineUnreadUpdates();

      expect(notificationController.hasUnreadUpdates, isTrue);
    });
    test('.determineUnreadUpdates - should be read', () async {
      await notificationController.readAllUpdates();
      await notificationController.determineUnreadUpdates();

      expect(notificationController.hasUnreadUpdates, isFalse);
    });
  });
}
