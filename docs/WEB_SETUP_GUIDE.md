# Web Platform Setup Guide

This guide helps you fix the errors when running NeuroSpark on web.

## Issues Fixed

### 1. AdMob Error (MissingPluginException)
**Problem**: AdMob doesn't support web platform, causing errors when initializing.

**Solution**: AdMob initialization now skips on web platform automatically. Ads will only work on mobile (Android/iOS).

### 2. Google Sign-In Error (ClientID not set)
**Problem**: Google Sign-In requires a web client ID to work on web.

**Solution**: Add your Google OAuth Client ID to `web/index.html`.

## How to Get Your Google OAuth Client ID

### Method 1: From Firebase Console (Recommended)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `neurospark-cf205`
3. Navigate to **Authentication** → **Sign-in method**
4. Click on **Google** provider
5. Find the **Web client ID** (it looks like: `123456789-abcdefghijklmnop.apps.googleusercontent.com`)
6. Copy this Client ID

### Method 2: From Google Cloud Console

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your Firebase project: `neurospark-cf205`
3. Navigate to **APIs & Services** → **Credentials**
4. Find your **OAuth 2.0 Client ID** for "Web application"
5. Copy the Client ID

## Setup Instructions

### Step 1: Update web/index.html

1. Open `web/index.html`
2. Find this line:
   ```html
   <meta name="google-signin-client_id" content="YOUR_WEB_CLIENT_ID_HERE">
   ```
3. Replace `YOUR_WEB_CLIENT_ID_HERE` with your actual Client ID from Firebase/Google Cloud Console
4. Save the file

Example:
```html
<meta name="google-signin-client_id" content="123456789-abcdefghijklmnop.apps.googleusercontent.com">
```

### Step 2: Verify Firebase Authentication Settings

1. Go to Firebase Console → Authentication → Sign-in method
2. Make sure **Google** is enabled
3. Verify the **Web client ID** is set (should be auto-populated)
4. Add authorized domains if needed:
   - `localhost`
   - Your production domain (when deployed)

### Step 3: Test

1. Run the app on web:
   ```bash
   flutter run -d chrome
   # or
   flutter run -d edge
   ```

2. Try Google Sign-In - it should work without errors now!

## Troubleshooting

### Still getting "ClientID not set" error?

1. **Check the meta tag**:
   - Make sure it's in the `<head>` section
   - Verify there are no typos in the Client ID
   - Make sure you didn't include quotes around the Client ID

2. **Clear browser cache**:
   - Hard refresh: `Ctrl+Shift+R` (Windows) or `Cmd+Shift+R` (Mac)
   - Or clear browser cache completely

3. **Verify Client ID format**:
   - Should look like: `123456789-abcdefghijklmnop.apps.googleusercontent.com`
   - Should NOT have quotes or extra spaces

4. **Check Firebase Console**:
   - Make sure Google Sign-In is enabled
   - Verify the Web client ID matches what you put in `web/index.html`

### AdMob still showing errors?

- This is expected - AdMob doesn't work on web
- The error is now caught and won't crash your app
- Ads will only display on mobile platforms (Android/iOS)

## Notes

- **AdMob**: Only works on mobile (Android/iOS), not web
- **Google Sign-In**: Works on all platforms (web, Android, iOS)
- **In-App Purchases**: Only work on mobile (Android/iOS), not web

## Next Steps

After setting up:
1. ✅ Test Google Sign-In on web
2. ✅ Test email/password authentication
3. ✅ Deploy to Firebase Hosting (optional)
4. ✅ Set up custom domain (optional)

## Resources

- [Firebase Authentication](https://firebase.google.com/docs/auth)
- [Google Sign-In for Web](https://developers.google.com/identity/sign-in/web)
- [Flutter Web](https://flutter.dev/web)

