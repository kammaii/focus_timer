import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  RewardedAd? _rewardedAd;
  bool _isAdLoading = false;
  bool _adsDisabledForDevice = false;

  static const String _adsDisabledForDeviceKey = 'ads_disabled_for_device';

  static const String _androidDebugRewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';
  static const String _iosDebugRewardedAdUnitId =
      'ca-app-pub-3940256099942544/1712485313';

  // TODO: Replace these release ad unit IDs before publishing.
  static const String _androidReleaseRewardedAdUnitId =
      'ca-app-pub-4839718329129134/3643299948';
  static const String _iosReleaseRewardedAdUnitId =
      'ca-app-pub-4839718329129134/7354864538';

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return kReleaseMode
          ? _androidReleaseRewardedAdUnitId
          : _androidDebugRewardedAdUnitId;
    } else if (Platform.isIOS) {
      return kReleaseMode
          ? _iosReleaseRewardedAdUnitId
          : _iosDebugRewardedAdUnitId;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  Future<void> init() async {
    await _loadAdsDisabledForDevice();
    if (_adsDisabledForDevice) return;

    await MobileAds.instance.initialize();
    _loadRewardedAd();
  }

  bool get adsDisabledForDevice => _adsDisabledForDevice;

  Future<void> _loadAdsDisabledForDevice() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    _adsDisabledForDevice = prefs.getBool(_adsDisabledForDeviceKey) ?? false;
  }

  Future<void> disableAdsForDevice() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_adsDisabledForDeviceKey, true);
    _adsDisabledForDevice = true;
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }

  Future<void> enableAdsForDevice() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_adsDisabledForDeviceKey, false);
    _adsDisabledForDevice = false;
    _loadRewardedAd();
  }

  void _loadRewardedAd() {
    if (_adsDisabledForDevice || _isAdLoading) return;
    _isAdLoading = true;

    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          if (_adsDisabledForDevice) {
            ad.dispose();
            _rewardedAd = null;
            _isAdLoading = false;
            return;
          }

          _rewardedAd = ad;
          _isAdLoading = false;
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          _isAdLoading = false;
          // 실패 시 재시도 로직
          Future.delayed(const Duration(seconds: 10), () => _loadRewardedAd());
        },
      ),
    );
  }

  Future<bool> showRewardedAd({
    required FutureOr<void> Function() onRewardEarned,
  }) async {
    await _loadAdsDisabledForDevice();

    if (_adsDisabledForDevice) {
      await onRewardEarned();
      return true;
    }

    if (_rewardedAd == null) {
      // 광고가 로드되지 않았을 경우 일단 로드 시도하고 알림
      _loadRewardedAd();
      Get.snackbar("광고 준비 중", "광고를 불러오는 중입니다. 잠시 후 다시 시도해주세요.");
      return false;
    }

    final ad = _rewardedAd!;
    _rewardedAd = null;

    final completer = Completer<bool>();
    var rewardEarned = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadRewardedAd();
        if (!completer.isCompleted) {
          completer.complete(rewardEarned);
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _loadRewardedAd();
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      },
    );

    try {
      await ad.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) async {
          rewardEarned = true;
          await onRewardEarned();
        },
      );
    } catch (_) {
      ad.dispose();
      _loadRewardedAd();
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    }

    return completer.future.timeout(
      const Duration(minutes: 2),
      onTimeout: () => rewardEarned,
    );
  }
}
