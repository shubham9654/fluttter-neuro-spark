# 🚀 NeuroSpark Quick Start Guide

Get your ADHD productivity app running in 5 minutes!

## ⚡ Quick Setup

### 1. Install Dependencies (1 min)

```bash
flutter pub get
```

### 2. Run the App (30 seconds)

```bash
# For Web (fastest for testing)
flutter run -d edge

# For Chrome
flutter run -d chrome

# For Android
flutter run -d <android-device-id>

# For iOS
flutter run -d <ios-device-id>
```

### 3. Test Core Features

✅ **Welcome Screen** → Click "Get Started" (auto anonymous login)  
✅ **Onboarding** → Complete neurotype setup  
✅ **Dashboard** → Main hub with stats and tasks  
✅ **Brain Dump** → Click "+" to add tasks  
✅ **Focus Session** → Tap a task to start 25-min timer  
✅ **Victory Screen** → See celebration after completion  
✅ **Dopamine Shop** → Browse rewards to unlock  

## 📱 Demo Mode (No Firebase Required)

The app works immediately with:
- ✅ Local storage (Hive)
- ✅ In-memory state management (Riverpod)
- ✅ Anonymous authentication
- ✅ All UI features

**Note**: Data won't persist across sessions without Firebase setup.

## 🔥 Firebase Setup (Optional - for production)

For real authentication and cloud sync, follow these steps:

### Quick Firebase Setup (10 minutes)

1. **Create Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Click "Add project" → Name: `neurospark`
   - Follow wizard to completion

2. **Enable Auth & Firestore**
   ```
   Firebase Console → Authentication → Get started
   - Enable: Anonymous ✅
   - Enable: Google ✅
   
   Firebase Console → Firestore → Create database
   - Start in test mode
   ```

3. **Get Web Config**
   ```
   Project Settings → Your apps → Web (</> icon)
   - Register app: neurospark_web
   - Copy the firebaseConfig object
   ```

4. **Update Config File**
   - Open `lib/firebase_options.dart`
   - Replace the demo values with your actual Firebase config
   ```dart
   static const FirebaseOptions web = FirebaseOptions(
     apiKey: 'YOUR_ACTUAL_API_KEY',
     appId: 'YOUR_ACTUAL_APP_ID',
     // ... etc
   );
   ```

5. **Restart App**
   ```bash
   flutter run -d edge
   ```

✅ Done! Now you have full Firebase integration.

For detailed Firebase setup (Android, iOS, Google Sign-In), see [FIREBASE_SETUP.md](FIREBASE_SETUP.md)

## 🎮 Feature Walkthrough

### 1. Welcome & Sign In
- Click "Get Started" for instant anonymous login
- Or use "Google" button for Google Sign-In
- No email/password required!

### 2. Onboarding Flow
- **Neurotype Setup**: Choose your ADHD profile
- **Energy Mapping**: Map your daily energy levels
- Takes ~2 minutes to complete

### 3. Dashboard (Main Hub)
- **Today's Progress**: Visual progress bar
- **Stats Cards**: Streak, Level, Coins
- **Quick Actions**: Brain Dump, Focus, Shop
- **Task List**: Today's selected tasks
- **FAB Button**: Quick add task

### 4. Brain Dump (Inbox)
- Type task → Press Enter or Click "+"
- **Swipe Right** → Add to Today
- **Swipe Left** → Delete task
- Zero friction capture!

### 5. Focus Session
- Tap any task to start 25-min Pomodoro
- **Pulsing animation** during active session
- **Play/Pause** controls
- **Exit dialog** prevents accidental quit
- Auto-completes task when timer ends

### 6. Victory Screen
- 🎉 Confetti animation
- Shows rewards earned:
  - +25 XP
  - +10 Coins
  - +1 Streak
- Level progress display
- Quick actions: Dashboard or Shop

### 7. Dopamine Shop
- Browse rewards by category:
  - 🎨 Themes
  - 🎵 Sounds
  - 👤 Avatars
  - ⚡ Power-ups
- Locked items show required coins
- Purchase with earned coins
- Instant unlock feedback

## 🛠 Development Tips

### Hot Reload
```bash
# After making code changes
Press 'r' in terminal (hot reload)
Press 'R' in terminal (hot restart)
```

### Check for Errors
```bash
flutter analyze
```

### Clear Build Cache
```bash
flutter clean
flutter pub get
flutter run -d edge
```

### View Logs
```bash
# Filter by severity
flutter run --verbose

# Web console (F12 in browser)
# Check Console tab for print statements
```

## 🐛 Troubleshooting

### "Firebase not initialized"
- Make sure you ran `flutter pub get`
- Check `lib/firebase_options.dart` exists
- Verify Firebase config is correct

### "Package not found"
```bash
flutter clean
flutter pub get
```

### App won't start
```bash
# Check Flutter doctor
flutter doctor

# Ensure device is connected
flutter devices

# Try different device
flutter run -d chrome  # or edge, or android
```

### Google Sign-In not working
- Requires Firebase setup
- Need OAuth credentials
- See [FIREBASE_SETUP.md](FIREBASE_SETUP.md) for details

### Build errors on web
```bash
# Clear web build
rm -rf build/web
flutter clean
flutter run -d edge
```

## 📚 Project Structure Quick Reference

```
lib/
├── main.dart                    # App entry point
├── firebase_options.dart        # Firebase config
├── common/
│   ├── routes/app_router.dart  # All navigation routes
│   ├── theme/                   # Colors, text styles, theme
│   └── widgets/                 # Reusable UI components
├── core/
│   ├── providers/               # Riverpod state providers
│   │   ├── auth_providers.dart
│   │   ├── task_providers.dart
│   │   └── game_stats_providers.dart
│   └── services/                # Firebase services
├── features/
│   ├── auth/                    # Welcome & sign in
│   ├── onboarding/              # User setup flow
│   ├── dashboard/               # Main hub
│   ├── task/                    # Brain dump & sorter
│   ├── focus/                   # Timer & victory
│   ├── gamification/            # Shop & rewards
│   ├── body_double/             # (Future feature)
│   └── settings/                # (Future feature)
```

## 🎯 Key Files to Customize

### Colors & Theming
- `lib/common/theme/app_colors.dart` - All colors
- `lib/common/theme/app_theme.dart` - Material theme
- `lib/common/theme/text_styles.dart` - Typography

### Routes & Navigation
- `lib/common/routes/app_router.dart` - All app routes

### State Management
- `lib/core/providers/*` - Riverpod providers
- Uses Notifier pattern (Riverpod 3.x)

### Data Models
- `lib/features/task/data/models/task.dart` - Task model
- `lib/features/gamification/data/models/game_stats.dart` - Game stats

## ✨ Next Steps

1. ✅ Run the app
2. ✅ Test all features
3. 🔥 Set up Firebase (optional)
4. 🎨 Customize colors/theme
5. 📱 Add your own features
6. 🚀 Deploy to production

## 💡 Pro Tips

- Use **anonymous auth** for quickest start
- **Hot reload** (r) for instant UI updates
- **Browser DevTools** (F12) for debugging
- **Riverpod DevTools** for state inspection
- Start with **web** platform for fastest iteration

## 📖 Full Documentation

- [README.md](README.md) - Complete project overview
- [FIREBASE_SETUP.md](FIREBASE_SETUP.md) - Detailed Firebase guide
- [Flutter Docs](https://docs.flutter.dev/)
- [Riverpod Docs](https://riverpod.dev/)
- [Firebase Docs](https://firebase.google.com/docs)

---

**Ready to build? Let's go! 🚀**

Need help? Check the troubleshooting section above or create an issue in the repository.

