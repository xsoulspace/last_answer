// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:core_server_server/envs.dart';
import 'package:core_server_server/src/endpoints/repositories/purchases/iap_purchase_repository.dart';
import 'package:core_server_server/src/endpoints/repositories/purchases/purchase_handler.dart';
import 'package:googleapis/androidpublisher/v3.dart' as ap;
import 'package:googleapis/pubsub/v1.dart' as pubsub;
import 'package:serverpod/serverpod.dart';
import 'package:shared_models/shared_models.dart';

final class GooglePlayPurchaseHandler extends PurchaseHandler {
  GooglePlayPurchaseHandler(
    this.androidPublisher,
    this.iapRepository,
    this.pubsubApi,
  ) {
    // Poll messages from Pub/Sub every 10 seconds
    Timer.periodic(
      const Duration(seconds: 10),
      (final _) async => _pullMessageFromPubSub(),
    );
  }
  final ap.AndroidPublisherApi androidPublisher;
  final IapPurchasesRepository iapRepository;
  final pubsub.PubsubApi pubsubApi;

  /// Handle non-subscription purchases (one time purchases).
  ///
  /// Retrieves the purchase status from Google Play and updates
  /// the Firestore Database accordingly.

  @override
  Future<bool> handleOneTime({
    required final Session session,
    required final UserModelId userId,
    required final PurchaseRequestDtoModel dto,
    required final String token,
  }) async {
    print(
      'GooglePlayPurchaseHandler.handleNonSubscription'
      '($userId, ${dto.productId}, ${token.substring(0, 5)}...)',
    );

    try {
      // Verify purchase with Google
      final response = await androidPublisher.purchases.products.get(
        Envs.androidPackageId,
        dto.productId.value,
        token,
      );

      print('Purchases response: ${response.toJson()}');

      // Make sure an order id exists
      if (response.orderId == null) {
        print('Could not handle purchase without order id');
        return false;
      }
      final orderId = response.orderId!;

      final purchase = PurchaseModel.oneTime(
        purchasedAt: DateTime.fromMillisecondsSinceEpoch(
          int.parse(response.purchaseTimeMillis ?? '0'),
        ),
        originalTransactionID: orderId,
        productId: dto.productId,
        status: _nonSubscriptionStatusFrom(response.purchaseState),
        userId: userId,
      );

      // Update the database
      // If we know the userId,
      // update the existing purchase or create it if it does not exist.
      await iapRepository.createOrUpdatePurchase(
        session: session,
        purchase: purchase,
      );
      return true;
    } on ap.DetailedApiRequestError catch (e) {
      print(
        'Error on handle NonSubscription: $e\n'
        'JSON: ${e.jsonResponse}',
      );
    } catch (e) {
      print('Error on handle NonSubscription: $e\n');
    }
    return false;
  }

  /// Handle subscription purchases.
  ///
  /// Retrieves the purchase status from Google Play and updates
  /// the Firestore Database accordingly.
  @override
  Future<bool> handleSubscription({
    required final Session session,
    required final UserModelId userId,
    required final PurchaseRequestDtoModel dto,
    required final String token,
  }) async {
    print(
      'GooglePlayPurchaseHandler.handleSubscription'
      '($userId, ${dto.productId}, ${token.substring(0, 5)}...)',
    );

    try {
      // Verify purchase with Google
      final response = await androidPublisher.purchases.subscriptions.get(
        Envs.androidPackageId,
        dto.productId.value,
        token,
      );

      print('Subscription response: ${response.toJson()}');

      // Make sure an order id exists
      if (response.orderId == null) {
        print('Could not handle purchase without order id');
        return false;
      }
      final orderId = extractOrderId(response.orderId!);

      final purchaseData = PurchaseModel.subscription(
        purchasedAt: DateTime.fromMillisecondsSinceEpoch(
          int.parse(response.startTimeMillis ?? '0'),
        ),
        originalTransactionID: orderId,
        productId: dto.productId,
        status: _subscriptionStatusFrom(response.paymentState),
        userId: userId,
        willExpireAt: DateTime.fromMillisecondsSinceEpoch(
          int.parse(response.expiryTimeMillis ?? '0'),
        ),
      );

      // Update the database
      // If we know the userId,
      // update the existing purchase or create it if it does not exist.
      await iapRepository.createOrUpdatePurchase(
        session: session,
        purchase: purchaseData,
      );
      return true;
    } on ap.DetailedApiRequestError catch (e) {
      print(
        'Error on handle Subscription: $e\n'
        'JSON: ${e.jsonResponse}',
      );
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      print('Error on handle Subscription: $e\n');
    }
    return false;
  }

