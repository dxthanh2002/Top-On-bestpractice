import 'dart:io';
import 'ad_unit.dart';

class TopOnPlatformConfig {
  final String appId;
  final String appKey;
  final String? debugKey;
  final Map<TopOnAdUnit, String> placements;
  final Map<TopOnAdUnit, String> sceneIds;
  final Map<TopOnAdUnit, String> showCustomExts;

  const TopOnPlatformConfig({
    required this.appId,
    required this.appKey,
    this.debugKey,
    required this.placements,
    this.sceneIds = const {},
    this.showCustomExts = const {},
  });

  String? getPlacement(TopOnAdUnit unit) => placements[unit];
  String? getSceneId(TopOnAdUnit unit) => sceneIds[unit];
  String? getShowCustomExt(TopOnAdUnit unit) => showCustomExts[unit];
}

class TopOnAdsConfig {
  final TopOnPlatformConfig ios;
  final TopOnPlatformConfig android;
  final String? channel;
  final String? subChannel;
  final Map<String, dynamic>? customData;

  const TopOnAdsConfig({
    required this.ios,
    required this.android,
    this.channel,
    this.subChannel,
    this.customData,
  });

  TopOnPlatformConfig get current => Platform.isIOS ? ios : android;
}
