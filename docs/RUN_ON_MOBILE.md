# Running Flutter App on Mobile Device via USB

## Prerequisites

1. **USB Cable**: Use a data cable (not just charging cable)
2. **Android Device**: Android phone or tablet
3. **Developer Options**: Enabled on your device
4. **USB Debugging**: Enabled on your device

## Step-by-Step Instructions

### Step 1: Enable Developer Options on Android

1. Open **Settings** on your Android device
2. Go to **About phone** (or **About device**)
3. Find **Build number** (or **MIUI version** for Xiaomi devices)
4. **Tap Build number 7 times** until you see "You are now a developer!"
5. Go back to Settings → You should now see **Developer options**

### Step 2: Enable USB Debugging

1. Open **Settings** → **Developer options**
2. Toggle **USB debugging** to **ON**
3. (Optional) Enable **Stay awake** (keeps screen on while charging)
4. (Optional) Enable **Install via USB** (for some devices)

### Step 3: Connect Your Device

1. Connect your Android device to your computer via USB cable
2. On your device, you may see a popup: **"Allow USB debugging?"**
   - Check **"Always allow from this computer"**
   - Tap **"Allow"** or **"OK"**

### Step 4: Verify Connection

Open terminal/command prompt and run:

```bash
flutter devices
```

You should see your device listed, for example:
```
2 connected devices:

sdk gphone64 arm64 (mobile) • emulator-5554 • android-arm64  • Android 13 (API 33)
SM G950F (mobile)           • R58M123456     • android-arm64  • Android 9 (API 28)
```

Or use ADB directly:
```bash
adb devices
```

Expected output:
```
List of devices attached
R58M123456    device
```

If you see `unauthorized`, check your device and allow USB debugging.

### Step 5: Run the App

```bash
flutter run
```

Or specify the device:
```bash
flutter run -d <device-id>
```

Example:
```bash
flutter run -d R58M123456
```

## Troubleshooting

### Device Not Detected

1. **Check USB Connection**
   - Try a different USB cable
   - Try a different USB port
   - Make sure it's a data cable, not just charging

2. **Check USB Debugging**
   - Disable and re-enable USB debugging
   - Revoke USB debugging authorizations in Developer options
   - Reconnect and allow again

3. **Install USB Drivers** (Windows)
   - Install device-specific USB drivers
   - Or install **Universal ADB Driver**: https://adb.clockworkmod.com/
   - Or use **Google USB Driver** from Android SDK

4. **Check ADB**
   ```bash
   adb kill-server
   adb start-server
   adb devices
   ```

### "Unauthorized" Device

1. On your device, check for USB debugging authorization popup
2. Tap **"Allow"** or **"OK"**
3. Check **"Always allow from this computer"** if available
4. If still unauthorized:
   - Go to Developer options → **Revoke USB debugging authorizations**
   - Disconnect and reconnect USB
   - Allow again when prompted

### App Installation Fails

1. **Enable "Install via USB"** in Developer options
2. **Allow installation from unknown sources** (if needed)
3. Check device storage space
4. Try:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

### Build Errors

If you get build errors:
```bash
flutter clean
flutter pub get
flutter run
```

## Quick Commands Reference

```bash
# List connected devices
flutter devices
adb devices

# Run on specific device
flutter run -d <device-id>

# Run in release mode (faster, no debug)
flutter run --release

# Build APK for installation
flutter build apk

# Install APK directly
adb install build/app/outputs/flutter-apk/app-debug.apk

# View device logs
flutter logs
adb logcat

# Restart ADB server
adb kill-server
adb start-server
```

## For iOS Devices (if applicable)

1. Connect iPhone/iPad via USB
2. Trust the computer on your device
3. Open Xcode → Window → Devices and Simulators
4. Select your device and click "Trust"
5. Run: `flutter run`

## Tips

- **Hot Reload**: Press `r` in terminal while app is running
- **Hot Restart**: Press `R` in terminal
- **Stop App**: Press `q` in terminal
- **Keep device unlocked** while developing for easier debugging
- **Use release mode** for testing performance: `flutter run --release`

