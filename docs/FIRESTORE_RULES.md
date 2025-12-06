# Firestore Security Rules

## Test Mode Rules (Development)

Use these rules for development and testing. **DO NOT use in production!**

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

**Expires**: January 5, 2026  
**Access**: Full read/write for all authenticated users

## Production Rules (Secure)

Use these rules for production. Users can only access their own data.

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User documents - users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // User's subcollections (tasks, gameStats, purchases, etc.)
      match /tasks/{taskId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      match /gameStats/{statsId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      match /purchases/{purchaseId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      match /shopPurchases/{purchaseId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      // Allow access to all other subcollections for the user
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

## How to Update Rules

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to **Build → Firestore Database → Rules**
4. Paste the rules above
5. Click **Publish**

## Rules Explanation

### Test Mode Rules
- ✅ Allows all authenticated users to read/write all data
- ✅ Good for development and testing
- ⚠️ **NOT SECURE** - Do not use in production
- ⚠️ Expires on January 5, 2026

### Production Rules
- ✅ Users can only access their own data (`users/{userId}`)
- ✅ All subcollections protected (tasks, gameStats, purchases)
- ✅ Unauthenticated users denied access
- ✅ Secure for production use

## Testing Rules

You can test your rules using the Rules Playground in Firebase Console:
1. Go to Firestore Database → Rules
2. Click **Rules Playground**
3. Test different scenarios:
   - Authenticated user accessing own data ✅
   - Authenticated user accessing other user's data ❌
   - Unauthenticated user accessing data ❌

## Important Notes

1. **Always test rules** before deploying to production
2. **Update test mode expiration date** before it expires
3. **Monitor Firestore usage** in Firebase Console
4. **Review access logs** regularly for security

## Common Issues

### Permission Denied Errors
- Check if user is authenticated
- Verify user ID matches document path
- Ensure rules are published (not just saved)

### Rules Not Working
- Wait 1-2 minutes after publishing
- Clear app cache and restart
- Check Firebase Console for rule syntax errors