  /// Process messages from Google Play
  /// Called every 10 seconds
  Future<void> _pullMessageFromPubSub() async {
    print('Polling Google Play messages');
    final request = pubsub.PullRequest(
      maxMessages: 1000,
    );
    const topicName =
        'projects/${Envs.googlePlayProjectName}/subscriptions/${Envs.googlePlayPubsubBillingTopic}-sub';
    final pullResponse = await pubsubApi.projects.subscriptions.pull(
      request,
      topicName,
    );
    final messages = pullResponse.receivedMessages ?? [];
    for (final message in messages) {
      final data64 = message.message?.data;
      if (data64 != null) {
        await _processMessage(data64, message.ackId);
      }
    }
  }

  Future<void> _processMessage(final String data64, final String? ackId) async {
    final dataRaw = utf8.decode(base64Decode(data64));
    print('Received data: $dataRaw');
    final data = jsonDecode(dataRaw) as Map<String, dynamic>;
    if (data['testNotification'] != null) {
      print('Skip test messages');
      if (ackId != null) {
        await _ackMessage(ackId);
      }
      return;
    }
    final subscriptionNotification =
        data['subscriptionNotification'] as Map<String, dynamic>;
    final oneTimeProductNotification =
        data['oneTimeProductNotification'] as Map<String, dynamic>;
    print('Processing Subscription');
    final subscriptionId = subscriptionNotification['subscriptionId'] as String;
    final purchaseToken = subscriptionNotification['purchaseToken'] as String;
    final iapId = IAPId.values.firstWhere((final e) => e.id == subscriptionId);
    final result = await handleSubscription(
      session: session,
      userId: UserModelId.empty,
      dto: PurchaseRequestDtoModel(
        productId: iapId,
        provider: PurchasePaymentProvider.googlePlay,
        type: ProductType.subscription,
      ),
      token: purchaseToken,
    );
    if (result && ackId != null) {
      await _ackMessage(ackId);
    }
  }

  /// ACK Messages from Pub/Sub
  Future<void> _ackMessage(final String id) async {
    print('ACK Message');
    final request = pubsub.AcknowledgeRequest(
      ackIds: [id],
    );
    const subscriptionName =
        'projects/${Envs.googlePlayProjectName}/subscriptions/${Envs.googlePlayPubsubBillingTopic}-sub';
    await pubsubApi.projects.subscriptions.acknowledge(
      request,
      subscriptionName,
    );
  }
}

OneTimePurchaseStatus _nonSubscriptionStatusFrom(final int? state) =>
    switch (state) {
      0 => OneTimePurchaseStatus.completed,
      2 => OneTimePurchaseStatus.pending,
      _ => OneTimePurchaseStatus.cancelled,
    };

SubscriptionStatus _subscriptionStatusFrom(final int? state) => switch (state) {
      // Payment pending
      0 => SubscriptionStatus.pending,
      // Payment received
      1 => SubscriptionStatus.active,
      // Free trial
      2 => SubscriptionStatus.active,
      // Pending deferred upgrade/downgrade
      3 => SubscriptionStatus.pending,
      // Expired or cancelled
      _ => SubscriptionStatus.expired,
    };

/// If a subscription suffix is present (..#) extract the orderId.
String extractOrderId(final String orderId) {
  final orderIdSplit = orderId.split('..');
  if (orderIdSplit.isNotEmpty) {
    return orderIdSplit.first;
  }
  return orderId;
}
