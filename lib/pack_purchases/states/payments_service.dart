part of pack_purchases;

class PaymentsService {
  bool get paymentsAccessable =>
      Envs.revenueCatApiKeyIsNotEmpty &&
      (Platform.isIOS || Platform.isMacOS || Platform.isAndroid) &&
      !kIsWeb;
  bool get paymentsNotAccessable => !paymentsAccessable;
}
