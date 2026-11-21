// ignore_for_file: invalid_annotation_target

part of 'models.dart';

/// The ad-video length the client reports for a reward
/// (`receiveAdVideoReward`); the server maps it to reward days.
enum AdVideoLengthType { s, m, l }

/// The kind of purchase action recorded server-side.
enum PurchaseType { videoAward, subscription, oneTimePurchase }
