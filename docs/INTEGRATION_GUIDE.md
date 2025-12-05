# Integration Guide: Login, Ads, and Payments

This guide explains the integrations that have been added to NeuroSpark and how to configure them.

## ✅ What's Been Integrated

### 1. Login Page (`/login`)
- **Location**: `lib/features/auth/presentation/pages/login_page.dart`
- **Features**:
  - Email/password authentication
  - Sign up functionality
  - Google Sign-In integration
  - Forgot password (UI ready, needs backend implementation)
  - Beautiful gradient background matching app theme

### 2. Google AdMob Integration
- **Service**: `lib/core/services/ad_service.dart`
- **Features**:
  - Banner ads widget
  - Interstitial ads helper
  - Rewarded ads helper
  - Auto-initialization in `main.dart`
  - Ad widget added to dashboard

### 3. In-App Purchase Integration
- **Service**: `lib/core/services/payment_service.dart`
- **Subscription Page**: `lib/features/settings/presentation/pages/subscription_page.dart`
- **Features**:
  - Premium monthly/yearly subscriptions
  - Remove ads purchase
  - Coin purchases (100, 500, 1000)
  - Purchase restoration
  - Beautiful subscription UI

## 🔧 Configuration Required

### AdMob Setup

1. **Create AdMob Account**:
   - Go to https://admob.google.com/
   - Create an account and add your app

2. **Get Ad Unit IDs**:
   - Create ad units for:
     - Banner ads
     - Interstitial ads
     - Rewarded ads
   - Get separate IDs for Android and iOS

3. **Update Ad Unit IDs**:
   - Open `lib/core/services/ad_service.dart`
   - Replace test IDs with your actual Ad Unit IDs:
     ```dart
     // Android
     static const String _androidBannerAdUnitId = 'YOUR_ANDROID_BANNER_ID';
     static const String _androidInterstitialAdUnitId = 'YOUR_ANDROID_INTERSTITIAL_ID';
     static const String _androidRewardedAdUnitId = 'YOUR_ANDROID_REWARDED_ID';
     
     // iOS
     static const String _iosBannerAdUnitId = 'YOUR_IOS_BANNER_ID';
     static const String _iosInterstitialAdUnitId = 'YOUR_IOS_INTERSTITIAL_ID';
     static const String _iosRewardedAdUnitId = 'YOUR_IOS_REWARDED_ID';
     ```

4. **Android Configuration**:
   - Add to `android/app/src/main/AndroidManifest.xml`:
     ```xml
     <meta-data
         android:name="com.google.android.gms.ads.APPLICATION_ID"
         android:value="ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX"/>
     ```

5. **iOS Configuration**:
   - Add to `ios/Runner/Info.plist`:
     ```xml
     <key>GADApplicationIdentifier</key>
     <string>ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX</string>
     ```

### In-App Purchase Setup

1. **Google Play Console** (Android):
   - Go to your app in Google Play Console
   - Navigate to "Monetization setup" > "Products" > "In-app products"
   - Create products with these IDs:
     - `premium_monthly`
     - `premium_yearly`
     - `remove_ads`
     - `coins_100`
     - `coins_500`
     - `coins_1000`

2. **App Store Connect** (iOS):
   - Go to your app in App Store Connect
   - Navigate to "Features" > "In-App Purchases"
   - Create products with the same IDs as above

3. **Update Product IDs** (if needed):
   - Open `lib/core/services/payment_service.dart`
   - Modify the product ID constants if you use different IDs

4. **Implement Purchase Handling**:
   - Open `lib/core/services/payment_service.dart`
   - Update `_handleSuccessfulPurchase()` method to:
     - Grant premium features
     - Add coins to user account
     - Remove ads
     - Update user subscription status in Firestore

### Firebase Authentication

The login page uses Firebase Auth which is already configured. Make sure:
- Email/Password authentication is enabled in Firebase Console
- Google Sign-In is configured (already set up)

## 📱 Usage

### Login Flow
1. User opens app → Welcome page
2. User taps "Sign in with Email" → Login page
3. User can:
   - Sign in with existing account
   - Create new account
   - Sign in with Google
   - Navigate back to welcome page

### Ads Display
- Banner ads automatically appear on the dashboard
- To show interstitial ads:
  ```dart
  final interstitialAd = InterstitialAdHelper();
  await interstitialAd.loadAd();
  await interstitialAd.show();
  ```
- To show rewarded ads:
  ```dart
  final rewardedAd = RewardedAdHelper();
  await rewardedAd.loadAd();
  await rewardedAd.show(
    onRewarded: (reward) {
      // Grant reward to user
    },
  );
  ```

### Payments
- Users can access subscription page from Settings
- Navigate to: Settings → Premium section → View Plans
- Or directly: `/settings/subscription`

## 🎨 UI Locations

1. **Login Page**: `/login` route
2. **Welcome Page**: Updated with "Sign in with Email" button
3. **Dashboard**: Banner ad widget at bottom
4. **Settings**: Premium section with subscription link

## 📝 Next Steps

1. **Configure AdMob**:
   - Replace test ad unit IDs with real ones
   - Add AdMob app ID to AndroidManifest.xml and Info.plist

2. **Configure In-App Purchases**:
   - Create products in Google Play Console / App Store Connect
   - Implement purchase handling logic in `PaymentService`

3. **Test**:
   - Test login flow
   - Test ad display (use test IDs for now)
   - Test purchase flow (use test products)

4. **Backend Integration** (Optional):
   - Store subscription status in Firestore
   - Implement purchase verification
   - Handle subscription renewals

## 🔒 Security Notes

- Never commit real Ad Unit IDs or product IDs to public repos
- Use environment variables or secure storage for sensitive data
- Implement server-side purchase verification for production
- Handle purchase failures gracefully

## 📚 Resources

- [AdMob Documentation](https://developers.google.com/admob)
- [In-App Purchase Documentation](https://pub.dev/packages/in_app_purchase)
- [Firebase Auth Documentation](https://firebase.google.com/docs/auth)

