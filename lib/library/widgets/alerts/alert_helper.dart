part of widgets;

class AlertHelper {
  AlertHelper._();
  static Future<void> onResponseError({
    required final GotrueError error,
  }) async {
    if (kIsWeb) {
      throw UnimplementedError('Response error alert. Error: ${error.message}');
    }
    await showNativeError(
      message: '${error.message}.\n\n'
          'Try again, or ask for help in discord channel.',
    );
  }

  static Future<void> showNativeError({
    required final String message,
  }) async {
    await FlutterPlatformAlert.playAlertSound(
      iconStyle: IconStyle.error,
    );
    await FlutterPlatformAlert.showAlert(
      windowTitle: 'Error',
      text: message,
      iconStyle: IconStyle.error,
    );
  }

  static Future<AlertButton> showYesNoWarning({
    required final String message,
    required final String title,
  }) async {
    await FlutterPlatformAlert.playAlertSound(
      iconStyle: IconStyle.warning,
    );

    return FlutterPlatformAlert.showAlert(
      windowTitle: title,
      text: message,
      alertStyle: AlertButtonStyle.yesNo,
      iconStyle: IconStyle.error,
    );
  }
}
