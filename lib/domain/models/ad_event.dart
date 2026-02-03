import 'ad_state.dart';
import 'ad_type.dart';

class AdEvent {
  final String placementId;
  final AdState state;
  final AdType type;
  final String? errorMessage;
  final Map<String, dynamic>? extra;

  const AdEvent({
    required this.placementId,
    required this.state,
    required this.type,
    this.errorMessage,
    this.extra,
  });

  AdEvent copyWith({
    String? placementId,
    AdState? state,
    AdType? type,
    String? errorMessage,
    Map<String, dynamic>? extra,
  }) {
    return AdEvent(
      placementId: placementId ?? this.placementId,
      state: state ?? this.state,
      type: type ?? this.type,
      errorMessage: errorMessage ?? this.errorMessage,
      extra: extra ?? this.extra,
    );
  }

  @override
  String toString() {
    return 'AdEvent(placementId: $placementId, state: $state, type: $type)';
  }
}
