# Scripts Directory

This directory contains utility scripts for building and setting up the NeuroSpark project.

## Available Scripts

### Build Scripts

#### `build_apk.sh` (Linux/macOS)
Builds both debug and release APK files for Android.

**Usage:**
```bash
./scripts/build_apk.sh
```

**What it does:**
- Cleans the Flutter build cache
- Installs dependencies
- Builds debug APK (for testing)
- Builds release APK (for production)

**Output:**
- Debug APK: `build/app/outputs/flutter-apk/app-debug.apk`
- Release APK: `build/app/outputs/flutter-apk/app-release.apk`

#### `build_apk.bat` (Windows)
Windows version of the APK build script.

**Usage:**
```cmd
scripts\build_apk.bat
```

**What it does:**
- Same as `build_apk.sh` but for Windows

### Setup Scripts

#### `install_android_tools.sh` (Linux/macOS)
Installs Android SDK command-line tools and accepts licenses.

**Usage:**
```bash
./scripts/install_android_tools.sh
```

**What it does:**
- Checks for Android SDK installation
- Installs/updates Android SDK command-line tools
- Accepts Android SDK licenses
- Verifies installation with `flutter doctor`

#### `install_android_tools.bat` (Windows)
Windows version of the Android tools installation script.

**Usage:**
```cmd
scripts\install_android_tools.bat
```

**What it does:**
- Same as `install_android_tools.sh` but for Windows

## Notes

- Make scripts executable (Linux/macOS):
  ```bash
  chmod +x scripts/*.sh
  ```

- All scripts include error handling and will exit with an error code if something fails.

- Scripts are designed to be run from the project root directory.

## Troubleshooting

If scripts fail:
1. Make sure Flutter is installed and in your PATH
2. For Android scripts, ensure Android SDK is properly configured
3. Check that you have the necessary permissions to execute scripts

