import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:get/get.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  RewardedAd? _rewardedAd;
  bool _isAdLoading = false;

  // 테스트 전용 보상형 광고 ID
  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  Future<void> init() async {
    await MobileAds.instance.initialize();
    _loadRewardedAd();
  }

  void _loadRewardedAd() {
    if (_isAdLoading) return;
    _isAdLoading = true;

    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
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

  Future<void> showRewardedAd({required Function() onRewardEarned}) async {
    if (_rewardedAd == null) {
      // 광고가 로드되지 않았을 경우 일단 로드 시도하고 알림
      _loadRewardedAd();
      Get.snackbar("광고 준비 중", "광고를 불러오는 중입니다. 잠시 후 다시 시도해주세요.");
      return;
    }

    await _rewardedAd!.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      onRewardEarned();
    });

    _rewardedAd = null;
    _loadRewardedAd(); // 다음을 위해 미리 로드
  }
}
