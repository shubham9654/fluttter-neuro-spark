# 🧠 NeuroSpark

**ADHD-optimized productivity app with low friction, high reward design.**

A beautifully designed Flutter app specifically built for neurodivergent individuals, featuring gamification, focus sessions, and an intuitive task management system.

## ✨ Features

### 🎯 Core Features
- **Brain Dump Inbox** - Capture thoughts instantly without friction
- **Focus Sessions** - Pomodoro-style timer with ADHD-friendly animations
- **Smart Task Management** - Swipe-based sorting system
- **Gamification System** - Earn XP, coins, and maintain streaks
- **Dopamine Shop** - Reward yourself with themes, sounds, and power-ups
- **Victory Celebrations** - Satisfying confetti and rewards after completing tasks

### 🔥 ADHD-Optimized Design
- Low friction input for quick capture
- Visual feedback with animations and haptics
- Progress visualization with streaks and levels
- Immediate rewards for task completion
- Distraction-free focus mode

### 🎨 Modern UI
- Material 3 design system
- Smooth animations and transitions
- Responsive layouts for all screen sizes
- Beautiful gradient backgrounds
- Accessible color schemes

## 🛠 Tech Stack

- **Framework**: Flutter 3.38.3
- **State Management**: Riverpod 3.0.3
- **Navigation**: GoRouter 17.0.0
- **Backend**: Firebase
  - Authentication (Anonymous, Google Sign-In)
  - Cloud Firestore
  - Firebase Storage
- **Local Storage**: Hive 2.2.3
- **Animations**: 
  - Confetti 0.8.0
  - Custom animations with AnimationController

## 📦 Key Dependencies

```yaml
dependencies:
  flutter_riverpod: ^3.0.3
  go_router: ^17.0.0
  firebase_core: ^3.10.0
  firebase_auth: ^5.4.0
  cloud_firestore: ^5.6.0
  google_sign_in: ^6.3.0
  hive: ^2.2.3
  confetti: ^0.8.0
  font_awesome_flutter: ^10.7.0
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.38.3 or higher
- Dart 3.10.1 or higher
- Firebase project (see setup below)

### Installation

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd neuro_spark
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Firebase** (see Firebase Setup section below)

4. **Run the app**
   ```bash
   # Web
   flutter run -d edge
   
   # Android
   flutter run -d <android-device>
   
   # iOS
   flutter run -d <ios-device>
   ```

## 🔥 Firebase Setup

### 1. Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Name it `neurospark` (or your preferred name)
4. Follow the setup wizard

### 2. Enable Authentication

1. In Firebase Console, go to **Authentication**
2. Click "Get started"
3. Enable sign-in methods:
   - ✅ Anonymous
   - ✅ Google

### 3. Set up Firestore Database

1. Go to **Firestore Database**
2. Click "Create database"
3. Start in **production mode** (or test mode for development)
4. Choose a location close to your users

### 4. Add Firebase to Your App

#### Web Setup:
1. In Project Settings, scroll to "Your apps"
2. Click the Web icon `</>`
3. Register app with nickname "neuro_spark_web"
4. Copy the Firebase configuration
5. Update `lib/firebase_options.dart` with your config:

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

#### Android Setup:
1. Download `google-services.json`
2. Place it in `android/app/`
3. Update `lib/firebase_options.dart` with Android config

#### iOS Setup:
1. Download `GoogleService-Info.plist`
2. Place it in `ios/Runner/`
3. Update `lib/firebase_options.dart` with iOS config

### 5. Configure Google Sign-In (Optional)

For Google Sign-In to work:

1. In Firebase Console → Authentication → Sign-in method → Google
2. Add your SHA-1 certificate fingerprint (Android)
3. Add authorized domains for web
4. Download and update config files

### 6. Firestore Security Rules (Production)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      match /{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

## 📱 App Structure

```
lib/
├── common/
│   ├── routes/         # GoRouter navigation
│   ├── theme/          # App theme, colors, text styles
│   ├── utils/          # Utilities, constants, helpers
│   └── widgets/        # Reusable widgets
├── core/
│   ├── providers/      # Riverpod providers
│   └── services/       # Firebase, Auth, Firestore services
├── features/
│   ├── auth/           # Authentication screens
│   ├── onboarding/     # Onboarding flow
│   ├── dashboard/      # Main dashboard
│   ├── task/           # Task management (Brain Dump, Sorter)
│   ├── focus/          # Focus sessions and victory
│   ├── gamification/   # Shop, rewards, stats
│   ├── body_double/    # Body doubling feature (future)
│   └── settings/       # App settings
├── firebase_options.dart
└── main.dart
```

## 🎮 User Flow

1. **Welcome** → Anonymous sign-in or Google sign-in
2. **Onboarding** → Neurotype setup & energy mapping
3. **Dashboard** → View today's tasks, stats, and quick actions
4. **Brain Dump** → Capture tasks quickly
5. **Task Sorter** → Swipe to organize tasks
6. **Focus Session** → Pomodoro timer with animations
7. **Victory** → Celebrate completion with rewards
8. **Shop** → Spend coins on themes, sounds, and power-ups

## 🎨 Design Philosophy

### Low Friction Input
- One-tap task capture
- Swipe gestures for organization
- Minimal required fields
- Quick start with anonymous auth

### High Reward Feedback
- Immediate visual feedback
- Confetti celebrations
- XP and coin rewards
- Streak tracking
- Level progression

### ADHD-Friendly Features
- Visual progress indicators
- Haptic feedback
- Short focus sessions (25 min)
- Dopamine rewards system
- No overwhelming options

## 🧪 Development

### Running Tests
```bash
flutter test
```

### Building for Production

```bash
# Web
flutter build web --release

# Android
flutter build apk --release

# iOS
flutter build ios --release
```

### Code Generation (for Hive models)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is private and not licensed for public use.

## 🙏 Acknowledgments

- Built with ❤️ for the neurodivergent community
- Designed with input from ADHD individuals
- Inspired by evidence-based ADHD productivity strategies

## 📖 Documentation

All documentation is organized in the [`docs/`](docs/) folder:

- **[Quick Start Guide](docs/QUICK_START.md)** - Get running in 5 minutes
- **[Firebase Setup](docs/FIREBASE_SETUP.md)** - Complete Firebase configuration
- **[Project Summary](docs/PROJECT_SUMMARY.md)** - Full feature list and status
- **[Bottom Navigation Guide](docs/BOTTOM_NAV_GUIDE.md)** - Navigation system docs

## 📞 Support

For questions or issues:
- Create an issue in the repository
- Contact the development team

## 🗺 Roadmap

### Coming Soon
- [ ] Body doubling sessions
- [ ] Social features
- [ ] Custom themes
- [ ] Background sounds
- [ ] Calendar integration
- [ ] Recurring tasks
- [ ] Task templates
- [ ] Dark mode
- [ ] Desktop apps (Windows, macOS, Linux)

---

**Made with 🧠 for neurodivergent productivity**
