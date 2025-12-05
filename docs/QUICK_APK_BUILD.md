# 🚀 Quick APK Build Guide

## ⚠️ Current Status

**Android SDK is NOT configured.** You need to set it up first.

---

## 📥 Step 1: Install Android SDK

### Easiest Way - Install Android Studio:

1. **Download:** https://developer.android.com/studio
2. **Install** Android Studio
3. **Open** Android Studio → `Tools` → `SDK Manager`
4. **Install:**
   - Android SDK Platform (latest)
   - Android SDK Build-Tools
   - Android SDK Platform-Tools

### Set Environment Variable:

**Windows:**
1. Right-click `This PC` → `Properties`
2. `Advanced system settings` → `Environment Variables`
3. Add new variable:
   - Name: `ANDROID_HOME`
   - Value: `C:\Users\YourUsername\AppData\Local\Android\Sdk`
4. Edit `Path` and add:
   - `%ANDROID_HOME%\platform-tools`
   - `%ANDROID_HOME%\tools`

5. **Restart your terminal/IDE**

---

## ✅ Step 2: Verify Setup

```bash
flutter doctor
```

You should see:
```
[√] Android toolchain - develop for Android devices
```

If needed, accept licenses:
```bash
flutter doctor --android-licenses
```

---

## 🚀 Step 3: Build APKs

Once Android SDK is set up, run:

**Windows:**
```cmd
scripts\build_apk.bat
```

**Linux/Mac:**
```bash
chmod +x scripts/build_apk.sh
./scripts/build_apk.sh
```

**Or manually:**
```bash
# Debug APK (for testing)
flutter build apk --debug

# Release APK (for production)
flutter build apk --release
```

---

## 📍 APK Locations

After building:
- **Debug:** `build/app/outputs/flutter-apk/app-debug.apk`
- **Release:** `build/app/outputs/flutter-apk/app-release.apk`

---

**See `docs/ANDROID_APK_BUILD.md` for detailed instructions!**

