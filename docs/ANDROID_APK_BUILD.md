# 📱 Building Android APK Files

This guide will help you build both **Debug** (for testing) and **Release** (for production) APK files for NeuroSpark.

---

## ⚠️ Prerequisites

Before building APKs, you need:

1. **Flutter SDK** installed (✅ Already installed)
2. **Android SDK** installed and configured
3. **Java Development Kit (JDK)** installed

---

## 🔧 Android SDK Setup

### Quick Setup (If Android SDK is Missing)

#### Option 1: Install Android Studio (Easiest)

1. **Download Android Studio**
   - Visit: https://developer.android.com/studio
   - Download and install

2. **Install SDK Components**
   - Open Android Studio
   - Go to `Tools` → `SDK Manager`
   - Install:
     - ✅ Android SDK Platform (latest)
     - ✅ Android SDK Build-Tools
     - ✅ Android SDK Command-line Tools
     - ✅ Android SDK Platform-Tools

3. **Set Environment Variables** (Windows)
   
   **Method A: Via GUI**
   - Right-click `This PC` → `Properties`
   - Click `Advanced system settings`
   - Click `Environment Variables`
   - Under `User variables`, click `New`:
     - Variable name: `ANDROID_HOME`
     - Variable value: `C:\Users\YourUsername\AppData\Local\Android\Sdk`
   - Edit `Path` variable and add:
     - `%ANDROID_HOME%\platform-tools`
     - `%ANDROID_HOME%\tools`
     - `%ANDROID_HOME%\tools\bin`

   **Method B: Via Command Line** (Run as Administrator)
   ```cmd
   setx ANDROID_HOME "C:\Users\%USERNAME%\AppData\Local\Android\Sdk"
   setx PATH "%PATH%;%ANDROID_HOME%\platform-tools;%ANDROID_HOME%\tools"
   ```

4. **Restart Terminal/IDE**
   - Close all terminals/IDE windows
   - Reopen and run: `flutter doctor`

#### Option 2: Command Line Tools Only (Advanced)

If you don't want to install Android Studio:

1. Download Command Line Tools:
   - Visit: https://developer.android.com/studio#command-tools
   - Download `commandlinetools-windows-xxx.zip`

2. Extract and Setup:
   ```cmd
   mkdir C:\Android\sdk\cmdline-tools
   REM Extract zip to C:\Android\sdk\cmdline-tools\latest
   
   REM Install SDK components
   cd C:\Android\sdk\cmdline-tools\latest\bin
   sdkmanager --install "platform-tools" "platforms;android-33" "build-tools;33.0.0"
   ```

3. Set Environment Variable:
   ```cmd
   setx ANDROID_HOME "C:\Android\sdk"
   setx PATH "%PATH%;%ANDROID_HOME%\platform-tools"
   ```

---

## ✅ Verify Setup

After installing Android SDK, verify:

```bash
flutter doctor
```

You should see:
```
[√] Android toolchain - develop for Android devices
```

If Android licenses are needed:
```bash
flutter doctor --android-licenses
```
Press `y` to accept all licenses.

---

## 🚀 Building APK Files

### Method 1: Using Build Scripts (Easiest)

**Windows:**
```cmd
scripts\build_apk.bat
```

**Linux/Mac:**
```bash
chmod +x scripts/build_apk.sh
./scripts/build_apk.sh
```

### Method 2: Manual Build Commands

**Build Debug APK (for testing):**
```bash
flutter build apk --debug
```
- Location: `build/app/outputs/flutter-apk/app-debug.apk`
- Size: Larger (~50-100 MB)
- Includes debug symbols and allows hot reload
- Used for testing during development

**Build Release APK (for production):**
```bash
flutter build apk --release
```
- Location: `build/app/outputs/flutter-apk/app-release.apk`
- Size: Smaller (~20-40 MB)
- Optimized and minified
- Used for distribution/testing on real devices

### Method 3: Build Split APKs (Optional)

For smaller APK sizes, you can build split APKs per ABI:

```bash
flutter build apk --split-per-abi --release
```

This creates separate APKs for:
- `app-armeabi-v7a-release.apk` (32-bit ARM)
- `app-arm64-v8a-release.apk` (64-bit ARM)
- `app-x86_64-release.apk` (64-bit x86)

---

## 📍 APK File Locations

After building, APK files will be located at:

```
build/app/outputs/flutter-apk/
├── app-debug.apk          # Debug version
└── app-release.apk        # Release version
```

---

## 🔐 Signing Release APK (For Google Play)

Currently, the release APK is signed with debug keys. For Google Play Store, you need to sign with a production key.

### Create Signing Key:

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### Configure Signing:

1. Create `android/key.properties`:
```properties
storePassword=<password from previous step>
keyPassword=<password from previous step>
keyAlias=upload
storeFile=<location of the key store file>
```

2. Update `android/app/build.gradle` to use signing config.

**Note:** This is optional for testing. Debug signing works fine for installing on devices.

---

## 📱 Installing APK on Device

### Via USB (ADB):

1. Enable Developer Options on Android device:
   - Go to `Settings` → `About phone`
   - Tap `Build number` 7 times

2. Enable USB Debugging:
   - Go to `Settings` → `Developer options`
   - Enable `USB debugging`

3. Connect device via USB and install:
   ```bash
   flutter install
   ```

   Or manually:
   ```bash
   adb install build/app/outputs/flutter-apk/app-debug.apk
   ```

### Via File Transfer:

1. Copy APK file to device
2. Open file manager on device
3. Tap APK file to install
4. Allow installation from unknown sources if prompted

---

## 🐛 Troubleshooting

### Issue: "No Android SDK found"

**Solution:**
- Verify `ANDROID_HOME` is set: `echo $ANDROID_HOME` (Linux/Mac) or `echo %ANDROID_HOME%` (Windows)
- Run `flutter config --android-sdk <path-to-sdk>`
- Restart terminal/IDE

### Issue: "Gradle build failed"

**Solution:**
- Clean build: `flutter clean`
- Get dependencies: `flutter pub get`
- Try again: `flutter build apk --release`

### Issue: "License not accepted"

**Solution:**
```bash
flutter doctor --android-licenses
```
Accept all licenses by pressing `y`.

---

## 📚 Additional Resources

- [Flutter Build Documentation](https://docs.flutter.dev/deployment/android)
- [Android SDK Setup Guide](https://flutter.dev/to/windows-android-setup)
- [APK Signing Guide](https://docs.flutter.dev/deployment/android#signing-the-app)

---

**Need help? Check the main README.md or open an issue!**

