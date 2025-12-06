# Fix Firestore Permission Denied Error

## Error Message
```
PERMISSION_DENIED: Cloud Firestore API has not been used in project neurospark-cf205 before or it is disabled.
```

## Quick Fix

### Step 1: Enable Firestore API

1. Go to [Google Cloud Console - Firestore API](https://console.developers.google.com/apis/api/firestore.googleapis.com/overview?project=neurospark-cf205)

2. Click **"Enable"** button

3. Wait 2-5 minutes for the API to be enabled

### Step 2: Verify Firestore Database is Created

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **neurospark-cf205**
3. Go to **Build → Firestore Database**
4. If you see "Create database", click it and:
   - Choose location (closest to your users)
   - Start in **test mode** for development
   - Click **Enable**

### Step 3: Check Firestore Security Rules

1. In Firebase Console → Firestore Database → Rules
2. For development, use test mode:
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
3. Click **Publish**

**Note**: These rules allow full read/write access until January 5, 2026. Update before production!

### Step 4: Verify in App

1. Restart your app
2. Try editing profile again
3. Should work now!

## Alternative: Enable via Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: **neurospark-cf205**
3. Go to **Build → Firestore Database**
4. Click **Create database**
5. Choose location
6. Start in **test mode**
7. Click **Enable**

This will automatically enable the Firestore API in Google Cloud Console.

## Production Security Rules

When ready for production, update Firestore rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // User's subcollections
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

## Troubleshooting

### Still Getting Permission Denied?

1. **Wait 5-10 minutes** after enabling API (propagation delay)
2. **Check billing**: Some Firebase features require billing enabled
3. **Verify project ID**: Make sure you're using the correct project
4. **Check app credentials**: Ensure `google-services.json` is up to date

### Profile Edit Still Not Working?

The app will now:
- ✅ Update display name in Firebase Auth (works even without Firestore)
- ⚠️ Show warning if Firestore is not enabled
- ✅ Still allow profile name updates

Firestore is only needed for:
- Bio storage
- Full data sync across devices
- Purchase history
- Game stats sync

## Need Help?

If issues persist:
1. Check Firebase Console for any error messages
2. Verify your `google-services.json` file is correct
3. Make sure you're logged in with the correct Firebase project account

