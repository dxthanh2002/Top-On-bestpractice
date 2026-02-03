import 'ad_state.dart';
import 'ad_type.dart';

class AdPlacement {
  final String placementId;
  final AdType type;
  final AdState state;
  final String? sceneId;

  const AdPlacement({
    required this.placementId,
    required this.type,
    this.state = AdState.idle,
    this.sceneId,
  });

  AdPlacement copyWith({
    String? placementId,
    AdType? type,
    AdState? state,
    String? sceneId,
  }) {
    return AdPlacement(
      placementId: placementId ?? this.placementId,
      type: type ?? this.type,
      state: state ?? this.state,
      sceneId: sceneId ?? this.sceneId,
    );
  }
}
