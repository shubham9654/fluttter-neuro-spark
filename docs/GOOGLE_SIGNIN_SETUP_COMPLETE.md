# Google Sign-In Setup - Almost Complete! ✅

## What's Done

✅ SHA-1 fingerprint added to Firebase Console  
✅ Google Services plugin configured in build files  
✅ Error handling improved in app  
✅ Flutter clean and pub get completed  

## What You Need to Do Now

### Step 1: Download google-services.json

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **neurospark-cf205**
3. Click the **gear icon** (⚙️) → **Project settings**
4. Scroll to **"Your apps"** section
5. Find your **Android app** (package: `com.example.neuro_spark`)
6. Click **"Download google-services.json"** button
7. Save the file

### Step 2: Place the File

1. Copy the downloaded `google-services.json` file
2. Place it in: `android/app/google-services.json`
3. Replace the placeholder file if it exists
4. Make sure it's named exactly `google-services.json`

### Step 3: Wait and Test

1. **Wait 5-10 minutes** for Firebase to propagate changes
2. **Rebuild the app:**
   ```bash
   flutter run
   ```
3. **Test Google Sign-In:**
   - Open the app
   - Try signing in with Google
   - Should work now! ✅

## File Structure

After downloading, your file structure should be:
```
neuro_spark/
  android/
    app/
      google-services.json  ← This file should exist here
      build.gradle
      ...
```

## Verification

To verify everything is set up:

1. ✅ SHA-1 in Firebase Console (DONE)
2. ⏳ google-services.json downloaded (DO THIS)
3. ✅ Google Services plugin configured (DONE)
4. ⏳ Wait 5-10 minutes
5. ⏳ Test Google Sign-In

## Troubleshooting

### If Google Sign-In still doesn't work:

1. **Verify google-services.json exists:**
   ```bash
   ls android/app/google-services.json
   ```

2. **Check it's the latest version:**
   - Download a fresh copy from Firebase Console
   - Make sure you downloaded it AFTER adding SHA-1

3. **Wait longer:**
   - Sometimes takes 10-15 minutes for Firebase to update

4. **Rebuild completely:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

5. **Check Firebase Console:**
   - Verify SHA-1 is listed in Project Settings → Your Android App
   - Verify Google Sign-In is enabled in Authentication → Sign-in method

## Next Steps

Once you've downloaded and placed `google-services.json`:
1. Wait 5-10 minutes
2. Run `flutter run`
3. Test Google Sign-In
4. Should work! 🎉

