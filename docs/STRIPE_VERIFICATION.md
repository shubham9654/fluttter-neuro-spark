# ✅ Stripe Integration Verification Guide

This guide helps you verify that Stripe payments are properly integrated in your NeuroSpark app.

## 📋 Quick Checklist

### 1. Code Integration ✅
- [x] `flutter_stripe` package added to `pubspec.yaml`
- [x] `StripeService` initialized in `main.dart`
- [x] Premium Plans page created (`premium_plans_page.dart`)
- [x] Route configured (`/settings/premium`)
- [x] Settings page links to premium page

### 2. Configuration Required ⚠️

#### A. Stripe Publishable Key
You need to set your Stripe publishable key when running the app:

**For Development (Test Mode):**
```bash
flutter run --dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_your_test_key_here
```

**For Production:**
```bash
flutter run --dart-define=STRIPE_PUBLISHABLE_KEY=pk_live_your_live_key_here
```

**Get your keys from:** [Stripe Dashboard](https://dashboard.stripe.com/apikeys)

#### B. Firebase Cloud Functions
You need to set up Firebase Functions for payment processing:

1. **Install Firebase CLI:**
   ```bash
   npm install -g firebase-tools
   ```

2. **Login to Firebase:**
   ```bash
   firebase login
   ```

3. **Initialize Functions (if not done):**
   ```bash
   firebase init functions
   ```

4. **Set Stripe Secret Key:**
   ```bash
   firebase functions:config:set stripe.secret_key="sk_test_your_secret_key"
   ```

5. **Create Functions** (see `docs/STRIPE_SETUP.md` for full code)

6. **Deploy Functions:**
   ```bash
   firebase deploy --only functions
   ```

## 🧪 Testing Steps

### Step 1: Verify Stripe Initialization

1. **Run the app with Stripe key:**
   ```bash
   flutter run --dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_51...
   ```

2. **Check console logs:**
   - ✅ Look for: `✅ Stripe initialized with Firebase Functions`
   - ❌ If you see: `⚠️ Stripe publishable key missing; skipping initialization.`
     → Your key is not set correctly

3. **Check app startup:**
   - Open the app
   - Check debug console for Stripe initialization message

### Step 2: Test Premium Plans Page

1. **Navigate to Premium Plans:**
   - Open app → Settings → Click "Premium" button
   - Should navigate to `/settings/premium`

2. **Verify UI:**
   - ✅ Two plans displayed (Monthly & Yearly)
   - ✅ Prices shown correctly
   - ✅ Features listed
   - ✅ "Subscribe Now" buttons visible

3. **Check for errors:**
   - No red error messages
   - No crashes when opening page

### Step 3: Test Payment Flow

1. **Click "Subscribe Now" on any plan**

2. **Expected behavior:**
   - ✅ Payment sheet should open (Stripe Payment Sheet)
   - ✅ You can enter card details
   - ✅ Payment processing happens

3. **Use Stripe Test Cards:**
   - **Success:** `4242 4242 4242 4242`
   - **Decline:** `4000 0000 0000 0002`
   - **3D Secure:** `4000 0027 6000 3184`
   - **Expiry:** Any future date (e.g., 12/25)
   - **CVC:** Any 3 digits (e.g., 123)
   - **ZIP:** Any 5 digits (e.g., 12345)

4. **After successful payment:**
   - ✅ Success message shown
   - ✅ Premium status saved to Firestore
   - ✅ User redirected back to settings

### Step 4: Verify Firestore Updates

1. **Check Firestore Console:**
   - Go to Firebase Console → Firestore
   - Navigate to `users/{userId}`
   - Check for these fields:
     - `isPremium: true`
     - `premiumPlanId: "premium_monthly"` or `"premium_yearly"`
     - `premiumUntil: "2024-12-31T..."` (ISO date string)
     - `premiumPurchaseDate: "2024-01-01T..."` (ISO date string)
     - `premiumInterval: "month"` or `"year"`

## 🔍 Debugging

### Check 1: Stripe Initialization

**Problem:** Stripe not initializing

**Solution:**
```dart
// In main.dart, check if key is being read:
final key = const String.fromEnvironment('STRIPE_PUBLISHABLE_KEY');
print('Stripe Key: ${key.isEmpty ? "MISSING" : "SET"}');
```

**Fix:**
- Ensure you're passing `--dart-define=STRIPE_PUBLISHABLE_KEY=...`
- Check key starts with `pk_test_` or `pk_live_`
- Verify no extra spaces in the key

### Check 2: Firebase Functions

**Problem:** Payment fails with "Function not found"

**Solution:**
1. Verify functions are deployed:
   ```bash
   firebase functions:list
   ```

2. Check function logs:
   ```bash
   firebase functions:log
   ```

3. Ensure function names match:
   - `createPaymentIntent`
   - `createEphemeralKey`

### Check 3: Payment Sheet Not Opening

**Problem:** Clicking "Subscribe Now" does nothing

**Possible causes:**
1. **Stripe not initialized:**
   - Check console for initialization message
   - Verify key is set correctly

2. **User not authenticated:**
   - Ensure user is signed in
   - Check `currentUserProvider` has a user

3. **Firebase Functions error:**
   - Check Firebase Functions logs
   - Verify functions are deployed

**Debug code:**
```dart
// Add to premium_plans_page.dart _purchasePlan method:
try {
  print('🔍 Starting payment...');
  print('🔍 User: ${user?.uid}');
  print('🔍 Amount: ${plan.priceInCents}');
  
  await StripeService.pay(...);
  
  print('✅ Payment successful');
} catch (e, stack) {
  print('❌ Payment error: $e');
  print('📍 Stack: $stack');
}
```

### Check 4: Payment Succeeds but Firestore Not Updated

**Problem:** Payment works but premium status not saved

**Solution:**
1. Check Firestore permissions:
   - Ensure user can write to `users/{userId}` collection
   - Check Firestore security rules

2. Check Firestore service:
   - Verify `FirestoreService` is initialized
   - Check user ID is correct

3. Check console for errors:
   - Look for Firestore write errors
   - Check network connectivity

## 📱 Platform-Specific Checks

### Android

1. **Min SDK Version:**
   - Check `android/app/build.gradle`
   - Ensure `minSdkVersion >= 21`

2. **Internet Permission:**
   - Check `android/app/src/main/AndroidManifest.xml`
   - Should have: `<uses-permission android:name="android.permission.INTERNET" />`

### iOS

1. **URL Scheme:**
   - Check `ios/Runner/Info.plist`
   - Should have URL scheme: `neuro_spark`

2. **Merchant ID (Optional for Apple Pay):**
   - Only needed if using Apple Pay
   - Configure in Xcode → Capabilities

## 🧪 Test Scenarios

### Scenario 1: Successful Payment
1. Navigate to Premium Plans
2. Select Monthly plan
3. Click "Subscribe Now"
4. Enter test card: `4242 4242 4242 4242`
5. Complete payment
6. ✅ Verify success message
7. ✅ Verify Firestore updated
8. ✅ Verify redirected to settings

### Scenario 2: Payment Decline
1. Navigate to Premium Plans
2. Select Yearly plan
3. Click "Subscribe Now"
4. Enter test card: `4000 0000 0000 0002`
5. Complete payment
6. ✅ Verify error message shown
7. ✅ Verify Firestore NOT updated
8. ✅ Verify still on premium page

### Scenario 3: User Not Authenticated
1. Sign out of app
2. Navigate to Premium Plans
3. Click "Subscribe Now"
4. ✅ Verify error: "Please sign in to purchase premium"

### Scenario 4: Network Error
1. Turn off internet
2. Navigate to Premium Plans
3. Click "Subscribe Now"
4. ✅ Verify error message about network
5. ✅ Verify no crash

## 📊 Verification Checklist

Use this checklist to verify everything is working:

- [ ] Stripe initializes on app startup (check console)
- [ ] Premium Plans page loads without errors
- [ ] Plans display correctly (Monthly & Yearly)
- [ ] Prices show correctly ($9.99/month, $95.99/year)
- [ ] Features list displays for each plan
- [ ] "Subscribe Now" button is clickable
- [ ] Payment sheet opens when clicking button
- [ ] Can enter test card details
- [ ] Successful payment shows success message
- [ ] Failed payment shows error message
- [ ] Firestore updates after successful payment
- [ ] User redirected after successful payment
- [ ] Premium status persists in Firestore

## 🚨 Common Issues & Solutions

### Issue 1: "Stripe publishable key missing"
**Solution:** Add `--dart-define=STRIPE_PUBLISHABLE_KEY=...` when running

### Issue 2: "Function not found"
**Solution:** Deploy Firebase Functions: `firebase deploy --only functions`

### Issue 3: "Payment sheet not opening"
**Solution:** 
- Check Stripe initialization
- Verify user is authenticated
- Check Firebase Functions logs

### Issue 4: "Payment succeeds but no Firestore update"
**Solution:**
- Check Firestore security rules
- Verify FirestoreService is working
- Check console for errors

## 📞 Need Help?

1. **Check Stripe Dashboard:**
   - Go to [Stripe Dashboard](https://dashboard.stripe.com/test/payments)
   - Check if payments are being created
   - Review payment logs

2. **Check Firebase Console:**
   - Go to Firebase Console → Functions
   - Check function logs
   - Review function execution history

3. **Check App Logs:**
   - Run app with verbose logging
   - Look for Stripe-related messages
   - Check for error stack traces

## ✅ Success Indicators

Your Stripe integration is working correctly if:

1. ✅ Stripe initializes on app startup
2. ✅ Premium Plans page loads and displays plans
3. ✅ Payment sheet opens when clicking "Subscribe Now"
4. ✅ Test payment completes successfully
5. ✅ Success message appears after payment
6. ✅ Firestore is updated with premium status
7. ✅ User is redirected after payment

If all these work, your Stripe integration is **properly configured**! 🎉

