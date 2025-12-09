# Stripe Setup with Firebase Functions

This guide shows you how to set up Stripe payments using Firebase Cloud Functions (no separate backend needed!).

## 📋 Prerequisites

1. Firebase project with Cloud Functions enabled
2. Stripe account (get your API keys from [Stripe Dashboard](https://dashboard.stripe.com/apikeys))
3. Flutter app with Firebase already configured

## 🚀 Setup Steps

### Step 1: Install Dependencies

The Flutter dependencies are already added to `pubspec.yaml`:
- `flutter_stripe: ^11.1.0`
- `cloud_functions: ^5.1.1`

Run:
```bash
flutter pub get
```

### Step 2: Configure Stripe Publishable Key

Use a local `.env` (never commit secrets) and feed it into dart-define:

1) Create `.env` (not tracked) from the sample  
   - Copy `docs/stripe.env.example` → `.env`  
   - Set your keys:
     - `STRIPE_PUBLISHABLE_KEY=pk_test_...`
     - `STRIPE_SECRET_KEY=sk_test_...` (used by Functions)
     - Optional: `STRIPE_WEBHOOK_SECRET=whsec_...`

2) Export env vars locally before running:
   - macOS/Linux: `export $(grep -v '^#' .env | xargs)`  
   - PowerShell: `Get-Content .env | foreach { if ($_ -and $_ -notmatch '^#') { $k,$v = $_.Split('='); setx $k $v } }`

3) Run app with dart-define from env:
```bash
flutter run --dart-define=STRIPE_PUBLISHABLE_KEY=$STRIPE_PUBLISHABLE_KEY
```

4) IDE configs:
- VS Code: add the dart-define in `.vscode/launch.json`
- Android Studio: Run/Debug config → Additional run args → `--dart-define=STRIPE_PUBLISHABLE_KEY=$STRIPE_PUBLISHABLE_KEY`

### Step 3: Set Up Firebase Functions

#### 3.1 Initialize Firebase Functions (if not already done)

```bash
# Install Firebase CLI if needed
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Functions in your project
cd your-project-root
firebase init functions

# Select:
# - TypeScript or JavaScript
# - Install dependencies
```

#### 3.2 Install Stripe in Functions

```bash
cd functions
npm install stripe
```

#### 3.3 Add Stripe Secret Key to Firebase

```bash
# Set your Stripe secret key (get from Stripe Dashboard)
firebase functions:config:set stripe.secret_key="sk_test_..."

# For production:
firebase functions:config:set stripe.secret_key="sk_live_..."
```

#### 3.4 Create Firebase Functions

Create `functions/index.js` (or `index.ts` for TypeScript):

```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const stripe = require('stripe')(functions.config().stripe.secret_key);

admin.initializeApp();

// Create or retrieve Stripe customer
async function getOrCreateCustomer(userId, email) {
  const userRef = admin.firestore().collection('users').doc(userId);
  const userDoc = await userRef.get();
  
  let customerId = userDoc.data()?.stripeCustomerId;
  
  if (!customerId) {
    // Create new Stripe customer
    const customer = await stripe.customers.create({
      email: email,
      metadata: {
        firebaseUID: userId,
      },
    });
    
    customerId = customer.id;
    
    // Save customer ID to Firestore
    await userRef.set({
      stripeCustomerId: customerId,
    }, { merge: true });
  }
  
  return customerId;
}

// Create Payment Intent
exports.createPaymentIntent = functions.https.onCall(async (data, context) => {
  // Verify user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated'
    );
  }

  const { amount, currency = 'usd', metadata = {} } = data;
  const userId = context.auth.uid;
  const email = context.auth.token.email;

  if (!amount || amount < 50) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Amount must be at least 50 cents'
    );
  }

  try {
    // Get or create Stripe customer
    const customerId = await getOrCreateCustomer(userId, email);

    // Create payment intent
    const paymentIntent = await stripe.paymentIntents.create({
      amount: amount,
      currency: currency,
      customer: customerId,
      metadata: {
        firebaseUID: userId,
        ...metadata,
      },
      automatic_payment_methods: {
        enabled: true,
      },
    });

    return {
      clientSecret: paymentIntent.client_secret,
      paymentIntentId: paymentIntent.id,
    };
  } catch (error) {
    console.error('Error creating payment intent:', error);
    throw new functions.https.HttpsError(
      'internal',
      'Failed to create payment intent',
      error.message
    );
  }
});

// Create Ephemeral Key
exports.createEphemeralKey = functions.https.onCall(async (data, context) => {
  // Verify user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated'
    );
  }

  const userId = context.auth.uid;
  const email = context.auth.token.email;

  try {
    // Get or create Stripe customer
    const customerId = await getOrCreateCustomer(userId, email);

    // Create ephemeral key (valid for 24 hours)
    const ephemeralKey = await stripe.ephemeralKeys.create(
      { customer: customerId },
      { apiVersion: '2024-06-20' } // Use latest Stripe API version
    );

    return {
      customerId: customerId,
      ephemeralKeySecret: ephemeralKey.secret,
    };
  } catch (error) {
    console.error('Error creating ephemeral key:', error);
    throw new functions.https.HttpsError(
      'internal',
      'Failed to create ephemeral key',
      error.message
    );
  }
});
```

#### 3.5 Deploy Functions

```bash
firebase deploy --only functions
```

### Step 4: Configure Platform-Specific Settings

#### Android

Ensure `minSdkVersion >= 21` in `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        minSdkVersion 21
    }
}
```

#### iOS

1. Add URL scheme to `ios/Runner/Info.plist`:
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>neuro_spark</string>
    </array>
  </dict>
</array>
```

2. (Optional) For Apple Pay, add merchant ID:
```xml
<key>com.apple.developer.in-app-payments</key>
<array>
  <string>merchant.com.neurospark</string>
</array>
```

### Step 5: Use Stripe in Your App

The `StripeService` is already initialized in `main.dart`. You can now use it anywhere:

```dart
import 'package:neuro_spark/core/services/stripe_service.dart';

// Simple payment flow
try {
  await StripeService.pay(
    amount: 1000, // $10.00 in cents
    currency: 'usd',
    metadata: {
      'productId': 'premium_monthly',
      'userId': userId,
    },
  );
  
  // Payment successful!
  print('Payment completed!');
} catch (e) {
  // Handle error
  print('Payment failed: $e');
}
```

## 🔒 Security Notes

1. **Never expose your Stripe secret key** in client-side code
2. Always use Firebase Functions to create payment intents
3. Verify user authentication in your functions
4. Use test keys (`pk_test_`, `sk_test_`) during development
5. Switch to live keys only in production

## 🧪 Testing

1. Use Stripe test cards from [Stripe Testing](https://stripe.com/docs/testing)
   - Success: `4242 4242 4242 4242`
   - Decline: `4000 0000 0000 0002`
   - 3D Secure: `4000 0027 6000 3184`

2. Check Firebase Functions logs:
```bash
firebase functions:log
```

3. Monitor Stripe Dashboard for test payments

## 📚 Additional Resources

- [Stripe Flutter SDK](https://github.com/flutter-stripe/flutter_stripe)
- [Stripe Payment Intents](https://stripe.com/docs/payments/payment-intents)
- [Firebase Cloud Functions](https://firebase.google.com/docs/functions)
- [Stripe Testing Guide](https://stripe.com/docs/testing)
