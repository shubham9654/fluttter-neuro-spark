# Download google-services.json

## Quick Steps

1. **Go to Firebase Console**
   - Open: https://console.firebase.google.com/
   - Select your project: **neurospark-cf205**

2. **Download google-services.json**
   - Click the **gear icon** (⚙️) next to "Project Overview"
   - Select **"Project settings"**
   - Scroll down to **"Your apps"** section
   - Find your **Android app** (package: `com.example.neuro_spark`)
   - Click **"Download google-services.json"** button

3. **Place the file**
   - Save the downloaded file
   - Copy it to: `android/app/google-services.json`
   - Make sure it's named exactly `google-services.json`

4. **Verify the file is in the right place**
   ```
   android/app/google-services.json  ← Should exist here
   ```

5. **Rebuild the app**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

## File Location

The file should be at:
```
neuro_spark/
  android/
    app/
      google-services.json  ← Place it here
```

## After Downloading

Once you've placed the file, the app is ready! Google Sign-In should work after:
- ✅ SHA-1 added to Firebase (DONE)
- ✅ google-services.json downloaded and placed (DO THIS)
- ✅ Wait 5-10 minutes for Firebase to update
- ✅ Rebuild and test

