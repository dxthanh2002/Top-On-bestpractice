import 'ad_unit.dart';

enum TopOnAdEventType {
  loading,
  loaded,
  loadFailed,
  showed,
  showFailed,
  clicked,
  closed,
  rewardEarned,
  rewardFailed,
  deepLink,
  videoStarted,
  videoEnded,
}

class TopOnAdEvent {
  final TopOnAdUnit adUnit;
  final String placementId;
  final TopOnAdEventType type;
  final String? errorMessage;
  final Map<String, dynamic>? extra;
  final DateTime timestamp;

  TopOnAdEvent({
    required this.adUnit,
    required this.placementId,
    required this.type,
    this.errorMessage,
    this.extra,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isError => type == TopOnAdEventType.loadFailed || type == TopOnAdEventType.showFailed;
  bool get isReady => type == TopOnAdEventType.loaded;

  @override
  String toString() => 'TopOnAdEvent($adUnit, $type, $placementId)';
}
