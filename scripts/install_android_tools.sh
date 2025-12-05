#!/bin/bash

echo "========================================"
echo "Installing Android SDK Command-Line Tools"
echo "========================================"
echo ""

# Detect Android SDK path
if [ -d "$HOME/AppData/Local/Android/sdk" ]; then
    ANDROID_SDK="$HOME/AppData/Local/Android/sdk"
elif [ -d "/c/Users/$USER/AppData/Local/Android/sdk" ]; then
    ANDROID_SDK="/c/Users/$USER/AppData/Local/Android/sdk"
else
    echo "ERROR: Android SDK not found"
    echo "Please install Android Studio first"
    exit 1
fi

echo "Android SDK Path: $ANDROID_SDK"

# Check if cmdline-tools already exists
if [ -f "$ANDROID_SDK/cmdline-tools/latest/bin/sdkmanager" ]; then
    echo "Found existing cmdline-tools"
    SDKMANAGER="$ANDROID_SDK/cmdline-tools/latest/bin/sdkmanager"
elif [ -f "$ANDROID_SDK/tools/bin/sdkmanager" ]; then
    echo "Found tools/bin/sdkmanager"
    SDKMANAGER="$ANDROID_SDK/tools/bin/sdkmanager"
else
    echo ""
    echo "ERROR: sdkmanager not found!"
    echo ""
    echo "Please install Android SDK Command-Line Tools:"
    echo "1. Open Android Studio"
    echo "2. Go to Tools > SDK Manager"
    echo "3. Click on 'SDK Tools' tab"
    echo "4. Check 'Android SDK Command-line Tools (latest)'"
    echo "5. Click 'Apply' to install"
    echo ""
    echo "OR download from:"
    echo "https://developer.android.com/studio#command-line-tools-only"
    echo ""
    exit 1
fi

echo ""
echo "Installing/Updating Command-Line Tools..."
"$SDKMANAGER" --install "cmdline-tools;latest"

if [ $? -ne 0 ]; then
    echo ""
    echo "ERROR: Failed to install command-line tools"
    echo "Please install manually via Android Studio SDK Manager"
    exit 1
fi

echo ""
echo "========================================"
echo "Accepting Android Licenses..."
echo "========================================"
if [ -f "$ANDROID_SDK/cmdline-tools/latest/bin/sdkmanager" ]; then
    yes | "$ANDROID_SDK/cmdline-tools/latest/bin/sdkmanager" --licenses
else
    flutter doctor --android-licenses
fi

echo ""
echo "========================================"
echo "Installation Complete!"
echo "========================================"
echo ""
echo "Verifying installation..."
flutter doctor -v


