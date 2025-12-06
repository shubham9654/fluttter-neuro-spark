# Android Testing Guide

## 🚀 Quick Start for Android Testing

### 1. Connect Your Android Device

```bash
# Check if device is connected
flutter devices

# You should see your device listed, e.g.:
# A015 (mobile) • 0011864CV001941 • android-arm64 • Android 15 (API 35)
```

### 2. Run the App

```bash
# Run in debug mode (for testing)
flutter run -d <your-device-id>

# Or just run (Flutter will auto-select device)
flutter run
```

## ✅ Testing Features on Android

### Testing Notifications

1. **First Launch:**
   - App will request notification permission
   - Tap "Allow" when prompted

2. **Test Task Creation Notification:**
   - Open the app
   - Navigate to "Brain Dump" page
   - Add a new task (type and press add button)
   - **Expected:** You should see a notification: "✅ Task Created" with the task title
   - Notification should appear in the notification tray

3. **If Notifications Don't Work:**
   - Go to Android Settings → Apps → NeuroSpark → Notifications
   - Ensure notifications are enabled
   - Check that "Task Notifications" channel is enabled

### Testing Google Sign-In

1. **On Login Page:**
   - Tap "Continue with Google"
   - Select your Google account
   - **Expected:** Should redirect to dashboard after successful sign-in

2. **If Google Sign-In Fails:**
   - Check Firebase Console → Authentication → Sign-in method
   - Ensure Google Sign-In is enabled
   - For production, you may need to add SHA-1 fingerprint (see below)

### Testing Firebase Integration

1. **Create a Task:**
   - Add a task in Brain Dump
   - Task should sync to Firestore automatically
   - Check Firebase Console → Firestore to verify

2. **Sign In:**
   - Sign in with email or Google
   - User data should be saved to Firestore
   - Check Firebase Console → Firestore → users collection

## 🔧 Android-Specific Configuration

### For Google Sign-In (Production)

If Google Sign-In doesn't work, you may need to add SHA-1 fingerprint:

1. **Get SHA-1 Fingerprint:**
   ```bash
   # Windows
   cd android
   gradlew signingReport
   
   # Or using keytool
   keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
   ```

2. **Add to Firebase:**
   - Go to Firebase Console → Project Settings
   - Scroll to "Your apps" → Android app
   - Click "Add fingerprint"
   - Paste SHA-1 fingerprint
   - Download updated `google-services.json` (if using)

### Notification Permissions

The app requests notification permission automatically. If denied:
- Go to Android Settings → Apps → NeuroSpark → Permissions
- Enable "Notifications"

## 📱 Android Version Requirements

- **Minimum SDK:** Check `android/app/build.gradle` for `minSdk`
- **Target SDK:** Android 15 (API 35) - configured automatically
- **Notifications:** Require Android 13+ (API 33+) for POST_NOTIFICATIONS permission

## 🐛 Troubleshooting

### App Won't Install

```bash
# Uninstall existing app
adb uninstall com.example.neuro_spark

# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

### Notifications Not Working

1. Check notification permission:
   ```bash
   adb shell dumpsys package com.example.neuro_spark | grep notification
   ```

2. Check logs:
   ```bash
   flutter logs
   # Look for notification-related messages
   ```

3. Verify notification channel:
   - Settings → Apps → NeuroSpark → Notifications
   - Ensure "Task Notifications" channel exists and is enabled

### Google Sign-In Not Working

1. Check Firebase Console:
   - Authentication → Sign-in method → Google → Enabled
   - Project Settings → Your apps → Android app exists

2. Check logs:
   ```bash
   flutter logs
   # Look for Google Sign-In errors
   ```

3. Verify SHA-1 fingerprint is added (for production)

### Build Errors

```bash
# Clean build
flutter clean
flutter pub get

# Rebuild
flutter run
```

## 📊 Testing Checklist

- [ ] App installs successfully
- [ ] App launches without crashes
- [ ] Notification permission is requested
- [ ] Task creation shows notification
- [ ] Google Sign-In works
- [ ] Email/password login works
- [ ] Tasks sync to Firestore
- [ ] User data saves to Firestore
- [ ] Speech-to-text works
- [ ] All features function correctly

## 🔍 Debug Commands

```bash
# View device logs
flutter logs

# Check connected devices
flutter devices

# Run with verbose logging
flutter run -v

# Build APK for manual installation
flutter build apk --debug
```

## 📝 Notes

- **Debug Mode:** Uses debug signing keys (automatic)
- **Release Mode:** For production, configure signing keys
- **Notifications:** Work best on Android 13+ (API 33+)
- **Google Sign-In:** May require SHA-1 fingerprint for production
- **Firebase:** Works offline, syncs when online

