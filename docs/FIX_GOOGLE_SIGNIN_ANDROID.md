# Fix Google Sign-In Error (ApiException: 10) on Android

## Error
```
ApiException: 10
PlatformException(sign_in_failed, com.google.android.gms.common.api.ApiException: 10: , null, null)
```

This error means Google Sign-In is not properly configured for your Android app. The SHA-1 fingerprint is missing from Firebase Console.

## Quick Fix

### Step 1: Get SHA-1 Fingerprint

**Option A: Using the provided script (Easiest)**

**Windows:**
```bash
scripts\get_sha1.bat
```

**Mac/Linux:**
```bash
chmod +x scripts/get_sha1.sh
./scripts/get_sha1.sh
```

**Option B: Using Gradle directly**

Run this command in the `android` directory:

```bash
cd android
./gradlew signingReport
```

Or on Windows:
```bash
cd android
gradlew signingReport
```

Look for the SHA-1 fingerprint under "Variant: debug" → "Config: debug" → "SHA1:"

**Option C: Using keytool**

**Windows:**
```bash
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android
```

**Mac/Linux:**
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android
```

Look for the SHA1 line and copy that value (format: `XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX`)

### Step 2: Add SHA-1 to Firebase

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to **Project Settings** (gear icon)
4. Scroll to **"Your apps"** section
5. Find your Android app (or add it if not present)
6. Click **"Add fingerprint"**
7. Paste your SHA-1 fingerprint
8. Click **"Save"**

### Step 3: Verify Google Sign-In is Enabled

1. In Firebase Console, go to **Authentication**
2. Click **"Sign-in method"** tab
3. Find **"Google"** in the list
4. Click on it
5. Ensure it's **Enabled**
6. Click **"Save"**

### Step 4: Rebuild and Test

```bash
flutter clean
flutter pub get
flutter run
```

## Alternative: Get SHA-1 using keytool

```bash
# Windows
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android

# Mac/Linux
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android
```

Look for the SHA1 line and copy that value.

## After Adding SHA-1

- Wait 5-10 minutes for Firebase to update
- Rebuild the app
- Try Google Sign-In again

