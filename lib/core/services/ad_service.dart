import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Ad Service for managing Google AdMob ads
class AdService {
  static bool _isInitialized = false;
  
  // Test Ad Unit IDs - Replace with your actual Ad Unit IDs from AdMob
  // For Android
  static const String _androidBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111'; // Test ID
  static const String _androidInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712'; // Test ID
  static const String _androidRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917'; // Test ID
  
  // For iOS
  static const String _iosBannerAdUnitId = 'ca-app-pub-3940256099942544/2934735716'; // Test ID
  static const String _iosInterstitialAdUnitId = 'ca-app-pub-3940256099942544/4411468910'; // Test ID
  static const String _iosRewardedAdUnitId = 'ca-app-pub-3940256099942544/1712485313'; // Test ID

  /// Initialize AdMob (only on mobile platforms, not web)
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    // AdMob doesn't support web platform
    if (kIsWeb) {
      debugPrint('⚠️ AdMob is not supported on web platform');
      return;
    }
    
    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      debugPrint('✅ AdMob initialized successfully');
    } catch (e) {
      debugPrint('❌ AdMob initialization failed: $e');
    }
  }

  /// Get banner ad unit ID based on platform
  static String get bannerAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return _androidBannerAdUnitId;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return _iosBannerAdUnitId;
    }
    return _androidBannerAdUnitId; // Default to Android
  }

  /// Get interstitial ad unit ID based on platform
  static String get interstitialAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return _androidInterstitialAdUnitId;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return _iosInterstitialAdUnitId;
    }
    return _androidInterstitialAdUnitId; // Default to Android
  }

  /// Get rewarded ad unit ID based on platform
  static String get rewardedAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return _androidRewardedAdUnitId;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return _iosRewardedAdUnitId;
    }
    return _androidRewardedAdUnitId; // Default to Android
  }
}

/// Banner Ad Widget
class BannerAdWidget extends StatefulWidget {
  final AdSize adSize;
  
  const BannerAdWidget({
    super.key,
    this.adSize = AdSize.banner,
  });

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    // Only load ads on mobile platforms
    if (!kIsWeb) {
      _loadAd();
    }
  }

  void _loadAd() {
    // Don't load on web
    if (kIsWeb) return;
    
    try {
      _bannerAd = BannerAd(
        adUnitId: AdService.bannerAdUnitId,
        size: widget.adSize,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (_) {
            if (mounted) {
              setState(() {
                _isAdLoaded = true;
              });
            }
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('Banner ad failed to load: $error');
            ad.dispose();
          },
          onAdOpened: (_) => debugPrint('Banner ad opened'),
          onAdClosed: (_) => debugPrint('Banner ad closed'),
        ),
      );
      _bannerAd?.load();
    } catch (e) {
      debugPrint('Error loading banner ad: $e');
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Don't show ads on web
    if (kIsWeb) {
      return const SizedBox.shrink();
    }
    
    if (!_isAdLoaded) {
      return const SizedBox.shrink();
    }

    return Container(
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}

/// Interstitial Ad Helper
class InterstitialAdHelper {
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;

  /// Load an interstitial ad
  Future<void> loadAd() async {
    await InterstitialAd.load(
      adUnitId: AdService.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdLoaded = true;
          debugPrint('✅ Interstitial ad loaded');
        },
        onAdFailedToLoad: (error) {
          debugPrint('❌ Interstitial ad failed to load: $error');
          _isAdLoaded = false;
        },
      ),
    );
  }

  /// Show the interstitial ad
  Future<void> show() async {
    if (!_isAdLoaded || _interstitialAd == null) {
      debugPrint('⚠️ Interstitial ad not loaded');
      await loadAd();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) {
        debugPrint('✅ Interstitial ad showed');
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('✅ Interstitial ad dismissed');
        ad.dispose();
        _isAdLoaded = false;
        loadAd(); // Load next ad
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('❌ Interstitial ad failed to show: $error');
        ad.dispose();
        _isAdLoaded = false;
        loadAd();
      },
    );

    _interstitialAd!.show();
  }

  void dispose() {
    _interstitialAd?.dispose();
  }
}

/// Rewarded Ad Helper
class RewardedAdHelper {
  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;

  /// Load a rewarded ad
  Future<void> loadAd() async {
    await RewardedAd.load(
      adUnitId: AdService.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isAdLoaded = true;
          debugPrint('✅ Rewarded ad loaded');
        },
        onAdFailedToLoad: (error) {
          debugPrint('❌ Rewarded ad failed to load: $error');
          _isAdLoaded = false;
        },
      ),
    );
  }

  /// Show the rewarded ad
  Future<void> show({
    required Function(RewardItem) onRewarded,
    VoidCallback? onAdDismissed,
  }) async {
    if (!_isAdLoaded || _rewardedAd == null) {
      debugPrint('⚠️ Rewarded ad not loaded');
      await loadAd();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) {
        debugPrint('✅ Rewarded ad showed');
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('✅ Rewarded ad dismissed');
        ad.dispose();
        _isAdLoaded = false;
        onAdDismissed?.call();
        loadAd(); // Load next ad
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('❌ Rewarded ad failed to show: $error');
        ad.dispose();
        _isAdLoaded = false;
        loadAd();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        debugPrint('✅ User earned reward: ${reward.amount} ${reward.type}');
        onRewarded(reward);
      },
    );
  }

  void dispose() {
    _rewardedAd?.dispose();
  }
}

