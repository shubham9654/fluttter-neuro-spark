# 🔥 Firebase Setup Guide for NeuroSpark

Complete guide to set up Firebase for the NeuroSpark app.

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"**
3. Project name: `neurospark` (or your choice)
4. Enable Google Analytics (optional but recommended)
5. Click **"Create project"**

## Step 2: Enable Authentication

1. In the Firebase Console, select your project
2. Go to **Build → Authentication**
3. Click **"Get started"**
4. Enable these sign-in methods:

### Anonymous Authentication
- Click **Anonymous**
- Toggle **Enable**
- Click **Save**

### Google Sign-In
- Click **Google**
- Toggle **Enable**
- Set support email
- Click **Save**

### Optional: Email/Password
- Click **Email/Password**
- Toggle **Enable**
- Click **Save**

## Step 3: Create Firestore Database

1. Go to **Build → Firestore Database**
2. Click **"Create database"**
3. Choose location (closest to your users)
4. Start in **test mode** for development:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.time < timestamp.date(2026, 1, 5);
    }
  }
}
```

**Important**: These test rules allow full access until January 5, 2026. Update to production rules before that date!

5. Click **"Enable"**

### Production Security Rules

When you're ready for production, update to:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User documents
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // User's subcollections (tasks, gameStats, etc.)
      match /{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    // Deny all other access
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

## Step 4: Enable Storage (Optional)

1. Go to **Build → Storage**
2. Click **"Get started"**
3. Start in **test mode** for development
4. Click **"Next"** → **"Done"**

### Production Storage Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Step 5: Register Your Apps

### For Web

1. In Project Settings, scroll to **"Your apps"**
2. Click the **Web icon** `</>`
3. App nickname: `neuro_spark_web`
4. ✅ Check "Also set up Firebase Hosting"
5. Click **"Register app"**
6. Copy the configuration object:

```javascript
const firebaseConfig = {
  apiKey: "AIza...",
  authDomain: "neurospark-xxx.firebaseapp.com",
  projectId: "neurospark-xxx",
  storageBucket: "neurospark-xxx.appspot.com",
  messagingSenderId: "123456789",
  appId: "1:123456789:web:abcdef123456",
  measurementId: "G-XXXXXXXXXX"
};
```

7. Update `lib/firebase_options.dart`:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_API_KEY',
  appId: 'YOUR_APP_ID',
  messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
  projectId: 'YOUR_PROJECT_ID',
  authDomain: 'YOUR_AUTH_DOMAIN',
  storageBucket: 'YOUR_STORAGE_BUCKET',
  measurementId: 'YOUR_MEASUREMENT_ID',
);
```

### For Android

1. Click **Android icon**
2. Android package name: `com.neurospark.app` (or your package name)
3. Download `google-services.json`
4. Place it in `android/app/`
5. Update `android/build.gradle`:

```gradle
buildscript {
  dependencies {
    classpath 'com.google.gms:google-services:4.4.0'
  }
}
```

6. Update `android/app/build.gradle`:

```gradle
apply plugin: 'com.google.gms.google-services'
```

7. Get SHA-1 certificate:

```bash
# Debug
keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore

# Release (if you have one)
keytool -list -v -alias <your-key-name> -keystore <path-to-keystore>
```

8. Add SHA-1 to Firebase:
   - Project Settings → Your apps → Android app
   - Add fingerprint
   - Paste SHA-1

9. Download new `google-services.json` and replace

### For iOS

1. Click **iOS icon**
2. iOS bundle ID: `com.neurospark.app` (or your bundle ID)
3. Download `GoogleService-Info.plist`
4. In Xcode, add it to `Runner` folder (drag and drop)
5. Make sure "Copy items if needed" is checked
6. Update `ios/Runner/Info.plist`:

```xml
<!-- Add inside <dict> tag -->
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <!-- Reversed client ID from GoogleService-Info.plist -->
      <string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
    </array>
  </dict>
</array>
```

## Step 6: Configure Google Sign-In

### Get OAuth Credentials

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your Firebase project
3. Go to **APIs & Services → Credentials**
4. Click **"Create Credentials" → "OAuth client ID"**

#### For Web
1. Application type: **Web application**
2. Name: `NeuroSpark Web Client`
3. Authorized JavaScript origins:
   - `http://localhost`
   - `http://localhost:5000`
   - Your production domain
4. Authorized redirect URIs:
   - `http://localhost`
   - Your production domain
5. Click **"Create"**
6. Copy the **Client ID**

#### For Android
1. Application type: **Android**
2. Name: `NeuroSpark Android`
3. Package name: `com.neurospark.app`
4. SHA-1 fingerprint: (paste from earlier)
5. Click **"Create"**

#### For iOS
1. Application type: **iOS**
2. Name: `NeuroSpark iOS`
3. Bundle ID: `com.neurospark.app`
4. Click **"Create"**

### Update Firebase Authentication

1. Back in Firebase Console → Authentication
2. Click **Google** provider
3. Web client ID and Web client secret should be auto-populated
4. Click **"Save"**

## Step 7: Test Your Setup

1. Run the app:
   ```bash
   flutter run -d edge
   ```

2. Try these features:
   - ✅ Anonymous sign-in
   - ✅ Google sign-in
   - ✅ Creating tasks
   - ✅ Completing focus sessions
   - ✅ Earning rewards

3. Check Firebase Console:
   - **Authentication** → Users should appear
   - **Firestore** → Data should be created
   - **Usage** → Should show API calls

## Step 8: Environment Setup (Optional)

For multiple environments (dev, staging, prod), create multiple Firebase projects:

```
neurospark-dev
neurospark-staging
neurospark-prod
```

Then use different config files:
- `lib/firebase_options_dev.dart`
- `lib/firebase_options_staging.dart`
- `lib/firebase_options_prod.dart`

## Troubleshooting

### "Firebase not initialized" error
- Make sure `Firebase.initializeApp()` is called in `main()`
- Check that `firebase_options.dart` has correct values

### Google Sign-In not working
- Verify SHA-1 is added (Android)
- Check bundle ID matches (iOS)
- Make sure OAuth client is created
- Check authorized domains in Firebase Auth settings

### Firestore permission denied
- Check security rules
- Verify user is authenticated
- Make sure userId matches in rules

### Build errors
- Run `flutter pub get`
- Run `flutter clean`
- Check all config files are in place
- Verify Firebase plugin versions match

## Next Steps

1. ✅ Set up Firebase (you're here!)
2. Configure CI/CD with Firebase Hosting
3. Set up Crashlytics for error monitoring
4. Enable Analytics for user insights
5. Set up Cloud Functions for backend logic
6. Configure App Check for security

## Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)
- [Google Cloud Console](https://console.cloud.google.com/)

---

**Need help?** Create an issue in the repository with:
- Platform (Web/Android/iOS)
- Error message
- Steps to reproduce

