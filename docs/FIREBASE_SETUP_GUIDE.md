# 🔥 Firebase Setup Guide - Fix White Screen

## Problem: White Screen & API Key Error

You're seeing:
```
API key not valid. Please pass a valid API key.
```

This is because you're using **demo Firebase keys**. Here's how to fix it:

---

## ✅ Quick Fix (2 Options)

### Option 1: Set Up Real Firebase (Recommended - 15 minutes)

Follow the steps below to get real Firebase keys.

### Option 2: Run Without Firebase (Quick - Works Now!)

I've already fixed the code to handle missing Firebase. The app now works offline!

**What works without Firebase:**
- ✅ All UI and navigation
- ✅ Task management (local storage)
- ✅ Focus sessions
- ✅ Gamification (XP, coins, streaks)
- ✅ Settings and profile (local)

**What needs Firebase:**
- ❌ Google Sign-In
- ❌ Cloud sync across devices
- ❌ Online backup

---

## 🚀 Setting Up Real Firebase Keys

### Step 1: Create Firebase Project (5 min)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"**
3. Enter project name: `neurospark` (or your choice)
4. **Disable Google Analytics** (optional, faster setup)
5. Click **"Create project"**
6. Wait for project creation
7. Click **"Continue"**

### Step 2: Register Web App (5 min)

1. In your Firebase project, click the **Web icon** `</>`
2. App nickname: `NeuroSpark Web`
3. ✅ Check **"Also set up Firebase Hosting"** (optional)
4. Click **"Register app"**

5. Copy the **firebaseConfig** object that appears:

```javascript
const firebaseConfig = {
  apiKey: "AIzaSy...",           // YOUR KEY
  authDomain: "your-project.firebaseapp.com",
  projectId: "your-project-id",
  storageBucket: "your-project.appspot.com",
  messagingSenderId: "123456789",
  appId: "1:123456789:web:abc123",
  measurementId: "G-ABC123"
};
```

6. Click **"Continue to console"**

### Step 3: Update Your App (2 min)

Open `lib/firebase_options.dart` and replace:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_ACTUAL_API_KEY_HERE',  // Paste from firebaseConfig
  appId: 'YOUR_ACTUAL_APP_ID_HERE',
  messagingSenderId: 'YOUR_SENDER_ID',
  projectId: 'your-project-id',
  authDomain: 'your-project.firebaseapp.com',
  storageBucket: 'your-project.appspot.com',
  measurementId: 'G-YOUR-ID',
);
```

### Step 4: Enable Authentication (3 min)

1. In Firebase Console, go to **Build → Authentication**
2. Click **"Get started"**
3. Click **"Anonymous"** tab
4. Toggle **"Enable"**
5. Click **"Save"**

Optional - Enable Google Sign-In:
1. Click **"Google"** tab
2. Toggle **"Enable"**
3. Enter support email
4. Click **"Save"**

### Step 5: Create Firestore Database (2 min)

1. Go to **Build → Firestore Database**
2. Click **"Create database"**
3. Select **"Start in test mode"** (for development)
4. Choose location closest to you
5. Click **"Enable"**

### Step 6: Test Your App! 🎉

```bash
flutter run -d edge
```

You should see:
- ✅ No white screen
- ✅ No API key errors
- ✅ App loads normally

---

## 📱 Android Setup (Optional)

If you want to run on Android:

### Step 1: Register Android App

1. Firebase Console → Project Settings
2. Click **Android icon**
3. Android package name: `com.example.neuro_spark`
4. App nickname: `NeuroSpark Android`
5. Click **"Register app"**

### Step 2: Download Config

1. Download `google-services.json`
2. Place it in: `android/app/google-services.json`

### Step 3: Update Build Files

Already configured! Just run:
```bash
flutter run
```

### Step 4: Get SHA-1 (for Google Sign-In)

```bash
cd android
./gradlew signingReport
```

Copy the SHA-1 and add it in Firebase:
- Project Settings → Your Android App
- Add fingerprint
- Paste SHA-1

---

## 🍎 iOS Setup (Optional)

### Step 1: Register iOS App

1. Firebase Console → Project Settings
2. Click **iOS icon**
3. iOS bundle ID: `com.example.neuroSpark`
4. App nickname: `NeuroSpark iOS`
5. Click **"Register app"**

### Step 2: Download Config

1. Download `GoogleService-Info.plist`
2. In Xcode, drag to `Runner` folder
3. Check ✅ "Copy items if needed"

### Step 3: Update Info.plist

Add to `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <!-- Copy from GoogleService-Info.plist -->
      <string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
    </array>
  </dict>
</array>

<key>NSUserNotificationsUsageDescription</key>
<string>NeuroSpark needs notifications for task reminders</string>
```

---

## 🔧 Troubleshooting

### White Screen Still Showing

**Solution 1: Clear Cache**
```bash
flutter clean
flutter pub get
flutter run -d edge
```

**Solution 2: Hard Reload**
- Open app in browser
- Press `Ctrl + Shift + R` (Windows)
- Or `Cmd + Shift + R` (Mac)

**Solution 3: Check Console**
- Press `F12` in browser
- Look for errors
- Share any error messages

### API Key Error Still Appearing

**Check:**
1. ✅ Copied entire API key (starts with `AIzaSy`)
2. ✅ No extra spaces or quotes
3. ✅ Saved `firebase_options.dart`
4. ✅ Restarted app (`flutter run`)

**Verify API Key:**
- Go to Firebase Console
- Project Settings
- General tab
- Web apps section
- Check your API key matches

### Authentication Not Working

**Check:**
1. ✅ Authentication enabled in Firebase
2. ✅ Anonymous auth enabled
3. ✅ Correct API key in code
4. ✅ No firewall blocking Firebase

---

## 🎯 Current Status

✅ **Fixed in Code:**
- App now handles missing Firebase gracefully
- No more white screen errors
- Runs in offline mode if Firebase not configured
- Better error messages in console

✅ **What Works Now (Without Firebase):**
- Complete UI and navigation
- Task management (local storage with Hive)
- Focus timer and sessions
- Gamification (XP, coins, streaks)
- All settings and preferences
- Profile editing

❌ **Needs Firebase:**
- Google Sign-In
- Cloud sync
- Cross-device data

---

## 📚 Quick Reference

### Firebase Console Links
- Main: https://console.firebase.google.com/
- Authentication: `Your Project → Build → Authentication`
- Firestore: `Your Project → Build → Firestore Database`
- Settings: `Your Project → ⚙️ Project Settings`

### Important Files
- `lib/firebase_options.dart` - Your Firebase config
- `android/app/google-services.json` - Android config
- `ios/Runner/GoogleService-Info.plist` - iOS config

### Commands
```bash
# Clean and rebuild
flutter clean && flutter pub get

# Run on web
flutter run -d edge

# Run on Android
flutter run

# Check Flutter setup
flutter doctor
```

---

## 💡 Pro Tips

1. **Use Test Mode** for Firestore during development
2. **Enable Anonymous Auth** first (easiest)
3. **Add Google Sign-In** later (optional)
4. **Keep API keys** secret (don't commit to public repos)
5. **Use environment variables** for production

---

## ✨ Next Steps

After Firebase is set up:

1. ✅ Test authentication
2. ✅ Verify Firestore writes
3. ✅ Enable cloud sync
4. Set up security rules
5. Configure production keys
6. Deploy to hosting

---

**Need Help?**

If you're still stuck, share:
1. Screenshot of Firebase Console (Web app section)
2. Your `firebase_options.dart` (hide API key)
3. Console errors (F12 in browser)

I'll help you fix it! 🚀

