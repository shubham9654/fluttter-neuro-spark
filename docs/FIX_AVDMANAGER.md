# Fix "avdmanager is missing from the Android SDK"

## Quick Fix (Recommended - Using Android Studio)

1. **Open Android Studio**
2. **Go to**: `Tools` → `SDK Manager` (or click the SDK Manager icon in the toolbar)
3. **Click on the "SDK Tools" tab**
4. **Check the box**: `Android SDK Command-line Tools (latest)`
5. **Click "Apply"** and wait for installation to complete
6. **Restart your terminal/command prompt**
7. **Run**: `flutter doctor --android-licenses` to accept licenses

## Alternative: Manual Installation

### Step 1: Download Command-Line Tools

1. Go to: https://developer.android.com/studio#command-line-tools-only
2. Download the Windows version (commandlinetools-win-*.zip)
3. Extract the zip file

### Step 2: Install to Android SDK

1. Navigate to: `C:\Users\shubh\AppData\Local\Android\sdk`
2. Create folder: `cmdline-tools` (if it doesn't exist)
3. Inside `cmdline-tools`, create folder: `latest`
4. Copy all contents from the extracted zip into the `latest` folder

The structure should be:
```
C:\Users\shubh\AppData\Local\Android\sdk\cmdline-tools\latest\bin\
```

### Step 3: Verify Installation

Run in terminal:
```bash
flutter doctor -v
```

You should see:
- ✅ cmdline-tools component is installed
- ✅ avdmanager is available

### Step 4: Accept Licenses

```bash
flutter doctor --android-licenses
```

Press `y` to accept all licenses.

## Verify Fix

After installation, run:
```bash
flutter doctor -v
```

The Android toolchain should show:
- ✅ cmdline-tools component is installed
- ✅ Android license status: accepted

## Using Installation Scripts

You can also use the provided installation scripts:

**Windows:**
```cmd
scripts\install_android_tools.bat
```

**Linux/Mac:**
```bash
chmod +x scripts/install_android_tools.sh
./scripts/install_android_tools.sh
```

## Troubleshooting

If you still see errors:
1. Make sure Android SDK path is correct: `C:\Users\shubh\AppData\Local\Android\sdk`
2. Restart your terminal/IDE after installation
3. Check that `cmdline-tools\latest\bin` is in your PATH (Flutter should handle this automatically)


