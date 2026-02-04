class TopOnShowResult {
  final bool success;
  final String? errorCode;
  final String? errorMessage;
  final bool? rewardEarned;
  final Map<String, dynamic>? extra;

  const TopOnShowResult({
    required this.success,
    this.errorCode,
    this.errorMessage,
    this.rewardEarned,
    this.extra,
  });

  factory TopOnShowResult.success({bool? rewardEarned, Map<String, dynamic>? extra}) {
    return TopOnShowResult(success: true, rewardEarned: rewardEarned, extra: extra);
  }

  factory TopOnShowResult.failure(String errorMessage, {String? errorCode}) {
    return TopOnShowResult(
      success: false,
      errorCode: errorCode,
      errorMessage: errorMessage,
    );
  }

  @override
  String toString() => 'TopOnShowResult(success: $success, reward: $rewardEarned)';
}

enum BannerPosition { top, bottom }

enum BannerSize {
  standard, // 320x50
  large,    // 320x100
  medium,   // 300x250
  adaptive,
}
