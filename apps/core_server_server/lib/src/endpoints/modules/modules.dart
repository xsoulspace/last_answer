import 'dart:io';

import 'package:core_server_server/src/endpoints/repositories/purchases/purchases.dart';
import 'package:googleapis/androidpublisher/v3.dart' as ap;
import 'package:googleapis/pubsub/v1.dart' as pubsub;
import 'package:googleapis_auth/auth_io.dart' as auth;

class ModulesDiDto {
  ModulesDiDto({
    required this.googlePlayClient,
  });
  final GooglePlayClient googlePlayClient;
}

class GooglePlayClient {
  GooglePlayClient({
    required this.androidPublisher,
    required this.pubsubApi,
  });
  final ap.AndroidPublisherApi androidPublisher;
  final pubsub.PubsubApi pubsubApi;

  static Future<GooglePlayClient> load() async {
    // Configure Android Publisher API access
    final serviceAccountGooglePlay =
        File('assets/service-account-google-play.json').readAsStringSync();
    final clientCredentialsGooglePlay =
        auth.ServiceAccountCredentials.fromJson(serviceAccountGooglePlay);
    final clientGooglePlay =
        await auth.clientViaServiceAccount(clientCredentialsGooglePlay, [
      ap.AndroidPublisherApi.androidpublisherScope,
      pubsub.PubsubApi.cloudPlatformScope,
    ]);
    final androidPublisher = ap.AndroidPublisherApi(clientGooglePlay);

    // Pub/Sub API to receive on purchase events from Google Play
    final pubsubApi = pubsub.PubsubApi(clientGooglePlay);

    return GooglePlayClient(
      androidPublisher: androidPublisher,
      pubsubApi: pubsubApi,
    );
  }
}

/// Creates the Google Play and Apple Store [PurchaseHandler]
/// and their dependencies
Future<ModulesDiDto> _createPurchaseHandlers() async {
  final iapPurchasesRepository = IapPurchasesRepository();
  final googlePlayClient = await GooglePlayClient.load();
  return ModulesDiDto(googlePlayClient: googlePlayClient);
}
